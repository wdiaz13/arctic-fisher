-- scripts/ui.lua
local gamedata = require("scripts.gamedata")

local ui = {}

local defaultFont
local signFont

function ui.loadFonts()
    defaultFont = love.graphics.newFont(14)
    signFont = love.graphics.newFont(28)
    love.graphics.setFont(defaultFont)
end

function ui.drawBackground()
    -- Arctic Horizon
    love.graphics.setColor(0.7, 0.9, 1.0)
    love.graphics.rectangle("fill", 0, 0, 600, 50)

    -- Water Gradient
    for y = 50, 900 do
        local t = (y - 50) / (900 - 50)
        local r = 0.0
        local g = 0.2 * (1 - t)
        local b = 0.4 * (1 - t)
        love.graphics.setColor(r, g, b)
        love.graphics.rectangle("fill", 0, y, 600, 1)
    end

    -- Ice
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.rectangle("fill", 0, 47, 600, 8)

    -- Fishing Hole
    love.graphics.setColor(0, 0, 0)
    love.graphics.ellipse("fill", 300, 52, 9, 3)

    -- Fisherman
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 285, 17, 30, 30)
end

function ui.drawOverlay(depth, message, money, inventoryFull, caughtFish)
    -- Fishing Line
    local lineLength = (depth / 1.0) * 170
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(2)
    love.graphics.line(300, 50, 300, 50 + lineLength)

    -- Ripple Effect (if in bite state)
    if gamedata.state == "bite" then
        local centerX = 300
        local centerY = 50 + lineLength
        local rippleRadius = 10 + (gamedata.rippleTimer * 50) % 50

        love.graphics.setColor(0, 0.6, 1)
        love.graphics.circle("fill", centerX, centerY, 5)

        love.graphics.setColor(0, 0.6, 1, 1 - (rippleRadius / 50))
        love.graphics.setLineWidth(2)
        love.graphics.circle("line", centerX, centerY, rippleRadius)
    end

    -- Money Pop Effect
    local popScale = 1.0
    if gamedata.moneyPopTimer and gamedata.moneyPopTimer > 0 then
        popScale = 1.0 + 0.5 * (gamedata.moneyPopTimer / gamedata.moneyPopDuration)
    end

    love.graphics.push()
    love.graphics.translate(10, 10)
    love.graphics.scale(popScale, popScale)

    -- Shadow
    love.graphics.setColor(0, 0, 0.1)
    love.graphics.print(string.format("$%.2f", money), 1, 1)

    -- Main Money
    love.graphics.setColor(1.0, 0.75, 0.0)
    love.graphics.print(string.format("$%.2f", money), 0, 0)

    love.graphics.pop()

    -- Depth Text
    local depthX = 10
    local depthY = 30

    if gamedata.depthShakeTimer and gamedata.depthShakeTimer > 0 then
        depthX = depthX + math.random(-gamedata.depthShakeStrength, gamedata.depthShakeStrength)
        depthY = depthY + math.random(-gamedata.depthShakeStrength, gamedata.depthShakeStrength)
    end

    -- Shadow
    love.graphics.setColor(0, 0, 0.1)
    love.graphics.print(string.format("Depth: %.1fm", depth), depthX + 1, depthY + 1)

    -- Main Text
    if gamedata.depthShakeTimer and gamedata.depthShakeTimer > 0 then
        love.graphics.setColor(1, 0.3, 0.3)
    else
        love.graphics.setColor(1, 1, 1)
    end
    love.graphics.print(string.format("Depth: %.1fm", depth), depthX, depthY)

    -- Reset color
    love.graphics.setColor(1, 1, 1)

    -- Message
    love.graphics.printf(message, 0, 860, 600, "center")

    -- Catch Text
    if caughtFish then
        love.graphics.printf(caughtFish, 0, 800, 600, "center")
    end

    -- Inventory Full Warning
    if inventoryFull then
        love.graphics.setColor(1, 0, 0)
        love.graphics.printf("Inventory Full!", 0, 400, 600, "center")
    end

    -- Icebox Shortcut
    love.graphics.setColor(0, 0, 0.1)
    love.graphics.print("'I' open Icebox", 491, 11)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("'I' open Icebox", 490, 10)

    -- Trading Post Shortcut
    love.graphics.setColor(0, 0, 0.1)
    love.graphics.print("'P' open Trading Post", 447, 31)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("'P' open Trading Post", 446, 30)
end

return ui
