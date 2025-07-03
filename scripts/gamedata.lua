-- scripts/gamedata.lua
local gamedata = {
    money = 0,
    displayedMoney = 0,
    iceChest = {},
    depth = 0,
    fishPools = {
    {
        name = "Pressure Reef",
        minDepth = 10.1,
        maxDepth = 15.1,
        fish = {
            {name = "Ice Spine Eel", chance = 0.25, minWeight = 9.5, maxWeight = 19.5},
            {name = "Tundra Snapper", chance = 0.35, minWeight = 6.5, maxWeight = 18.0},
            {name = "White Gnasher", chance = 0.2, minWeight = 5.0, maxWeight = 60.0},
            {name = "Pallid Sturgeon", chance = 0.2, minWeight = 35.0, maxWeight = 69.9}
        }
    },
    {
        name = "Brine Veins",
        minDepth = 5.1,
        maxDepth = 10.1,
        fish = {
            {name = "Brine Sculpin", chance = 0.25, minWeight = 9.5, maxWeight = 31.5},
            {name = "Crackle Pike", chance = 0.35, minWeight = 6.5, maxWeight = 15.0},
            {name = "Blind Capelin", chance = 0.2, minWeight = 5.0, maxWeight = 10.0},
            {name = "Frostjaw Bass", chance = 0.2, minWeight = 9.0, maxWeight = 17.0}
        }
    },
    {
        name = "Subglacial Zone",
        minDepth = 2.1,
        maxDepth = 5.1,
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
        maxDepth = 2.1,
        fish = {
            {name = "Arctic Char", chance = 0.4, minWeight = 2.3, maxWeight = 4.5},
            {name = "Capelin", chance = 0.3, minWeight = 6.5, maxWeight = 11.0},
            {name = "Sunflash Smelt", chance = 0.2, minWeight = 0.2, maxWeight = 1.3},
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
