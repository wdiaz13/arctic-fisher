-- scripts/shop.lua
local gamedata = require("scripts.gamedata")
local fishing = require("scripts.fishing") --modify maxdepth

local shop = {}

local viewingShop = false

local upgrades = {
    {name = "Line+ Upgrade", price = 5, purchased = false},
    {name = "Reel Upgrade", price = 25, purchased = false},
    {name = "Rod Upgrade", price = 100, purchased = false},
}

local lineUpgradeLevel = 0
local reelUpgradeLevel = 0
local rodUpgradeLevel = 0

local function getLineUpgradePrice()
    --(doubles each time)
    return 5 * (2 ^ lineUpgradeLevel)
end

local function getReelUpgradePrice()
    --(doubles each time)
    return 75 * (2 ^ reelUpgradeLevel)
end

local function getRodUpgradePrice()
    --(doubles each time)
    return 100 * (2 ^ rodUpgradeLevel)
end

function shop.isOpen()
    return viewingShop
end

function shop.toggleShop()
    viewingShop = not viewingShop
end

function shop.draw()
    -- Igloo Ice Block Background
    local blockWidth = 100
    local blockHeight = 60
    for y = 0, 900, blockHeight do
        local offset = (y / blockHeight) % 2 == 0 and 0 or blockWidth / 2
        for x = -offset, 600, blockWidth do
            love.graphics.setColor(0.8, 0.9, 1.0)
            love.graphics.rectangle("fill", x, y, blockWidth - 4, blockHeight - 4, 8, 8)
            love.graphics.setColor(0.7, 0.8, 0.95)
            love.graphics.setLineWidth(2)
            love.graphics.rectangle("line", x, y, blockWidth - 4, blockHeight - 4, 8, 8)
        end
    end

    -- Window Shadow
    love.graphics.setColor(0.5, 0.5, 0.6, 0.4)
    love.graphics.rectangle("fill", 105, 185, 400, 415, 30, 30)

    -- Main Window
    love.graphics.setColor(0.7, 0.8, 1)
    love.graphics.rectangle("fill", 100, 180, 400, 415, 30, 30)

    -- Window Border Outline
    love.graphics.setColor(0.6, 0.7, 0.9)
    love.graphics.setLineWidth(6)
    love.graphics.rectangle("line", 100, 180, 400, 415, 30, 30)

    -- Driftwood Counter
    love.graphics.setColor(0.4, 0.25, 0.1)
    love.graphics.rectangle("fill", 50, 650, 500, 150, 20, 20)

    -- Upgrades
    local slotWidth = 120
local gap = (500 - (slotWidth * 3)) / 4
for i = 0, 2 do
    local x = 50 + gap + i * (slotWidth + gap)
    local y = 680

    local upgrade = upgrades[i + 1] -- 💥 THIS IS MISSING!!

    local mx, my = love.mouse.getPosition()
    local hover = mx >= x and mx <= x + slotWidth and my >= y and my <= y + 100

    if hover then
        love.graphics.setColor(1.0, 0.8, 0.3)
    else
        love.graphics.setColor(0.8, 0.8, 0.7)
    end
    love.graphics.rectangle("fill", x, y, slotWidth, 100, 10, 10)

    -- Rope Border
    love.graphics.setColor(0.6, 0.4, 0.2)
    love.graphics.setLineWidth(5)
    love.graphics.rectangle("line", x, y, slotWidth, 100, 10, 10)

    love.graphics.setColor(0, 0, 0)
    love.graphics.setFont(love.graphics.getFont())

    love.graphics.printf(upgrade.name, x, y + 20, slotWidth, "center")
    
    if upgrade.name == "Line+ Upgrade" then
        love.graphics.printf("$" .. tostring(getLineUpgradePrice()), x, y + 50, slotWidth, "center")
    elseif upgrade.name == "Reel Upgrade" then
        love.graphics.printf("$" .. tostring(getReelUpgradePrice()), x, y + 50, slotWidth, "center")
    else
        love.graphics.printf("$" .. tostring(upgrade.price), x, y + 50, slotWidth, "center")
    end    
end

    -- Wooden Sign for Trading Post
    love.graphics.setColor(0.6, 0.4, 0.2)
    love.graphics.rectangle("fill", 150, 80, 300, 70, 20, 20)

    love.graphics.setColor(0.4, 0.25, 0.1)
    love.graphics.setFont(love.graphics.newFont(28))
    love.graphics.printf("Trading Post", 150, 100, 300, "center")
    love.graphics.setFont(love.graphics.newFont(14))
end

function shop.mousepressed(x, y, button)
    if button ~= 1 then return end

    local slotWidth = 120
    local gap = (500 - (slotWidth * 3)) / 4

    for i = 0, 2 do
        local upgrade = upgrades[i + 1]
        local slotX = 50 + gap + i * (slotWidth + gap)
        local slotY = 680

        if upgrade.name == "Line+ Upgrade" then
            local price = getLineUpgradePrice()
            if gamedata.money >= price then
                gamedata.money = gamedata.money - price
                fishing.increaseMaxDepth(1)
                lineUpgradeLevel = lineUpgradeLevel + 1
            end
        elseif upgrade.name == "Reel Upgrade" then
            local price = getReelUpgradePrice()
            if gamedata.money >= price then
                gamedata.money = gamedata.money - price
                fishing.increaseReelSpeed(2)
                reelUpgradeLevel = reelUpgradeLevel + 1
            end
        else
            if not upgrade.purchased and gamedata.money >= upgrade.price then
                gamedata.money = gamedata.money - upgrade.price
                upgrade.purchased = true
                -- Future: apply Rod Upgrade effects
            end
        end        
    end
end

return shop