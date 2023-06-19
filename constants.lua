local constants = {};

-- Designed to be used with ResolveString
constants.WeekDay = T{
    [1] = 'Firesday',
    [2] = 'Earthsday',
    [3] = 'Watersday',
    [4] = 'Windsday',
    [5] = 'Iceday',
    [6] = 'Lightningday',
    [7] = 'Lightsday',
    [8] = 'Darksday'
};

constants.WeekDayElement = T{
    [1] = 'Fire',
    [2] = 'Earth',
    [3] = 'Water',
    [4] = 'Wind',
    [5] = 'Ice',
    [6] = 'Thunder',
    [7] = 'Light',
    [8] = 'Dark'
};

constants.Weather = T{
    [1] = 'Clear',
    [2] = 'Sunshine',
    [3] = 'Clouds',
    [4] = 'Fog',
    [5] = 'Fire',
    [6] = 'Fire x2',
    [7] = 'Water',
    [8] = 'Water x2',
    [9] = 'Earth',
    [10] = 'Earth x2',
    [11] = 'Wind',
    [12] = 'Wind x2',
    [13] = 'Ice',
    [14] = 'Ice x2',
    [15] = 'Thunder',
    [16] = 'Thunder x2',
    [17] = 'Light',
    [18] = 'Light x2',
    [19] = 'Dark',
    [20] = 'Dark x2'
};

constants.WeatherElement = T{
    [1] = 'None',
    [2] = 'None',
    [3] = 'None',
    [4] = 'None',
    [5] = 'Fire',
    [6] = 'Fire',
    [7] = 'Water',
    [8] = 'Water',
    [9] = 'Earth',
    [10] = 'Earth',
    [11] = 'Wind',
    [12] = 'Wind',
    [13] = 'Ice',
    [14] = 'Ice',
    [15] = 'Thunder',
    [16] = 'Thunder',
    [17] = 'Light',
    [18] = 'Light',
    [19] = 'Dark',
    [20] = 'Dark'
};

constants.StormWeather = {
    [178] = 4,
    [179] = 12,
    [180] = 10,
    [181] = 8,
    [182] = 14,
    [183] = 6,
    [184] = 16,
    [185] = 18,
    [589] = 5,
    [590] = 13,
    [591] = 11,
    [592] = 9,
    [593] = 15,
    [594] = 7,
    [595] = 17,
    [596] = 19
};

constants.MoonPhasePercent = T{
    [1] = 100,
    [2] = 98,
    [3] = 95,
    [4] = 93,
    [5] = 90,
    [6] = 88,
    [7] = 86,
    [8] = 83,
    [9] = 81,
    [10] = 79,
    [11] = 76,
    [12] = 74,
    [13] = 71,
    [14] = 69,
    [15] = 67,
    [16] = 64,
    [17] = 62,
    [18] = 60,
    [19] = 57,
    [20] = 55,
    [21] = 52,
    [22] = 50,
    [23] = 48,
    [24] = 45,
    [25] = 43,
    [26] = 40,
    [27] = 38,
    [28] = 36,
    [29] = 33,
    [30] = 31,
    [31] = 29,
    [32] = 26,
    [33] = 24,
    [34] = 21,
    [35] = 19,
    [36] = 17,
    [37] = 14,
    [38] = 12,
    [39] = 10,
    [40] = 7,
    [41] = 5,
    [42] = 2,
    [43] = 0,
    [44] = 2,
    [45] = 5,
    [46] = 7,
    [47] = 10,
    [48] = 12,
    [49] = 14,
    [50] = 17,
    [51] = 19,
    [52] = 21,
    [53] = 24,
    [54] = 26,
    [55] = 29,
    [56] = 31,
    [57] = 33,
    [58] = 36,
    [59] = 38,
    [60] = 40,
    [61] = 43,
    [62] = 45,
    [63] = 48,
    [64] = 50,
    [65] = 52,
    [66] = 55,
    [67] = 57,
    [68] = 60,
    [69] = 62,
    [70] = 64,
    [71] = 67,
    [72] = 69,
    [73] = 71,
    [74] = 74,
    [75] = 76,
    [76] = 79,
    [77] = 81,
    [78] = 83,
    [79] = 86,
    [80] = 88,
    [81] = 90,
    [82] = 93,
    [83] = 95,
    [84] = 98
};

constants.MoonPhase = T{
    [1] = 'Full Moon',
    [2] = 'Full Moon',
    [3] = 'Full Moon',
    [4] = 'Waning Gibbous',
    [5] = 'Waning Gibbous',
    [6] = 'Waning Gibbous',
    [7] = 'Waning Gibbous',
    [8] = 'Waning Gibbous',
    [9] = 'Waning Gibbous',
    [10] = 'Waning Gibbous',
    [11] = 'Waning Gibbous',
    [12] = 'Waning Gibbous',
    [13] = 'Waning Gibbous',
    [14] = 'Waning Gibbous',
    [15] = 'Waning Gibbous',
    [16] = 'Waning Gibbous',
    [17] = 'Waning Gibbous',
    [18] = 'Last Quarter',
    [19] = 'Last Quarter',
    [20] = 'Last Quarter',
    [21] = 'Last Quarter',
    [22] = 'Last Quarter',
    [23] = 'Last Quarter',
    [24] = 'Last Quarter',
    [25] = 'Last Quarter',
    [26] = 'Waning Crescent',
    [27] = 'Waning Crescent',
    [28] = 'Waning Crescent',
    [29] = 'Waning Crescent',
    [30] = 'Waning Crescent',
    [31] = 'Waning Crescent',
    [32] = 'Waning Crescent',
    [33] = 'Waning Crescent',
    [34] = 'Waning Crescent',
    [35] = 'Waning Crescent',
    [36] = 'Waning Crescent',
    [37] = 'Waning Crescent',
    [38] = 'Waning Crescent',
    [39] = 'New Moon',
    [40] = 'New Moon',
    [41] = 'New Moon',
    [42] = 'New Moon',
    [43] = 'New Moon',
    [44] = 'New Moon',
    [45] = 'New Moon',
    [46] = 'Waxing Crescent',
    [47] = 'Waxing Crescent',
    [48] = 'Waxing Crescent',
    [49] = 'Waxing Crescent',
    [50] = 'Waxing Crescent',
    [51] = 'Waxing Crescent',
    [52] = 'Waxing Crescent',
    [53] = 'Waxing Crescent',
    [54] = 'Waxing Crescent',
    [55] = 'Waxing Crescent',
    [56] = 'Waxing Crescent',
    [57] = 'Waxing Crescent',
    [58] = 'Waxing Crescent',
    [59] = 'First Quarter',
    [60] = 'First Quarter',
    [61] = 'First Quarter',
    [62] = 'First Quarter',
    [63] = 'First Quarter',
    [64] = 'First Quarter',
    [65] = 'First Quarter',
    [66] = 'First Quarter',
    [67] = 'Waxing Gibbous',
    [68] = 'Waxing Gibbous',
    [69] = 'Waxing Gibbous',
    [70] = 'Waxing Gibbous',
    [71] = 'Waxing Gibbous',
    [72] = 'Waxing Gibbous',
    [73] = 'Waxing Gibbous',
    [74] = 'Waxing Gibbous',
    [75] = 'Waxing Gibbous',
    [76] = 'Waxing Gibbous',
    [77] = 'Waxing Gibbous',
    [78] = 'Waxing Gibbous',
    [79] = 'Waxing Gibbous',
    [80] = 'Waxing Gibbous',
    [81] = 'Full Moon',
    [82] = 'Full Moon',
    [83] = 'Full Moon',
    [84] = 'Full Moon'
};

-- Not designed to be used with ResolveString
constants.Jobs = T{
    ['Bard'] = 'BRD',
    ['Beastmaster'] = 'BST',
    ['Black Mage'] = 'BLM',
    ['Blue Mage'] = 'BLU',
    ['Corsair'] = 'COR',
    ['Dancer'] = 'DNC',
    ['Dark Knight'] = 'DRK',
    ['Dragoon'] = 'DRG',
    ['Geomancer'] = 'GEO',
    ['Monk'] = 'MNK',
    ['Ninja'] = 'NIN',
    ['Paladin'] = 'PLD',
    ['Puppetmaster'] = 'PUP',
    ['Red Mage'] = 'RDM',
    ['Rune Fencer'] = 'RUN',
    ['Samurai'] = 'SAM',
    ['Scholar'] = 'SCH',
    ['Summoner'] = 'SMN',
    ['Thief'] = 'THF',
    ['Warrior'] = 'WAR',
    ['White Mage'] = 'WHM',
};

return constants;