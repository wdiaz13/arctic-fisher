-- scripts/shop.lua
local gamedata = require("scripts.gamedata")
local fishing = require("scripts.fishing") -- modify maxdepth
local sound = require("scripts.sound")
local ui = require("scripts.ui")

local shop = {}

local viewingShop = false

local upgrades = {
    {name = "Line+ Upgrade", price = 5, purchased = false},
    {name = "Reel Upgrade", price = 25, purchased = false},
    {name = "Rod Upgrade", price = 60, purchased = false},
}

local lineUpgradeLevel = 0
local reelUpgradeLevel = 0
local rodUpgradeLevel = 0

-- Fireplace animation system
local fireplace = {
    x = 300,  -- center of window
    y = 380,  -- inside the room
    baseRadius = 8,
    flicker = 0,
    time = 0 
}

local function getLineUpgradePrice()
    --(doubles each time)
    return 5 * (2 ^ lineUpgradeLevel)
end

local function getReelUpgradePrice()
    --(doubles each time)
    return 25 * (2 ^ reelUpgradeLevel)
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
    -- Igloo Ice Block Background (darker for nighttime) - CLEAN, NO FLICKERING
    local blockWidth = 100
    local blockHeight = 60
    for y = 0, 900, blockHeight do
        local offset = (y / blockHeight) % 2 == 0 and 0 or blockWidth / 2
        for x = -offset, 600, blockWidth do
            -- Clean weathered ice blocks (no random flickering)
            love.graphics.setColor(0.6, 0.7, 0.8) -- consistent color
            love.graphics.rectangle("fill", x, y, blockWidth - 4, blockHeight - 4, 8, 8)
            
            -- Clean borders
            love.graphics.setColor(0.5, 0.6, 0.7)
            love.graphics.setLineWidth(2)
            love.graphics.rectangle("line", x, y, blockWidth - 4, blockHeight - 4, 8, 8)
        end
    end

    -- Window Shadow (extended just a bit more)
    love.graphics.setColor(0.4, 0.4, 0.5, 0.6)
    love.graphics.rectangle("fill", 105, 185, 400, 490, 30, 30) -- extended from 485 to 490

    -- Main Window (FINAL extension for perfect connection)
    love.graphics.setColor(0.65, 0.75, 0.95)
    love.graphics.rectangle("fill", 100, 180, 400, 490, 30, 30, 30, 30) -- extended from 485 to 490

    -- Window Border Outline (final extension)
    love.graphics.setColor(0.5, 0.6, 0.8)
    love.graphics.setLineWidth(6)
    love.graphics.rectangle("line", 100, 180, 400, 490, 30, 30, 30, 30) -- extended from 485 to 490
    
    -- Window frost/condensation marks
    love.graphics.setColor(0.7, 0.8, 0.9, 0.3)
    love.graphics.circle("fill", 150, 250, 8) -- breath mark
    love.graphics.circle("fill", 420, 320, 6) -- another breath mark
    love.graphics.rectangle("fill", 200, 190, 30, 2) -- frost line
    love.graphics.rectangle("fill", 350, 580, 40, 2) -- bottom frost

    -- INTERIOR ROOM VIEW (fills final window)
    -- Dark cozy room background (much darker and moodier)
    love.graphics.setColor(0.08, 0.06, 0.04)
    love.graphics.rectangle("fill", 106, 186, 388, 478, 25, 25) -- extended height to match final window
    
    -- Atmospheric depth gradient (darker toward edges)
    for i = 0, 40 do
        local alpha = (40 - i) / 40 * 0.3
        love.graphics.setColor(0, 0, 0, alpha)
        love.graphics.rectangle("fill", 106 + i, 186 + i, 388 - i*2, 478 - i*2, 25, 25) -- extended height
    end
    
    -- Stone fireplace back wall (darker)
    love.graphics.setColor(0.18, 0.15, 0.12)
    love.graphics.rectangle("fill", 180, 186, 240, 300) -- tall back wall
    
    -- Main fireplace structure (raised up to be right below black opening)
    love.graphics.setColor(0.25, 0.20, 0.15)
    love.graphics.rectangle("fill", 200, 420, 200, 60) -- raised base, shorter height
    love.graphics.rectangle("fill", 220, 280, 160, 70) -- fireplace body
    
    -- Fireplace opening/hearth (smaller, above the new black rectangle)
    love.graphics.setColor(0.05, 0.03, 0.02)
    love.graphics.rectangle("fill", 240, 300, 120, 40) -- smaller opening
    
    -- BLACK FIREPLACE OPENING (moved to red rectangle area)
    love.graphics.setColor(0.01, 0.01, 0.01)
    love.graphics.rectangle("fill", 220, 420, 160, 70) -- moved down to red rectangle area
    
    -- HEARTH BOTTOM (lighter rectangle at bottom of hearth)
    love.graphics.setColor(0.15, 0.12, 0.08)
    love.graphics.rectangle("fill", 230, 470, 140, 15) -- moved down with hearth
    
    -- FIREWOOD (moved down to new hearth bottom)
    love.graphics.setColor(0.15, 0.08, 0.04)
    -- Log 1 (horizontal, on new hearth bottom)
    love.graphics.rectangle("fill", 270, 477, 30, 6, 3, 3)
    love.graphics.rectangle("fill", 285, 480, 25, 5, 2, 2)
    -- Log 2 (angled, on new hearth bottom)
    love.graphics.push()
    love.graphics.translate(280, 475)
    love.graphics.rotate(0.2)
    love.graphics.rectangle("fill", 0, 0, 20, 4, 2, 2)
    love.graphics.pop()
    
    -- Log end details (rings)
    love.graphics.setColor(0.10, 0.05, 0.02)
    love.graphics.circle("fill", 275, 480, 3)
    love.graphics.circle("fill", 290, 482, 2.5)
    
    -- FIRE (moved down to new hearth bottom, above logs)
    local fireX = 300 -- center of hearth
    local fireY = 475 -- on the new hearth bottom above logs
    
    -- Main flame 
    love.graphics.setColor(1.0, 0.4, 0.1, 0.8)
    love.graphics.ellipse("fill", fireX, fireY, 12 * fireplace.flicker, 18 * fireplace.flicker)
    
    -- Inner flame
    love.graphics.setColor(1.0, 0.7, 0.2, 0.9)
    love.graphics.ellipse("fill", fireX, fireY + 2, 8 * fireplace.flicker, 12 * fireplace.flicker)
    
    -- Hot core
    love.graphics.setColor(1.0, 0.9, 0.6, 0.9)
    love.graphics.ellipse("fill", fireX, fireY + 4, 4 * fireplace.flicker, 6 * fireplace.flicker)
    
    -- Fire glow on surrounding area
    love.graphics.setColor(1.0, 0.3, 0.1, 0.2)
    love.graphics.ellipse("fill", fireX, fireY, 25, 30)
    
    -- BLACK GRATE (moved down to cover new hearth bottom area - WIDER)
    love.graphics.setColor(0.05, 0.05, 0.05)
    for i = 0, 6 do -- fewer bars to fit hearth bottom
        local barY = 468 + i * 4 -- moved down
        love.graphics.rectangle("fill", 230, barY, 140, 2) -- wider: from 130 to 140
    end
    -- Vertical grate supports
    for i = 0, 6 do -- one more support for wider grate
        local barX = 235 + i * 22
        love.graphics.rectangle("fill", barX, 468, 2, 20) -- vertical supports moved down
    end
    
    -- Stone brick details 
    love.graphics.setColor(0.20, 0.15, 0.10)
    for row = 0, 12 do 
        for col = 0, 9 do 
            local brickX = 185 + col * 24 + (row % 2) * 12
            local brickY = 190 + row * 18
            -- FIXED: Keep bricks within chimney boundaries (185-415 x, 190-420 y)
            if brickX >= 185 and brickX <= 390 and brickY >= 190 and brickY <= 400 then
                love.graphics.rectangle("fill", brickX, brickY, 20, 15, 1, 1)
                love.graphics.setColor(0.15, 0.10, 0.05)
                love.graphics.rectangle("line", brickX, brickY, 20, 15, 1, 1)
                love.graphics.setColor(0.20, 0.15, 0.10)
            end
        end
    end
    
    -- Stone arch (darker)
    love.graphics.setColor(0.30, 0.25, 0.20)
    for i = 0, 6 do
        local angle = (i / 6) * math.pi
        local archX = 300 + math.cos(angle) * 60
        local archY = 300 - math.sin(angle) * 30
        love.graphics.rectangle("fill", archX - 8, archY - 4, 16, 8, 2, 2)
    end
    
    -- Wooden mantle (lowered 15px)
    love.graphics.setColor(0.35, 0.20, 0.10)
    love.graphics.rectangle("fill", 210, 285, 180, 12, 3, 3) -- lowered from 270 to 285
    love.graphics.setColor(0.30, 0.15, 0.05)
    love.graphics.rectangle("line", 210, 285, 180, 12, 3, 3)
    
    -- Update fireplace animation
    local dt = love.timer.getDelta()
    fireplace.time = fireplace.time + dt
    fireplace.flicker = 1 + 0.15 * math.sin(fireplace.time * 6) + 0.1 * math.sin(fireplace.time * 12)
    
    -- Sparks
    love.graphics.setColor(1.0, 0.8, 0.3, 0.7 + 0.3 * math.sin(fireplace.time * 8))
    for i = 1, 8 do
        local sparkX = fireX + (math.sin(fireplace.time * 4 + i) * 15)
        local sparkY = fireY - 10 - (i * 2) - math.sin(fireplace.time * 6 + i) * 3 -- adjusted for new position
        local sparkSize = 0.5 + math.sin(fireplace.time * 10 + i) * 0.5
        love.graphics.circle("fill", sparkX, sparkY, sparkSize)
    end
    
    -- Additional sparks 
    love.graphics.setColor(1.0, 0.6, 0.1, 0.6)
    for i = 1, 4 do
        local crackleX = fireX + (math.random() - 0.5) * 20
        local crackleY = fireY + (math.random() - 0.5) * 8 -- adjusted range for new position
        love.graphics.circle("fill", crackleX, crackleY, 0.5 + math.random() * 0.5)
    end
    
    -- Trophy fish plaque above mantle
    love.graphics.setColor(0.40, 0.25, 0.15)
    love.graphics.rectangle("fill", 250, 220, 100, 40, 8, 8) -- much bigger: 100x40 instead of 60x25
    
    -- Plaque frame
    love.graphics.setColor(0.30, 0.15, 0.05)
    love.graphics.setLineWidth(3) -- thicker frame
    love.graphics.rectangle("line", 250, 220, 100, 40, 8, 8)
    
    -- Trophy fish 
    love.graphics.setColor(0.10, 0.10, 0.10)
    love.graphics.ellipse("fill", 298, 240, 35, 12) -- moved 2px left: from 300 to 298
    love.graphics.polygon("fill", 333, 240, 343, 235, 343, 245) -- tail moved left
    love.graphics.polygon("fill", 273, 245, 283, 255, 293, 245) -- fin moved left
    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.circle("fill", 283, 238, 2.5) -- eye moved left
    
    -- Floor
    love.graphics.setColor(0.08, 0.06, 0.04) -- same as room background
    love.graphics.rectangle("fill", 106, 485, 388, 185, 0, 0, 25, 25) -- extended to final window bottom
    
    -- BROWN COUNTER AT BOTTOM (moved up inside window)
    love.graphics.setColor(0.35, 0.20, 0.10)
    love.graphics.rectangle("fill", 106, 600, 388, 50, 0, 0, 25, 25) -- moved up from 620 to 600
    
    -- Counter edge/trim (the bar the gear rests on)
    love.graphics.setColor(0.25, 0.15, 0.05)
    love.graphics.rectangle("fill", 106, 600, 388, 4) -- moved up from 620 to 600
    
    -- Atmospheric fog/depth effect overlay (extended to final window size)
    love.graphics.setColor(0.05, 0.05, 0.05, 0.4)
    love.graphics.rectangle("fill", 106, 186, 388, 478, 25, 25) -- extended to match final window

    -- Driftwood Counter 
    love.graphics.setColor(0.35, 0.18, 0.08) -- more weathered/darker wood
    love.graphics.rectangle("fill", 50, 650, 500, 150, 20, 20, 20, 20) -- all corners beveled to fit window
    
    -- Driftwood wear marks and scratches
    love.graphics.setColor(0.25, 0.12, 0.05)
    -- Deep scratches from years of use
    love.graphics.rectangle("fill", 80, 680, 40, 2) -- scratch 1
    love.graphics.rectangle("fill", 200, 690, 60, 1) -- scratch 2
    love.graphics.rectangle("fill", 350, 685, 30, 2) -- scratch 3
    love.graphics.rectangle("fill", 450, 695, 25, 1) -- scratch 4
    
    -- Worn edges where people lean
    love.graphics.setColor(0.28, 0.15, 0.06)
    love.graphics.rectangle("fill", 50, 650, 500, 8) -- top edge wear
    love.graphics.rectangle("fill", 100, 750, 300, 6) -- bottom center wear
    
    -- Stains and rings from mugs/bottles
    love.graphics.setColor(0.3, 0.15, 0.05, 0.6)
    love.graphics.circle("fill", 150, 700, 8) -- ring stain 1
    love.graphics.circle("fill", 300, 710, 6) -- ring stain 2
    love.graphics.circle("fill", 420, 695, 7) -- ring stain 3
    
    -- Counter edge reinforcement (worn metal strip)
    love.graphics.setColor(0.4, 0.4, 0.35) -- tarnished metal
    love.graphics.rectangle("fill", 50, 648, 500, 3)

    -- FISHING SPOOLS (on driftwood counter inside window)
    -- Spool 1 (left)
    love.graphics.setColor(0.4, 0.25, 0.15) -- more weathered wooden spool
    love.graphics.rectangle("fill", 150, 605, 16, 24, 3, 3) -- left area, lowered to rest on bar
    -- Worn edges on spool
    love.graphics.setColor(0.3, 0.2, 0.1)
    love.graphics.rectangle("fill", 149, 612, 2, 10) -- left wear
    love.graphics.rectangle("fill", 165, 614, 2, 8) -- right wear
    
    love.graphics.setColor(0.55, 0.45, 0.25) -- faded tan line
    love.graphics.rectangle("fill", 152, 611, 12, 12) -- wound line
    love.graphics.setColor(0.6, 0.5, 0.3)
    love.graphics.rectangle("fill", 153, 612, 10, 10) -- line highlight
    
    -- Spool 2 (center-left) - also weathered
    love.graphics.setColor(0.35, 0.25, 0.12)
    love.graphics.rectangle("fill", 200, 607, 18, 22, 3, 3) -- center-left area, lowered
    -- Chips and wear
    love.graphics.setColor(0.25, 0.18, 0.08)
    love.graphics.rectangle("fill", 199, 617, 3, 4) -- chip
    love.graphics.rectangle("fill", 216, 622, 3, 3) -- another chip
    
    love.graphics.setColor(0.35, 0.4, 0.45) -- very muted blue-gray line
    love.graphics.rectangle("fill", 202, 612, 14, 12)
    love.graphics.setColor(0.4, 0.45, 0.5)
    love.graphics.rectangle("fill", 203, 613, 12, 10)
    
    -- FISHING HOOKS (on driftwood counter inside window) - weathered and tarnished
    love.graphics.setColor(0.5, 0.5, 0.5) -- tarnished silver hooks
    love.graphics.setLineWidth(2)
    
    -- Hook 1 (slightly rusty) - center area
    love.graphics.setColor(0.45, 0.4, 0.35) -- rusty hook
    love.graphics.arc("line", "open", 270, 620, 4, 0, math.pi * 1.5)
    love.graphics.line(270, 616, 270, 610)
    
    -- Hook 2 (tarnished) - center-right area
    love.graphics.setColor(0.4, 0.4, 0.4)
    love.graphics.arc("line", "open", 300, 623, 3, 0.2, math.pi * 1.3)
    love.graphics.line(300, 620, 300, 615)
    
    -- Hook 3 (newer but used) - right area
    love.graphics.setColor(0.55, 0.55, 0.55)
    love.graphics.arc("line", "open", 330, 617, 4, 0.1, math.pi * 1.4)
    love.graphics.line(330, 613, 330, 607)
    
    -- Hook 4 (old and rusty) - center-left area
    love.graphics.setColor(0.4, 0.35, 0.3)
    love.graphics.arc("line", "open", 285, 627, 3, 0.3, math.pi * 1.2)
    love.graphics.line(285, 624, 285, 619)
    
    -- Hook 5 (bent slightly) - right-center area
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.arc("line", "open", 315, 613, 4, 0.2, math.pi * 1.5) -- slightly different angle
    love.graphics.line(315, 609, 314, 604) -- slightly bent shank
    
    -- TACKLE BOX (on driftwood counter inside window) - weathered and battle-worn
    love.graphics.setColor(0.2, 0.25, 0.2) -- more weathered green
    love.graphics.rectangle("fill", 380, 600, 50, 30, 4, 4) -- right area, lowered to rest on bar
    
    -- Scratches and wear marks on tackle box
    love.graphics.setColor(0.15, 0.2, 0.15)
    love.graphics.rectangle("fill", 385, 605, 15, 1) -- scratch 1
    love.graphics.rectangle("fill", 390, 615, 20, 1) -- scratch 2
    love.graphics.rectangle("fill", 410, 610, 8, 1) -- scratch 3
    
    -- Worn edges
    love.graphics.setColor(0.1, 0.15, 0.1)
    love.graphics.rectangle("fill", 380, 600, 3, 30) -- left edge wear
    love.graphics.rectangle("fill", 427, 605, 3, 20) -- right edge wear
    
    love.graphics.setColor(0.15, 0.2, 0.15)
    love.graphics.rectangle("line", 380, 600, 50, 30, 4, 4)
    
    -- Tackle box details (weathered)
    love.graphics.setColor(0.4, 0.4, 0.4) -- tarnished latch
    love.graphics.rectangle("fill", 401, 605, 8, 4) -- centered latch
    love.graphics.setColor(0.25, 0.25, 0.25) -- worn handle
    love.graphics.rectangle("fill", 400, 602, 12, 3, 1, 1)

    -- Upgrades
    local slotWidth = 120
    local gap = (500 - (slotWidth * 3)) / 4
    for i = 0, 2 do
        local x = 50 + gap + i * (slotWidth + gap)
        local y = 680

        local upgrade = upgrades[i + 1] 

        local mx, my = love.mouse.getPosition()
        local hover = mx >= x and mx <= x + slotWidth and my >= y and my <= y + 100

        -- Different styling for Rod Upgrade (coming soon)
        if i == 2 then -- Rod Upgrade
            love.graphics.setColor(0.6, 0.6, 0.5) -- grayed out
        elseif hover then
            love.graphics.setColor(1.0, 0.8, 0.3)
        else
            love.graphics.setColor(0.8, 0.8, 0.7)
        end
        love.graphics.rectangle("fill", x, y, slotWidth, 100, 10, 10)

        -- Rope Border
        if i == 2 then -- Rod Upgrade
            love.graphics.setColor(0.4, 0.3, 0.2) -- darker border for disabled
        else
            love.graphics.setColor(0.6, 0.4, 0.2)
        end
        love.graphics.setLineWidth(5)
        love.graphics.rectangle("line", x, y, slotWidth, 100, 10, 10)

        love.graphics.setColor(0, 0, 0)
        love.graphics.setFont(love.graphics.getFont())

        if i == 2 then -- Third slot - just "Coming Soon"
            love.graphics.printf("Coming", x, y + 35, slotWidth, "center")
            love.graphics.printf("Soon", x, y + 55, slotWidth, "center")
        else
            love.graphics.printf(upgrade.name, x, y + 20, slotWidth, "center")
            
            if upgrade.name == "Line+ Upgrade" then
                love.graphics.printf("$" .. tostring(getLineUpgradePrice()), x, y + 50, slotWidth, "center")
            elseif upgrade.name == "Reel Upgrade" then
                love.graphics.printf("$" .. tostring(getReelUpgradePrice()), x, y + 50, slotWidth, "center")
            end    
        end
    end

    -- Wooden Sign for Trading Post 
    -- Sign shadow (slightly offset)
    love.graphics.setColor(0.3, 0.2, 0.1, 0.6)
    love.graphics.rectangle("fill", 153, 83, 300, 70, 20, 20)
    
    -- Main weathered sign body (faded and worn)
    love.graphics.setColor(0.45, 0.25, 0.12) -- more weathered brown
    love.graphics.rectangle("fill", 150, 80, 300, 70, 20, 20)
    
    -- SIMPLIFIED wood grain (just one subtle line)
    love.graphics.setColor(0.35, 0.20, 0.08)
    love.graphics.rectangle("fill", 180, 115, 140, 1) -- single center grain line
    
    -- Weathered edges and cracks
    love.graphics.setColor(0.25, 0.15, 0.05)
    -- Left edge wear
    love.graphics.rectangle("fill", 150, 95, 8, 15)
    love.graphics.rectangle("fill", 152, 120, 6, 10)
    -- Right edge wear
    love.graphics.rectangle("fill", 442, 100, 8, 12)
    love.graphics.rectangle("fill", 440, 130, 10, 8)
    
    -- Rusty nail marks
    love.graphics.setColor(0.4, 0.2, 0.1)
    love.graphics.circle("fill", 170, 95, 2) -- top left nail
    love.graphics.circle("fill", 430, 95, 2) -- top right nail
    love.graphics.circle("fill", 170, 135, 2) -- bottom left nail
    love.graphics.circle("fill", 430, 135, 2) -- bottom right nail
    
    -- Rust stains from nails
    love.graphics.setColor(0.3, 0.15, 0.05, 0.6)
    love.graphics.rectangle("fill", 168, 97, 4, 8) -- rust stain 1
    love.graphics.rectangle("fill", 428, 97, 4, 6) -- rust stain 2
    
    -- Faded, worn text
    love.graphics.setColor(0.25, 0.15, 0.05) -- much darker, faded text
    love.graphics.setFont(love.graphics.newFont(32)) -- keep large font size
    love.graphics.printf("Trading Post", 150, 98, 300, "center") -- adjusted Y position slightly
    
    -- Text wear/fade effects
    love.graphics.setColor(0.35, 0.20, 0.08, 0.7) -- overlay for worn look
    love.graphics.rectangle("fill", 180, 108, 15, 3) -- worn spot on "T"
    love.graphics.rectangle("fill", 240, 112, 8, 2) -- worn spot on "a"
    love.graphics.rectangle("fill", 320, 110, 12, 3) -- worn spot on "P"
    
    love.graphics.setFont(love.graphics.newFont(14)) -- reset font

    ui.drawMoneyOverlay() -- money display
end

function shop.mousepressed(x, y, button)
    if button ~= 1 then return end

    local slotWidth = 120
    local gap = (500 - (slotWidth * 3)) / 4

    for i = 0, 2 do
        local slotX = 50 + gap + i * (slotWidth + gap)
        local slotY = 680 -- updated to match new position

        if x >= slotX and x <= slotX + slotWidth and y >= slotY and y <= slotY + 100 then
            -- Which upgrade?
            if i == 0 then -- Line Upgrade
                local price = getLineUpgradePrice()
                if gamedata.money >= price then
                    gamedata.money = gamedata.money - price
                    lineUpgradeLevel = lineUpgradeLevel + 1
                    fishing.increaseMaxDepth(1)
                    sound.play("lineUpgrade")
                end
            elseif i == 1 then -- Reel Upgrade
                local price = getReelUpgradePrice()
                if gamedata.money >= price then
                    gamedata.money = gamedata.money - price
                    reelUpgradeLevel = reelUpgradeLevel + 1
                    fishing.increaseReelSpeed(2) -- double it each time
                    sound.play("reelUpgrade")
                end
            -- Rod Upgrade (i == 2) - DO NOTHING, coming soon
            end
        end
    end
end

return shop