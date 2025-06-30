-- scripts/gamedata.lua
local gamedata = {
    money = 0,
    iceChest = {},
    depth = 0,
    fishPools = {
    {
        name = "Subglacial Zone",
        minDepth = 2.00,
        maxDepth = 5.0,
        fish = {
            {name = "Polar Cod", chance = 0.2, minWeight = 9.5, maxWeight = 16.5},
            {name = "Halibut", chance = 0.2, minWeight = 13.5, maxWeight = 40.0},
            {name = "Icefang Haddock", chance = 0.25, minWeight = 5.0, maxWeight = 10.0},
            {name = "Pink Ice Salmon", chance = 0.35, minWeight = 6.0, maxWeight = 18.0}
        }
    },
    {
        name = "Upper Shelf",
        minDepth = 0.0,
        maxDepth = 2.0,
        fish = {
            {name = "Arctic Char", chance = 0.4, minWeight = 2.3, maxWeight = 4.5},
            {name = "Capelin", chance = 0.3, minWeight = 6.5, maxWeight = 11.0},
            {name = "Polar Cod", chance = 0.2, minWeight = 9.5, maxWeight = 16.5},
            {name = "Halibut", chance = 0.1, minWeight = 13.5, maxWeight = 40.0}
        }
    }
},

    state = "idle",
    rippleTimer = 0,
    depthShakeTimer = 0,
    depthShakeStrength = 1.5,
    moneyPopTimer = 0,
    moneyPopDuration = 0.5,
}

return gamedata
