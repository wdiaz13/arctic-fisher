-- scripts/gamedata.lua

local gamedata = {
    money = 0,
    iceChest = {},
    fishTypes = {
        {name = "Arctic Char", chance = 0.45, minWeight = 2.3, maxWeight = 4.5},
        {name = "Capelin", chance = 0.25, minWeight = 6.5, maxWeight = 11.0},
        {name = "Polar Cod", chance = 0.20, minWeight = 9.5, maxWeight = 16.5},
        {name = "Halibut", chance = 0.10, minWeight = 13.5, maxWeight = 40.0},
    },
    state = "idle",
    rippleTimer = 0,
    depthShakeTimer = 0,
    depthShakeStrength = 1.5,
    moneyPopTimer = 0,
    moneyPopDuration = 0.5,
}

return gamedata
