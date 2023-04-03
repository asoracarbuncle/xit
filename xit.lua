addon.name      = 'XIT'
addon.author    = 'Asora';
addon.version   = '0.1.8';
addon.desc      = 'Sends information to a centralized server so it can be aggregated.';
addon.link      = 'https://horizonxi-tracker.com/';

require('common');
local chat = require('chat');
local http = require('socket.http');
local json = require('json');
local ltn12 = require('socket.ltn12');
local os = require('os');
local settings = require('settings');

-- Default settings
local defaultSettings = {
    token = nil
};

-- XIT globals
local xit = T{
    zoneId = 0,
    urls = {
        login = "http://laravel.local/api/login",
        logout = "http://laravel.local/api/logout",
        mobkills = "http://laravel.local/api/mobkills",
    },
    settings = settings.load(defaultSettings),
};

--[[
* Attempts to login with the provided credentials
*
* @param {string} email - The user's email
* @param {string} password - The user's password
--]]
local function attemptLogin(email, password)

    -- Process the request
    local reqBody = json.encode({
        ['email'] = email,
        ['password'] = password
    });
    local respBody = {};
    local reqBody, reqCode, reqHeaders, reqStatus = http.request {
        url = xit.urls.login,
        method = "POST",
        headers = {
            ["Accept"] = "application/json",
            ["Content-Type"] = "application/json",
            ["Content-Length"] = string.len(reqBody),
        },
        source = ltn12.source.string(reqBody),
        sink = ltn12.sink.table(respBody),
    }

    -- Process the response
    if (reqCode == 201) then

        -- Convert the response body to a table
        local decodedResponse = json.decode(respBody[1]);
        xit.settings.token = decodedResponse.token;

        -- Login succeeded
        print(chat.header(addon.name):append(chat.message('Login successful!')));

    else
        -- Login failed
        print(chat.header(addon.name):append(chat.error('Login Failed: ')):append(chat.message('Please try again.')));

    end

    settings.save();

end

--[[
* Attempts to logout of the existing session
--]]
local function attemptLogout()
    
    -- Ensure there is a saved token before continuing
    if (xit.settings.token ~= '') then

        -- Process the request
        local reqBody = json.encode({});
        local respBody = {};
        local reqBody, reqCode, reqHeaders, reqStatus = http.request {
            url = xit.urls.logout,
            method = "POST",
            headers = {
                ["Accept"] = "application/json",
                ["Authorization"] = "Bearer " .. xit.settings.token,
                ["Content-Type"] = "application/json",
                ["Content-Length"] = string.len(reqBody),
            },
            source = ltn12.source.string(reqBody),
            sink = ltn12.sink.table(respBody),
        }

        -- Process the response
        if (reqCode == 201) then

            -- Login succeeded
            xit.settings.token = '';
            print(chat.header(addon.name):append(chat.message('Logout successful!')));

        elseif (reqCode == 401) then
            xit.settings.token = '';
            print(chat.header(addon.name):append(chat.error('Logout Failed: ')):append(chat.message('You are not signed in.')));
        end

    else
        xit.settings.token = '';
        print(chat.header(addon.name):append(chat.error('Logout Failed: ')):append(chat.message('You are not signed in.')));
    end

    settings.save();

end

--[[
* event: load
* desc : Event called when the addon is being loaded.
--]]
ashita.events.register('load', 'load_cb', function ()

    -- Get the zone id
    xit.settings.zoneId = AshitaCore:GetMemoryManager():GetParty():GetMemberZone(0);

end);

--[[
* event: command
* desc : Event called when the addon is processing a command.
--]]
ashita.events.register('command', 'command_cb', function (e)

    -- Get the command arguments
    local args = e.command:args();

    -- End immediately if no args were passed
    if (#args < 2 or args[1] ~= '/xit') then
        return;
    end

    -- Handle: /xit help - Shows the addon help.
    if (args[2] == 'help') then

        -- Print the opening line of the help information
        print(chat.header(addon.name):append(chat.message('Available commands:')));

        -- Build a list of available commands
        local commands = T{
            {'/xit help', 'Displays the addons help information.'},
            {'/xit login [username] [password]', 'Login to the XIT data service.'},
            {'/xit logout', 'Attempts to log out of the XIT data service.'},
        };
    
        -- Print the list of available commands
        commands:ieach(function (v)
            print(chat.header(addon.name):append(chat.error('Usage: ')):append(chat.message(v[1]):append(' - ')):append(chat.color1(6, v[2])));
        end);

    end

    -- Handle: /xit login - Attempts to login.
    if (args[2] == 'login' and #args >= 4) then
        attemptLogin(args[3], args[4]);
    end

    -- Handle: /xit logout - Attempts to login.
    if (args[2] == 'logout') then
        attemptLogout();
    end
    
end);

--[[
* event: packet_in
* desc : Event called when the addon is processing incoming packets.
--]]
ashita.events.register('packet_in', 'packet_in_cb', function (e)

    -- All the different ways a mob will need to be tracked
    -- 1.) Direct kill from the player running the addon
    -- 2.) Indirect kill from the player running the addon
    -- 3.) Direct kill from a player in the party of someone running the addon
    -- 4.) Indirect kill from a player in the party of someone running the addon
    -- 5.) A mob that died nearby from an unknown cause

    -- Grab some basic info from memory
    local memEntity = AshitaCore:GetMemoryManager():GetEntity()
    local memParty = AshitaCore:GetMemoryManager():GetParty()
    local memPlayer = AshitaCore:GetMemoryManager():GetPlayer()
    local memPlayerIndex = memParty:GetMemberIndex(0)
    local memTargetIndex = memParty:GetMemberTargetIndex(0)

    -- Packet: Zone Enter / Zone Leave
    if (e.id == 0x000A) then
        xit.settings.zoneId = struct.unpack('H', e.data, 0x30 + 0x01);
    end

    -- Packet: Kill Message (Not yet implemented)
    if (e.id == 0x002D) then
        local kmPlayer          = struct.unpack('l', e.data, 0x04 + 0x01); -- Player ID in the case of RoE log updates
        local kmTarget          = struct.unpack('l', e.data, 0x08 + 0x01); -- ID
        local kmPlayerIndex     = struct.unpack('H', e.data, 0x0C + 0x01); -- Player Index in the case of RoE log updates
        local kmTargetIndex     = struct.unpack('H', e.data, 0x0E + 0x01); -- EXP gained, etc. Numerator for RoE objectives
        local kmP1              = struct.unpack('l', e.data, 0x10 + 0x01); -- Denominator for RoE objectives
        local kmP2              = struct.unpack('l', e.data, 0x14 + 0x01);
        local kmMessage         = struct.unpack('H', e.data, 0x18 + 0x01);
        local kmFlags           = struct.unpack('H', e.data, 0x1A + 0x01); -- This could also be a third parameter, but I suspect it is flags because I have only ever seen one bit set.
    end

    -- Packet: Found Item (Not yet implemented)
    if (e.id == 0x00D2) then
        local fiDropper       = struct.unpack('l', e.data, 0x08 + 0x01); -- ID
        local fiCount         = struct.unpack('l', e.data, 0x0C + 0x01); -- Takes values greater than 1 in the case of gil
        local fiItem          = struct.unpack('H', e.data, 0x10 + 0x01);
        local fiDropperIndex  = struct.unpack('H', e.data, 0x12 + 0x01); -- Index
        local fiIndex         = struct.unpack('B', e.data, 0x14 + 0x01); -- This is the internal index in memory, not the one it appears in in the menu
        local fiOld           = struct.unpack('B', e.data, 0x15 + 0x01); -- This is true if it's not a new drop, but appeared in the pool before you joined a party
        local fiTimestamp     = struct.unpack('l', e.data, 0x18 + 0x01); -- Utime
    end

    -- Packet: Action Message
    if (e.id == 0x0029) then
        local amActor         = struct.unpack('l', e.data, 0x08 + 0x01); -- ID
        local amtarget        = struct.unpack('l', e.data, 0x0C + 0x01); -- ID
        local amP1            = struct.unpack('l', e.data, 0x10 + 0x01);
        local amP2            = struct.unpack('l', e.data, 0x12 + 0x01);
        local amActorIndex    = struct.unpack('H', e.data, 0x14 + 0x01);
        local amTargetIndex   = struct.unpack('H', e.data, 0x16 + 0x01);
        local amMessage       = struct.unpack('H', e.data, 0x18 + 0x01);

        -- A player killed a mob
        if (amMessage == 6) then
            local messagePlayer = GetEntity(amActorIndex);
            local messageMob = GetEntity(amTargetIndex);

            -- Player running the addon killed a mob directly
            if (memParty:GetMemberServerId(0) == messagePlayer.ServerId) then

                -- Prepare the request data
                local reqData = {
                    ['player_id'] = messagePlayer.ServerId,
                    ['player_name'] = messagePlayer.Name,
                    ['player_job_id'] = memParty:GetMemberMainJob(0),
                    ['player_job_level'] = memParty:GetMemberMainJobLevel(0),
                    ['player_subjob_id'] = memParty:GetMemberSubJob(0),
                    ['player_subjob_level'] = memParty:GetMemberSubJobLevel(0),
                    ['mob_id'] = messageMob.ServerId,
                    ['mob_name'] = messageMob.Name,
                    ['mob_level'] = 0,
                    ['zone_id'] = xit.settings.zoneId,
                    ['position_x'] = memEntity:GetLocalPositionX(amActorIndex),
                    ['position_y'] = memEntity:GetLocalPositionY(amActorIndex),
                    ['position_z'] = memEntity:GetLocalPositionZ(amActorIndex),
                };
                
                -- Process the request
                local reqBody = json.encode(reqData);
                local respBody = {};
                local reqBody, reqCode, reqHeaders, reqStatus = http.request {
                    url = xit.urls.mobkills,
                    method = "POST",
                    headers = {
                        ["Accept"] = "application/json",
                        ["Authorization"] = "Bearer " .. xit.settings.token,
                        ["Content-Type"] = "application/json",
                        ["Content-Length"] = string.len(reqBody),
                    },
                    source = ltn12.source.string(reqBody),
                    sink = ltn12.sink.table(respBody),
                }

                -- Process the response
                if (reqCode == 201) then

                    -- Login succeeded
                    print(chat.header(addon.name):append(chat.message('Kill information submitted!')));

                else
                    -- Login failed
                    print(chat.header(addon.name):append(chat.error('Error: ')):append(chat.message('Kill information could not be submitted.')));

                end

            -- Someone killed a mob nearby (Not yet implemented)
            else

            end

        end
        
        -- A mob died nearby from an unknown cause (Not yet implemented)
        if (amMessage == 20) then
        end

    end

    return;

end);

--[[
* event: unload
* desc : Event called when the addon is being unloaded.
--]]
ashita.events.register('unload', 'unload_cb', function ()
end);
