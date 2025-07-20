-- scripts/fishdex.lua
local gamedata = require("scripts.gamedata")
local sound = require("scripts.sound")
local ui = require("scripts.ui") -- money access in icebox

local fishdex = {}

gamedata.iceChest = {}

local viewingChest = false

function fishdex.isChestOpen()
    return viewingChest
end

function fishdex.toggleChest()
    viewingChest = not viewingChest
end

function fishdex.update(dt)
    -- Nothing needed yet but reserved for future upgrades
end

function fishdex.drawChest()
    local defaultFont = love.graphics.getFont()

    -- Draw shadow behind cooler
    love.graphics.setColor(0.5, 0.6, 0.7, 0.5)
    love.graphics.rectangle("fill", 180, 110, 260, 700, 20, 20)

    -- Draw cooler body
    love.graphics.setColor(0.7, 0.9, 1)
    love.graphics.rectangle("fill", 170, 100, 260, 700, 20, 20)

    -- Draw cooler edge
    love.graphics.setColor(0.6, 0.8, 0.9)
    love.graphics.setLineWidth(8)
    love.graphics.rectangle("line", 170, 100, 260, 700, 20, 20)

    -- Draw slots
    for i = 1, 6 do
        local slotY = 120 + (i - 1) * 110
        local slotX = 190
        local slotWidth = 220
        local slotHeight = 80

        -- Slot Background
        love.graphics.setColor(0.9, 0.95, 1)
        love.graphics.rectangle("fill", slotX, slotY, slotWidth, slotHeight, 10, 10)

        -- Slot Border
        love.graphics.setColor(0.6, 0.8, 0.9)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", slotX, slotY, slotWidth, slotHeight, 10, 10)

        local fish = gamedata.iceChest[i]
        if fish and fish.name and fish.weight then
            local price = fishdex.calculateFishValue(fish.name, fish.weight)

            -- Draw fish info safely
            love.graphics.setColor(0, 0, 0)
            love.graphics.printf(string.format("%s - %.1fkg", fish.name, fish.weight), slotX, slotY + 20, slotWidth, "center")

            love.graphics.setColor(1.0, 0.75, 0.0)
            love.graphics.printf(string.format("($%.2f)", price), slotX, slotY + 45, slotWidth, "center")

            -- Highlight if selected
            if fish.selected then
                love.graphics.setColor(1.0, 0.8, 0.3, 0.4)
                love.graphics.rectangle("fill", slotX, slotY, slotWidth, slotHeight, 10, 10)
            end
        end
    end

    -- Draw SELL button if any fish selected
    if fishdex.anyFishSelected() then
        local buttonX = 200
        local buttonY = 30
        local buttonWidth = 200
        local buttonHeight = 50

        -- Shadow
        love.graphics.setColor(0.5, 0.4, 0.0, 0.5)
        love.graphics.rectangle("fill", buttonX + 3, buttonY + 3, buttonWidth, buttonHeight, 10, 10)

        -- Main Button
        love.graphics.setColor(1.0, 0.75, 0.0)
        love.graphics.rectangle("fill", buttonX, buttonY, buttonWidth, buttonHeight, 10, 10)

        -- Button Text
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf("SELL SELECTED", buttonX, buttonY + 15, buttonWidth, "center")
    end

    -- Draw Total Weight
    local totalWeight = 0
    for _, fish in ipairs(gamedata.iceChest) do
        if fish and fish.weight then
            totalWeight = totalWeight + fish.weight
        end
    end
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(string.format("Total Weight: %.1fkg", totalWeight), 190, 780)

    -- Always show money while in fishdex view
    ui.drawMoneyOverlay()

end

function fishdex.mousepressed(x, y, button)
    if button ~= 1 then return end

    local mx, my = x, y

    -- Check SELL button
    if fishdex.anyFishSelected() then
        local buttonX = 200
        local buttonY = 40
        local buttonWidth = 200
        local buttonHeight = 50

        if mx >= buttonX and mx <= buttonX + buttonWidth and my >= buttonY and my <= buttonY + buttonHeight then
            -- Sell all selected fish
            local total = 0
            local newIceChest = {}
            for _, fish in ipairs(gamedata.iceChest) do
                if fish and fish.selected then
                    total = total + fishdex.calculateFishValue(fish.name, fish.weight)
                elseif fish then
                    table.insert(newIceChest, fish)
                end
            end
            gamedata.iceChest = newIceChest
            gamedata.money = (gamedata.money or 0) + total
            gamedata.moneyPopTimer = gamedata.moneyPopDuration

            sound.playRandom("sell")
            return
        end
    end

    -- Check slot clicks
    for i = 1, #gamedata.iceChest do
        local slotX = 190
        local slotY = 120 + (i - 1) * 110
        local slotWidth = 220
        local slotHeight = 80

        if mx >= slotX and mx <= slotX + slotWidth and my >= slotY and my <= slotY + slotHeight then
            local fish = gamedata.iceChest[i]
            if fish then
                fish.selected = not fish.selected
                sound.playRandom("select")
            end
        end
    end
end

function fishdex.anyFishSelected()
    for _, fish in ipairs(gamedata.iceChest) do
        if fish and fish.selected then
            return true
        end
    end
    return false
end

function fishdex.calculateFishValue(name, weight)
    if name == "Arctic Char" then
        return 200.20 + 0.01 * weight
    elseif name == "Capelin" then
        return 300.40 + 0.01 * weight
    elseif name == "Sunflash Smelt" then
        return 100.80 + 0.01 * weight
    elseif name == "Polar Cod" then
        return 4.20 + 0.01 * weight
    elseif name == "Halibut" then
        return 9.50 + 0.01 * weight
    elseif name == "Icefang Haddock" then
        return 16.5 + 0.02 * weight
    elseif name == "Pink Ice Salmon" then
        return 18.0 + 0.03 * weight
    elseif name == "Brine Sculpin" then
        return 45.0 + 0.50 * weight
    elseif name == "Crackle Pike" then
        return 25.0 + 0.20 * weight
    elseif name == "Blind Capelin" then
        return 6.80 + 0.20 * weight
    elseif name == "Frostjaw Bass" then
        return 28.0 + 0.25 * weight      
    elseif name == "Ice Spine Eel" then
        return 62.0 + 0.53 * weight
    elseif name == "Tundra Snapper" then
        return 88.0 + 0.53 * weight
    elseif name == "White Gnasher" then
        return 68.0 + 0.03 * weight
    elseif name == "Pallid Sturgeon" then
        return 98.0 + 0.93 * weight        
    else
        return 0
    end
end

return fishdex
