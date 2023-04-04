local data = {};
data.Constants = require('constants');

data.ResolveString = function(table, value)
    if (table[value + 1] == nil) then
        return 'Unknown';
    else
        return table[value + 1];
    end
end

data.GetWeather = function()
    local pWeather = ashita.memory.find('FFXiMain.dll', 0, '66A1????????663D????72', 0, 0);
    local pointer = ashita.memory.read_uint32(pWeather + 0x02);
    return ashita.memory.read_uint8(pointer + 0);
end

data.GetTimestamp = function()
    local pVanaTime = ashita.memory.find('FFXiMain.dll', 0, 'B0015EC390518B4C24088D4424005068', 0, 0);
    local pointer = ashita.memory.read_uint32(pVanaTime + 0x34);
    local rawTime = ashita.memory.read_uint32(pointer + 0x0C) + 92514960;
    local timestamp = {};
    timestamp.day = math.floor(rawTime / 3456);
    timestamp.hour = math.floor(rawTime / 144) % 24;
    timestamp.minute = math.floor((rawTime % 144) / 2.4);
    return timestamp;
end

data.GetEnvironment = function()
    local environmentTable = {};
    environmentTable.Area = AshitaCore:GetResourceManager():GetString("zones.names", AshitaCore:GetMemoryManager():GetParty():GetMemberZone(0));
    local timestamp = data.GetTimestamp();
    environmentTable.Day = data.Constants.WeekDay[(timestamp.day % 8) + 1];
    environmentTable.DayElement = data.Constants.WeekDayElement[(timestamp.day % 8) + 1];
    environmentTable.MoonPhase = data.ResolveString(data.Constants.MoonPhase, ((timestamp.day + 26) % 84) + 1);
    environmentTable.MoonPercent = data.Constants.MoonPhasePercent[((timestamp.day + 26) % 84) + 1];
    local weather = data.GetWeather();
    environmentTable.RawWeather = data.ResolveString(data.Constants.Weather, weather);
    environmentTable.RawWeatherElement = data.ResolveString(data.Constants.WeatherElement, weather);
    environmentTable.Time = timestamp.hour .. ":" ..  timestamp.minute;
    environmentTable.Timestamp = timestamp;
    environmentTable.Weather = data.ResolveString(data.Constants.Weather, weather);
    environmentTable.WeatherElement = data.ResolveString(data.Constants.WeatherElement, weather);
    return environmentTable;
end

return data;