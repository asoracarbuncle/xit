addon.name      = 'FFXITracker'
addon.author    = 'Asora';
addon.version   = '0.1';
addon.desc      = 'Sends information to a centralized server so it can be aggregated.';
addon.link      = 'https://ffxitracker.com/';

require('common');

chat            = require('chat');
http            = require('socket.http');
json            = require('json');
ltn12           = require('socket.ltn12');
settings        = require('settings');

constants        = require('constants');

ffxitDefaults   = { token = nil };
ffxitGlobals    = {
    urls = {
        login = "http://10.0.0.250/api/v1/login",
        tokenLogin = "http://10.0.0.250/api/v1/token-login",
        logout = "http://10.0.0.250/api/v1/logout",
        fishingCatches = "http://10.0.0.250/api/v1/fishing-catches",
        itemDrops = "http://10.0.0.250/api/v1/item-drops",
        mobKills = "http://10.0.0.250/api/v1/mob-kills",
    },
    settings = settings.load(ffxitDefaults),
    tokenName = 'addon_v01_ashita_v4',
};

--[[
* Submits a request to the data service
*
* @param {string} reqUrl - The target URL of the request
* @param {string} reqMethod - The http request method
* @param {table} reqHeaders - A table of the http headers
* @param {string} reqBody - The body of the request
*
* @return {integer} resStatus - The response status
* @return {integer} resCode - The response code
* @return {table} resHeaders - The response headers
* @return {string} resBody - The response body content
--]]
local function httpRequest(reqUrl, reqMethod, reqHeaders, reqBody)

    -- Process the request
    local resBody = {};
    local resStatus, resCode, resHeaders = http.request {
        url = reqUrl,
        method = reqMethod,
        headers = reqHeaders,
        source = ltn12.source.string(reqBody),
        sink = ltn12.sink.table(resBody),
    }

    -- Return the results
    return resStatus, resCode, resHeaders, json.decode(resBody[1]);

end

--[[
* Attempts to login with the provided credentials
*
* @param {string} email - The user's email
* @param {string} password - The user's password
--]]
local function login(email, password)

    -- Construct the request info
    local reqUrl = ffxit.urls.login;
    local reqMethod = 'POST';
    local reqBody = json.encode({
        ['email'] = email,
        ['password'] = password,
        ['token_name'] = ffxit.tokenName,
    });
    local reqHeaders = {
        ['Accept'] = 'application/json',
        ['Content-Type'] = 'application/json',
        ['Content-Length'] = string.len(reqBody),
    };

    -- Execute the request
    local resStatus, resCode, resHeaders, resBody = httpRequest(reqUrl, reqMethod, reqHeaders, reqBody);

    -- Process the response
    if (resCode == 201) then

        -- Convert the response body to a table
        ffxitGlobals.settings.token = resBody.token;
        settings.save();

        -- Login succeeded
        print(chat.header(addon.name):append(chat.message('Login successful!')));

    else
        -- Login failed
        print(chat.header(addon.name):append(chat.error('Login Failed: ')):append(chat.message('Please try again.')));

    end

end

--[[
* Attempts to logout of the existing session
--]]
local function logout()

    -- Check if we have a token
    if (ffxitGlobals.settings.token) then

        -- Construct the request info
        local reqUrl = ffxitGlobals.urls.logout;
        local reqMethod = 'POST';
        local reqBody = json.encode({});
        local reqHeaders = {
            ['Accept'] = 'application/json',
            ["Authorization"] = "Bearer " .. ffxitGlobals.settings.token,
            ['Content-Type'] = 'application/json',
            ['Content-Length'] = string.len(reqBody),
        };

        -- Execute the request
        local resStatus, resCode, resHeaders, resBody = httpRequest(reqUrl, reqMethod, reqHeaders, reqBody);

        -- Process the response
        if (resCode == 201) then

            -- Convert the response body to a table
            ffxitGlobals.settings.token = nil;
            settings.save();

            -- Logout succeeded
            print(chat.header(addon.name):append(chat.message('Logout successful!')));

        end

    end

    -- Logout failed
    print(chat.header(addon.name):append(chat.error('Logout Failed: ')):append(chat.message('You are not logged in.')));

end

--[[
* event: load
* desc : Event called when the addon is being loaded.
--]]
ashita.events.register('load', 'load_cb', function ()

    -- Construct the request info
    local reqUrl = ffxitGlobals.urls.tokenLogin;
    local reqMethod = 'POST';
    local reqBody = json.encode({});
    local reqHeaders = {
        ['Accept'] = 'application/json',
        ["Authorization"] = "Bearer " .. ffxitGlobals.settings.token,
        ['Content-Type'] = 'application/json',
        ['Content-Length'] = string.len(reqBody),
    };

    -- Execute the request
    local resStatus, resCode, resHeaders, resBody = httpRequest(reqUrl, reqMethod, reqHeaders, reqBody);

    -- Process the response
    if (resCode == 201) then

        -- Login succeeded
        print(chat.header(addon.name):append(chat.message('Logged in successfully!')));

    else
        -- Login failed
        print(chat.header(addon.name):append(chat.error('Login Failed: ')):append(chat.message('Please run the login command.')));

    end

end);

--[[
* event: command
* desc : Event called when the addon is processing a command.
--]]
ashita.events.register('command', 'command_cb', function (e)

    -- Get the command arguments
    local args = e.command:args();

    -- End immediately if no args were passed
    if (#args < 2 or args[1] ~= '/ffxit') then
        return;
    end

    -- Handle: /ffxit help - Shows the addon help.
    if (args[2] == 'help') then

        -- Print the opening line of the help information
        print(chat.header(addon.name):append(chat.message('Available commands:')));

        -- Build a list of available commands
        local commands = T{
            {'/ffxit help', 'Displays the addons help information.'},
            {'/ffxit login [username] [password]', 'Log into the FFXI Tracker service.'},
            {'/ffxit logout', 'Logs out of the FFXI Tracker data service.'},
        };
    
        -- Print the list of available commands
        commands:ieach(function (v)
            print(chat.header(addon.name):append(chat.error('Usage: ')):append(chat.message(v[1]):append(' - ')):append(chat.color1(6, v[2])));
        end);

    -- Handle: /ffxit login - Attempts to login.
    elseif (args[2] == 'login' and #args >= 4) then
        login(args[3], args[4]);

    -- Handle: /ffxit logout - Attempts to login.
    elseif (args[2] == 'logout') then
        logout();

    -- Handle: Everything else
    else
        print(chat.header(addon.name):append(chat.message('Unsupported command. Try again.')));

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
    -- local memEntity = AshitaCore:GetMemoryManager():GetEntity();
    -- local memPlayer = AshitaCore:GetMemoryManager():GetPlayer();
    -- local memPlayerIndex = memParty:GetMemberIndex(0);
    -- local memTargetIndex = memParty:GetMemberTargetIndex(0);

    -- Packet: Zone Enter / Zone Leave
    if (e.id == 0x000A) then
        ffxitGlobals.settings.zoneId = struct.unpack('H', e.data, 0x30 + 0x01);
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

            -- Common items
            local pEntity       = AshitaCore:GetMemoryManager():GetEntity();
            local pPlayer       = AshitaCore:GetMemoryManager():GetPlayer();
            local pParty        = AshitaCore:GetMemoryManager():GetParty();
            local playerIndex   = pParty:GetMemberTargetIndex(0);
            local mob           = GetEntity(amTargetIndex);

            -- Player running the addon killed a mob directly
            if (true) then

                -- Prereqs
                local jobIndex = pPlayer:GetMainJob();
                local subjobIndex = pPlayer:GetSubJob();
                local timeLocation = ashita.memory.find('FFXiMain.dll', 0, 'B0015EC390518B4C24088D4424005068', 0, 0);
                local timePointer = ashita.memory.read_uint32(timeLocation + 0x34);
                local rawTime = ashita.memory.read_uint32(timePointer + 0x0C) + 92514960;
                local vanaTime = {};
                vanaTime.day = math.floor(rawTime / 3456);
                vanaTime.hour = math.floor(rawTime / 144) % 24;
                vanaTime.minute = math.floor((rawTime % 144) / 2.4);
                vanaTime.second = '00';
                local dayIndex = (vanaTime.day % 8) + 1;
                local weatherPointer = ashita.memory.find('FFXiMain.dll', 0, '66A1????????663D????72', 0, 0);
                local weatherIndex = ashita.memory.read_uint8(ashita.memory.read_uint32(weatherPointer + 0x02) + 0);
                local moonPhaseIndex = ((vanaTime.day + 26) % 84) + 1;
                
                -- Player
                local jobName               = AshitaCore:GetResourceManager():GetString("jobs.names", jobIndex);
                local jobAbbreviation       = AshitaCore:GetResourceManager():GetString("jobs.names_abbr", jobIndex);
                local jobLevel              = pPlayer:GetMainJobLevel();
                local playerName            = pParty:GetMemberName(0);
                local positionX             = pEntity:GetLocalPositionX(playerIndex)
                local positionY             = pEntity:GetLocalPositionY(playerIndex)
                local positionZ             = pEntity:GetLocalPositionZ(playerIndex)
                local subJobName            = AshitaCore:GetResourceManager():GetString("jobs.names", subjobIndex);
                local subJobAbbreviation    = AshitaCore:GetResourceManager():GetString("jobs.names_abbr", subjobIndex);
                local subJobLevel           = pPlayer:GetSubJobLevel();

                -- Mob
                local mobName = mob.Name;

                -- Environment
                local dayName           = constants.WeekDay[dayIndex];
                local moonPhaseName     = constants.MoonPhase[moonPhaseIndex + 1];
                local time              = vanaTime.hour .. ':' .. vanaTime.minute .. ':' .. vanaTime.second
                local weatherName       = constants.Weather[weatherIndex + 1];
                local zoneName          = AshitaCore:GetResourceManager():GetString("zones.names", AshitaCore:GetMemoryManager():GetParty():GetMemberZone(0));

                -- Debugging
                -- print(chat.header(addon.name):append(chat.message('Job Name: ' .. jobName)));
                -- print(chat.header(addon.name):append(chat.message('Job Abbreviation: ' .. jobAbbreviation)));
                -- print(chat.header(addon.name):append(chat.message('Job Level: ' .. jobLevel)));
                -- print(chat.header(addon.name):append(chat.message('Player Name: ' .. playerName)));
                -- print(chat.header(addon.name):append(chat.message('Position X: ' .. positionX)));
                -- print(chat.header(addon.name):append(chat.message('Position Y: ' .. positionY)));
                -- print(chat.header(addon.name):append(chat.message('Position Z: ' .. positionZ)));
                -- print(chat.header(addon.name):append(chat.message('Subjob Name: ' .. subJobName)));
                -- print(chat.header(addon.name):append(chat.message('Subjob Abbreviation: ' .. subJobAbbreviation)));
                -- print(chat.header(addon.name):append(chat.message('Subjob Level: ' .. subJobLevel)));
                -- print(chat.header(addon.name):append(chat.message('Mob Name: ' .. mobName)));
                -- print(chat.header(addon.name):append(chat.message('Day Name: ' .. dayName)));
                -- print(chat.header(addon.name):append(chat.message('Moon Phase: ' .. moonPhaseName)));
                -- print(chat.header(addon.name):append(chat.message('Time: ' .. time)));
                -- print(chat.header(addon.name):append(chat.message('Weather Name: ' .. weatherName)));
                -- print(chat.header(addon.name):append(chat.message('Zone Name: ' .. zoneName)));

                -- Construct the request info
                local reqUrl = ffxitGlobals.urls.mobKills;
                local reqMethod = 'POST';
                local reqBody = json.encode({
                    ['day_name'] = dayName,
                    ['mob_name'] = mobName,
                    ['moon_phase_name'] = moonPhaseName,
                    ['job_name'] = jobName,
                    ['job_abbreviation'] = jobAbbreviation,
                    ['server_name'] = 'Horizon',
                    ['sub_job_name'] = subJobName,
                    ['sub_job_abbreviation'] = subJobAbbreviation,
                    ['weather_name'] = weatherName,
                    ['zone_name'] = zoneName,
                    ['player_name'] = playerName,
                    ['job_level'] = jobLevel,
                    ['sub_job_level'] = subJobLevel,
                    ['time'] = time,
                    ['position_x'] = positionX,
                    ['position_y'] = positionY,
                    ['position_z'] = positionZ
                });
                local reqHeaders = {
                    ['Accept'] = 'application/json',
                    ["Authorization"] = "Bearer " .. ffxitGlobals.settings.token,
                    ['Content-Type'] = 'application/json',
                    ['Content-Length'] = string.len(reqBody),
                };

                -- Execute the request
                local resStatus, resCode, resHeaders, resBody = httpRequest(reqUrl, reqMethod, reqHeaders, reqBody);

                -- Process the response
                if (resCode ~= 201) then
                    -- Request failed
                    print(chat.header(addon.name):append(chat.message('There was an error sending the kill data.')));
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
