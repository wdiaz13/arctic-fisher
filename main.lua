-- Arctic Fisher Phase 1 

-- Game States
local state = "idle" -- 'idle', 'dropping', 'waiting', 'bite', 'reeling', 'caught', 'missed'

-- Line Properties
local depth = 0
local maxDepth = 1.0
local dropSpeed = 0.2
local reelSpeed = 0.2

-- Timing
local biteTimer = 0
local fishOnTimer = 0
local missTimer = 0
local inventoryPopupTimer = 0
local rippleTimer = 0
local moneyPopTimer = 0
local moneyPopDuration = 0.5
local depthShakeTimer = 0
local depthShakeDuration = 0.25
local depthShakeStrength = 1.5

-- Money
local money = 0

-- Fish Data
local fishTypes = {
    {name = "Arctic Char", chance = 0.45, minWeight = 2.3, maxWeight = 4.5},
    {name = "Capelin", chance = 0.25, minWeight = 6.5, maxWeight = 11.0},
    {name = "Polar Cod", chance = 0.20, minWeight = 9.5, maxWeight = 16.5},
    {name = "Halibut", chance = 0.10, minWeight = 13.5, maxWeight = 40.0}
}

local caughtFish = nil
local message = "Click and hold to drop your line!"
local lineMaxPixels = 170 -- Line Max

--Fonts
local defaultFont
local signFont

-- Input Hold Detection
local isHoldingDrop = false
local isHoldingReel = false

-- Inventory
local iceChest = {}
local isInventoryFull = false
local viewingChest = false
local viewingShop = false

function love.load()
    love.window.setMode(600, 900)
    love.window.setTitle("Arctic Fisher")
    defaultFont = love.graphics.newFont(14)
    signFont = love.graphics.newFont(28)
end

function love.update(dt)
    if viewingChest or viewingShop then return end
    
    if isInventoryFull then
        inventoryPopupTimer = inventoryPopupTimer - dt
        if inventoryPopupTimer <= 0 then
            isInventoryFull = false
        end
    end

    if isHoldingDrop and state == "idle" then
        state = "dropping"
        message = "Dropping the line..."
    end

    if isHoldingDrop and (state == "dropping" or state == "waiting") then
        depth = math.min(depth + dropSpeed * dt, maxDepth)
    elseif isHoldingReel and (state == "waiting" or state == "bite" or state == "reeling") then
        depth = math.max(depth - reelSpeed * dt, 0)
    end

    if state == "dropping" then
        if depth >= maxDepth then
            depth = maxDepth
            depthShakeTimer = depthShakeDuration
            startWaiting()
        end
    elseif state == "waiting" then
        biteTimer = biteTimer - dt
        if biteTimer <= 0 and depth > 0.5 then
            state = "bite"
            fishOnTimer = 2
            rippleTimer = 0
            message = "Bite! Reel it in!"
        end
    elseif state == "bite" then
        fishOnTimer = fishOnTimer - dt
        rippleTimer = rippleTimer + dt
        if fishOnTimer <= 0 then
            message = "The fish got away!"
            startWaiting()
        end
    elseif state == "reeling" then
        if depth <= 0 then
            depth = 0
            finalizeCatch()
        end
    elseif state == "missed" then
        missTimer = missTimer - dt
        if missTimer <= 0 then
            if depth >= 0.5 then
                startWaiting()
            else
                state = "idle"
                message = "Click and hold to drop your line!"
            end
        end
    end

    if depth <= 0 and not caughtFish and (not isHoldingDrop and not isHoldingReel) then
        if state ~= "reeling" then
            state = "idle"
            message = "Click and hold to drop your line!"
        end
    end
    
    --moneypop
    if moneyPopTimer > 0 then
        moneyPopTimer = moneyPopTimer - dt
    end

    --depth text shake
    if depthShakeTimer > 0 then
        depthShakeTimer = depthShakeTimer - dt
        if depthShakeTimer < 0 then
            depthShakeTimer = 0
        end
    end    
end

function love.draw()
    if viewingChest then
        drawIceChest()
        return
    end

    if viewingShop then
        drawTradingPost()
        return
    end

    -- Draw Arctic Horizon
    love.graphics.setColor(0.7, 0.9, 1.0)
    love.graphics.rectangle("fill", 0, 0, 600, 50)

    -- Draw Water Gradient 
    for y = 50, 900 do
        local t = (y - 50) / (900 - 50)
        local r = 0.0
        local g = 0.2 * (1 - t)
        local b = 0.4 * (1 - t)
        love.graphics.setColor(r, g, b)
        love.graphics.rectangle("fill", 0, y, 600, 1)
    end

    -- Draw Ice 
    love.graphics.setColor(0.7, 0.7, .7)
    love.graphics.rectangle("fill", 0, 47, 600, 8)

    --Draw Hole
    love.graphics.setColor(0, 0, 0) 
    love.graphics.ellipse("fill", 300, 52, 9, 3)

    -- Draw Fisher Man
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 285, 17, 30, 30)

    -- Draw Fishing Line
    local lineLength = (depth / maxDepth) * lineMaxPixels
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(2)
    love.graphics.line(300, 50, 300, 50 + lineLength)

    -- Draw Ripple Animation if bite
    if state == "bite" then
        local centerX = 300
        local centerY = 50 + lineLength
        local rippleRadius = 10 + (rippleTimer * 50) % 50

        love.graphics.setColor(0, 0.6, 1)
        love.graphics.circle("fill", centerX, centerY, 5)

        love.graphics.setColor(0, 0.6, 1, 1 - (rippleRadius / 50))
        love.graphics.setLineWidth(2)
        love.graphics.circle("line", centerX, centerY, rippleRadius)
    end

    -- Money Pop Effect
    local popScale = 1.0
    if moneyPopTimer > 0 then
    popScale = 1.0 + 0.5 * (moneyPopTimer / moneyPopDuration) -- bigger at start, shrinks back
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


    -- Draw Depth Text
    local depthX = 10
    local depthY = 30

    if depthShakeTimer > 0 then
        depthX = depthX + math.random(-depthShakeStrength, depthShakeStrength)
        depthY = depthY + math.random(-depthShakeStrength, depthShakeStrength)
    end

    -- Shadow
    love.graphics.setColor(0, 0, 0.1)
    love.graphics.print(string.format("Depth: %.1fm", depth), depthX + 1, depthY + 1)

    -- Main Text
    if depthShakeTimer > 0 then
        love.graphics.setColor(1, 0.3, 0.3) -- Red while shaking
    else
        love.graphics.setColor(1, 1, 1) -- Normal white
    end
        love.graphics.print(string.format("Depth: %.1fm", depth), depthX, depthY)

    -- Reset color after depth shake
    love.graphics.setColor(1, 1, 1)

    -- Draw Message
    love.graphics.printf(message, 0, 860, 600, "center")

    -- Draw Catch Text
    if caughtFish then
        love.graphics.printf(caughtFish, 0, 800, 600, "center")
    end

    if isInventoryFull then
        love.graphics.setColor(1, 0, 0)
        love.graphics.printf("Inventory Full!", 0, 400, 600, "center")
    end

    -- Shadow on Press "I" to open Icebox
    love.graphics.setColor(0, 0, 0.1)
    love.graphics.print("'I' open Icebox", 491, 11)

    -- Main text Press "I" to open Icebox
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("'I' open Icebox", 490, 10)

    -- Shadow on Press "P" to open Trading Post
    love.graphics.setColor(0, 0, 0.1)
    love.graphics.print("'P' open Trading Post", 456, 31)
    
    -- Main text Press "P" to open Trading Post
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("'P' open Trading Post", 455, 30)
    
end

--Which fish in icebox is selected
function anyFishSelected()
    for _, fish in ipairs(iceChest) do
        if fish.selected then
            return true
        end
    end
    return false
end


function love.mousepressed(x, y, button)
    if viewingChest then
        if button == 1 then
            local mx, my = x, y

            -- Check SELL BUTTON Click first
            if anyFishSelected() then
                local buttonX = 200
                local buttonY = 40
                local buttonWidth = 200
                local buttonHeight = 50

                if mx >= buttonX and mx <= buttonX + buttonWidth and my >= buttonY and my <= buttonY + buttonHeight then
                    -- Sell all selected fish
                    local total = 0
                    local newIceChest = {}
                    for _, fish in ipairs(iceChest) do
                        if fish.selected then
                            total = total + calculateFishValue(fish.name, fish.weight)
                        else
                            table.insert(newIceChest, fish)
                        end
                    end
                    iceChest = newIceChest
                    money = money + total
                    moneyPopTimer = moneyPopDuration
                    return -- don't check clicking slots if just sold
                end
            end

            -- Otherwise, Check if clicked inside a fish slot
            for i = 1, #iceChest do
                local slotX = 190
                local slotY = 120 + (i - 1) * 110
                local slotWidth = 220
                local slotHeight = 80

                if mx >= slotX and mx <= slotX + slotWidth and my >= slotY and my <= slotY + slotHeight then
                    if iceChest[i] then
                        iceChest[i].selected = not iceChest[i].selected
                    end
                end
            end
        end
        return
    end

    -- Otherwise, normal fishing behavior
    if button == 1 then
        if state == "caught" or state == "missed" then
            caughtFish = nil
            message = "Dropping the line..."
            depth = 0
            isHoldingDrop = true
            state = "dropping"
        else
            isHoldingDrop = true
        end
    elseif button == 2 then
        isHoldingReel = true
        if state == "bite" then
            state = "reeling"
            message = "Reeling in!"
        end
    end
end

function love.mousereleased(x, y, button)
    if viewingChest then return end

    if button == 1 then
        isHoldingDrop = false
        if depth >= 0.5 and state == "dropping" then
            startWaiting()
        end
    elseif button == 2 then
        isHoldingReel = false
        if state == "reeling" and depth > 0 then
            state = "missed"
            missTimer = 2
            message = "The fish slipped away!"
            caughtFish = nil
        end
    end
end

function love.keypressed(key)
    if key == "i" then
        viewingChest = not viewingChest
        viewingShop = false
        if viewingChest then
            message = ""
        else
            if state == "idle" then
                message = "Click and hold to drop your line!"
            end
        end
    elseif key == "p" then
        viewingShop = not viewingShop
        viewingChest = false
    end
end

-- Bite Timer
function startWaiting()
    biteTimer = math.random(2, 15)
    state = "waiting"
    message = "Waiting for a bite..."
end

function finalizeCatch()
    if state == "reeling" then
        if #iceChest >= 6 then
            isInventoryFull = true
            inventoryPopupTimer = 2
            message = "Inventory Full!"
            state = "waiting"
            return
        end

        local roll = math.random()
        local cumulative = 0
        for _, fish in ipairs(fishTypes) do
            cumulative = cumulative + fish.chance
            if roll <= cumulative then
                local weight = math.random() * (fish.maxWeight - fish.minWeight) + fish.minWeight
                caughtFish = string.format("Caught a %.1fkg %s!", weight, fish.name)
                table.insert(iceChest, {name = fish.name, weight = weight, selected = false})
                message = "Nice catch!"
                state = "caught"
                return
            end
        end

        caughtFish = "Caught a mystery fish!"
        message = "You caught something!"
        state = "caught"
    end
end

-- FISH VALUE
function calculateFishValue(name, weight)
    if name == "Arctic Char" then
        return 0.20 + 0.01 * weight
    elseif name == "Capelin" then
        return 0.40 + 0.01 * weight
    elseif name == "Polar Cod" then
        return 1.20 + 0.01 * weight
    elseif name == "Halibut" then
        return 2.50 + 0.01 * weight
    else
        return 0 -- unknown fish
    end
end


--ICE CHEST
function drawIceChest()
    
    -- Draw shadow behind cooler
    love.graphics.setColor(0.5, 0.6, 0.7, 0.5)
    love.graphics.rectangle("fill", 170 + 10, 100 + 10, 260, 700, 20, 20)

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

    if iceChest[i] then
        local fish = iceChest[i]
        local price = calculateFishValue(fish.name, fish.weight)

        -- Fish name and weight 
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(string.format("%s - %.1fkg", fish.name, fish.weight), slotX, slotY + 20, slotWidth, "center")

        -- Price 
        love.graphics.setColor(1.0, 0.75, 0.0)
        love.graphics.printf(string.format("($%.2f)", price), slotX, slotY + 45, slotWidth, "center")

        --Highlight if selected
        if fish.selected then
            love.graphics.setColor(1.0, 0.8, 0.3, 0.4) -- soft gold glow
            love.graphics.rectangle("fill", slotX, slotY, slotWidth, slotHeight, 10, 10)
        end
    end
    -- SELL BUTTON
if anyFishSelected() then
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

    -- Text
    love.graphics.setColor(0, 0, 0)
    love.graphics.setFont(defaultFont)
    love.graphics.printf("SELL SELECTED", buttonX, buttonY + 15, buttonWidth, "center")
end

    -- Draw Total Weight
    local totalWeight = 0
    for _, fish in ipairs(iceChest) do
        totalWeight = totalWeight + fish.weight
    end
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(string.format("Total Weight: %.1fkg", totalWeight), 190, 780)
end
end

-- DRAW TRADING POST
function drawTradingPost()
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

-- Main window
love.graphics.setColor(0.7, 0.8, 1)
love.graphics.rectangle("fill", 100, 180, 400, 415, 30, 30)

-- Window border outline
love.graphics.setColor(0.6, 0.7, 0.9)
love.graphics.setLineWidth(6)
love.graphics.rectangle("line", 100, 180, 400, 415, 30, 30)

    -- Driftwood Counter
    love.graphics.setColor(0.4, 0.25, 0.1)
    love.graphics.rectangle("fill", 50, 650, 500, 150, 20, 20)

    -- Upgrades
    local upgrades = {
        {name = "Line+ Upgrade", price = "$15"},
        {name = "Reel Upgrade", price = "$75"},
        {name = "Rod Upgrade", price = "$100"}
    }

    local slotWidth = 120
    local gap = (500 - (slotWidth * 3)) / 4
    for i = 0, 2 do
        local x = 50 + gap + i * (slotWidth + gap)
        local y = 680
        -- Slot Light Up on Hover
        local mx, my = love.mouse.getPosition()
        local hover = mx >= x and mx <= x + slotWidth and my >= y and my <= y + 100

        if hover then
            love.graphics.setColor(1.0, 0.8, 0.3)
        else
            love.graphics.setColor(0.8, 0.8, 0.7)
        end
        love.graphics.rectangle("fill", x, y, slotWidth, 100, 10, 10)

        -- Rope border
        love.graphics.setColor(0.6, 0.4, 0.2)
        love.graphics.setLineWidth(5)
        love.graphics.rectangle("line", x, y, slotWidth, 100, 10, 10)

        love.graphics.setColor(0, 0, 0)
        love.graphics.setFont(defaultFont)
        love.graphics.printf(upgrades[i + 1].name, x, y + 20, slotWidth, "center")
        love.graphics.printf(upgrades[i + 1].price, x, y + 50, slotWidth, "center")
    end

    -- Wooden Sign for Trading Post
    love.graphics.setColor(0.6, 0.4, 0.2)
    love.graphics.rectangle("fill", 150, 80, 300, 70, 20, 20)

    love.graphics.setColor(0.4, 0.25, 0.1)
    love.graphics.setFont(signFont)
    love.graphics.printf("Trading Post", 150, 100, 300, "center")
    love.graphics.setFont(defaultFont)
end
