-- scripts/ui.lua
local gamedata = require("scripts.gamedata")

local ui = {}

local schoolFish = {}
local snowParticles = {}
local deepCoral = {} -- Add coral system

local defaultFont
local signFont

-- load images
local tentImage = love.graphics.newImage("assets/environment/tent.png")

-- fire behind tent
local fire = {
    x = 300,  -- center behind tent
    y = 40,
    baseRadius = 3.5,
    flicker = 0,
    time = 0 
}

function ui.loadFonts()
    defaultFont = love.graphics.newFont(14)
    signFont = love.graphics.newFont(28)
    love.graphics.setFont(defaultFont)
end

-- Initialize school of fish
function ui.initFish()
    -- Surface fish (smaller, lighter) - extend down to 7m
    for i = 1, 15 do -- increased from 10
        local yPos = math.random(250, 1240) -- up to 7m depth (50 + 7*170 = 1240)
        table.insert(schoolFish, {
            x = math.random(-100, 600),
            y = yPos,
            originalY = yPos,
            speed = math.random(15, 25), -- SLOWER: was 20-40, now 15-25
            direction = math.random(0, 1) == 0 and -1 or 1,
            color = (math.random() < 0.1) and {.5, 0.2, 0.2} or {0.2, 0.3, 0.4},
            fishType = "surface",
            width = 5,
            height = 2
        })
    end
    
    -- Deep water fish (smaller, more numerous, 9-15m depth)
    for i = 1, 12 do -- increased from 6
        local yPos = math.random(1580, 2600) -- 9m to 15m depth (50 + 9*170 = 1580, 50 + 15*170 = 2600)
        table.insert(schoolFish, {
            x = math.random(-100, 600),
            y = yPos,
            originalY = yPos,
            speed = math.random(8, 18),
            direction = math.random(0, 1) == 0 and -1 or 1,
            color = (math.random() < 0.3) and {0.4, 0.1, 0.1} or {0.1, 0.15, 0.35}, -- 30% red, 70% dark blue
            fishType = "deep",
            width = 5, -- same size as surface fish
            height = 2  -- same size as surface fish
        })
    end
    
    -- Initialize deep coral (10-15m depth, static on sides) - DENSE EDGE COVERAGE
    for i = 1, 100 do -- increased to 100 for very dense coverage
        local side = math.random() < 0.5 and "left" or "right"
        local x = side == "left" and math.random(-40, 80) or math.random(520, 640) -- focused on edges
        local y = math.random(1750, 2600) -- 10m to 15m depth
        table.insert(deepCoral, {
            x = x,
            y = y,
            width = math.random(4, 18), -- smaller, more interconnected pieces
            height = math.random(20, 60), -- taller for better vertical coverage
            branches = math.random(4, 12), -- many branches for interconnection
            color = {0.12 + math.random() * 0.15, 0.03 + math.random() * 0.07, 0.2 + math.random() * 0.15}, -- more purple variation
            opacity = 0.2 + math.random() * 0.5 -- wider opacity range for layering effect
        })
    end
end

-- Function to spawn snowflakes
local function spawnSnowflake()
    table.insert(snowParticles, {
        x = math.random(-100, 600),
        y = -10,
        speedY = math.random(40, 70),
        drift = math.random(30, 60), -- wind drift left/right
        alpha = 1, -- opacity full
        size = math.random(1, 1.75) * 0.75 -- random size
    })
end

-- Function to get the current zone based on depth
local function getCurrentZone()
    local depth = gamedata.depth
    for _, zone in pairs(gamedata.fishPools) do
        if zone.minDepth and zone.maxDepth and depth >= zone.minDepth and depth <= zone.maxDepth then
            return zone.name
        end
    end
    return "Unknown Zone"
end

function ui.update(dt)
    -- schoolFish movement
    for _, fish in ipairs(schoolFish) do
        fish.x = fish.x + fish.speed * fish.direction * dt

        if fish.direction == 1 and fish.x > 650 then
            fish.x = -50
            fish.y = fish.originalY --restore original depth
        elseif fish.direction == -1 and fish.x < -50 then
            fish.x = 650
            fish.y = fish.originalY
        end
    end

    -- snowflake spawning
    for i = #snowParticles, 1, -1 do
        local p = snowParticles[i]
        p.x = p.x + p.drift * dt
        p.y = p.y + p.speedY * dt
    
        -- If it hits the ice layer, remove it
        if p.y > 50 then
            table.remove(snowParticles, i)
        end
    end
    -- snowflake spawn timer
    ui.snowSpawnTimer = (ui.snowSpawnTimer or 0) - dt
    if ui.snowSpawnTimer <= 0 then
        for i = 1, 2 do  -- spawn 2 flakes per tick
            spawnSnowflake()
        end
        ui.snowSpawnTimer = 0.035  -- speed of snowfall
    end

    fire.time = fire.time + dt
    fire.flicker = 1 + 0.15 * math.sin(fire.time * 2)

    -- Money display animation
    local diff = gamedata.money - gamedata.displayedMoney
    if math.abs(diff) > 0.01 then
        gamedata.displayedMoney = gamedata.displayedMoney + diff * dt * 16
    else
        gamedata.displayedMoney = gamedata.money
    end
end

-- WORLD SPACE: Elements that move with camera
function ui.drawBackground()
    -- night sky (extends far above for camera scrolling)
    love.graphics.setColor(0.10, 0.15, 0.22)
    love.graphics.rectangle("fill", 0, -2000, 600, 2050) -- extended upward for camera

    -- snowflakes (world space - will scroll with camera)
    for _, p in ipairs(snowParticles) do
        love.graphics.setColor(1, 1, 1, p.alpha)
        love.graphics.rectangle("fill", p.x, p.y, p.size or 1.3, p.size or 1.3)
    end    

    -- Water Gradient (extends deep for camera scrolling) - FASTER GRADIENT TO ALMOST BLACK
    local waterStartY = 50
    local waterEndY = 5000 -- much deeper for camera scrolling
    local pixelsPerMeter = 170 -- same as fishing module
    for y = waterStartY, waterEndY, 2 do -- step by 2 for performance
        -- Calculate depth in meters for gradient
        local depthInMeters = (y - waterStartY) / pixelsPerMeter
        local maxDepthForGradient = 5.0 -- gradient completes by 5m depth (much faster)
        local t = math.min(depthInMeters / maxDepthForGradient, 1.0)
        
        -- Gradient from blue (0.0, 0.1, 0.3) to almost black (0.0, 0.02, 0.08)
        local r = 0.0
        local g = 0.1 * (1 - t * 0.8) -- from 0.1 to 0.02
        local b = 0.3 * (1 - t * 0.73) -- from 0.3 to 0.08
        
        love.graphics.setColor(r, g, b)
        love.graphics.rectangle("fill", 0, y, 600, 2)
    end

    -- Deep coral (world space - static on sides, 10-15m depth)
    for _, coral in ipairs(deepCoral) do
        love.graphics.setColor(coral.color[1], coral.color[2], coral.color[3], coral.opacity)
        
        -- Draw main coral trunk
        love.graphics.rectangle("fill", coral.x, coral.y, coral.width * 0.3, coral.height)
        
        -- Draw coral branches
        for j = 1, coral.branches do
            local branchY = coral.y + (j / coral.branches) * coral.height * 0.8
            local branchLength = coral.width * (0.5 + math.random() * 0.5)
            local branchAngle = (j % 2 == 0) and -1 or 1
            
            -- Left/right branches
            love.graphics.rectangle("fill", 
                coral.x + coral.width * 0.15, 
                branchY, 
                branchLength * branchAngle, 
                2)
        end
    end

    -- School fish (world space - will scroll with camera)
    for _, fish in ipairs(schoolFish) do
        love.graphics.setColor(fish.color)
        if fish.fishType == "deep" then
            -- Draw deep fish (same size as surface now)
            love.graphics.rectangle("fill", fish.x, fish.y, fish.width, fish.height)
        else
            -- Draw regular surface fish
            love.graphics.rectangle("fill", fish.x, fish.y, fish.width or 5, fish.height or 2)
        end
    end    

    -- Ice layer (world space - will scroll out of view)
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.rectangle("fill", 0, 47, 600, 8)

    -- Fishing Hole (world space)
    love.graphics.setColor(0, 0, 0)
    love.graphics.ellipse("fill", 300, 52, 9, 3)

    -- Tent Fire (world space - will scroll out of view)
    -- core bright tungsten glow
    love.graphics.setColor(1.0, 0.7, 0.2, 0.9)
    love.graphics.circle("fill", fire.x, fire.y, fire.baseRadius * fire.flicker)
    -- outer soft red-orange halo
    love.graphics.setColor(1.0, 0.4, 0.1, 0.9)
    love.graphics.circle("fill", fire.x, fire.y, fire.baseRadius * 2 * fire.flicker)
    -- white-hot center
    love.graphics.setColor(1.0, 0.9, 0.6, 0.9)
    love.graphics.circle("fill", fire.x, fire.y + 5, fire.baseRadius * 0.5 * fire.flicker)

    -- Tent (world space - will scroll out of view)
    love.graphics.setColor(1, 1, 1)
    local scaleX = 43 / tentImage:getWidth()
    local scaleY = 43 / tentImage:getHeight()
    love.graphics.draw(tentImage, 279, 6, 0, scaleX, scaleY)

    -- Fishing Line (world space - moves with camera)
    local lineLength = (gamedata.depth / 1.0) * 170
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(1)
    love.graphics.line(300, 50, 300, 50 + lineLength)

    -- Ripple Effect (world space - if in bite state)
    if gamedata.state == "bite" then
        local centerX = 300
        local centerY = 50 + lineLength
        local rippleRadius = 10 + (gamedata.rippleTimer * 50) % 50

        love.graphics.setColor(0, 0.6, 1)
        love.graphics.circle("fill", centerX, centerY, 3.5)

        love.graphics.setColor(0, 0.6, 1, 1 - (rippleRadius / 35))
        love.graphics.setLineWidth(1)
        love.graphics.circle("line", centerX, centerY, rippleRadius)
    end
end

-- SCREEN SPACE: HUD elements that stay fixed regardless of camera
function ui.drawOverlay(depth, message, money, inventoryFull, caughtFish)
    -- Depth Text (screen space - always visible)
    local depthX = 10
    local depthY = 30

    if gamedata.depthShakeTimer and gamedata.depthShakeTimer > 0 then
        depthX = depthX + math.random(-gamedata.depthShakeStrength, gamedata.depthShakeStrength)
        depthY = depthY + math.random(-gamedata.depthShakeStrength, gamedata.depthShakeStrength)
    end

    -- Shadow
    love.graphics.setColor(0, 0, 0.1)
    love.graphics.print(string.format("Depth: %.1fm", gamedata.depth), depthX + 1, depthY + 1)

    -- Main Text
    if gamedata.depthShakeTimer and gamedata.depthShakeTimer > 0 then
        love.graphics.setColor(1, 0.3, 0.3)
    else
        love.graphics.setColor(1, 1, 1)
    end
    love.graphics.print(string.format("Depth: %.1fm", gamedata.depth), depthX, depthY)

    -- Reset color
    love.graphics.setColor(1, 1, 1)

    -- Message (screen space - always at bottom)
    love.graphics.printf(message, 0, 860, 600, "center")

    -- Catch Text (screen space)
    if caughtFish then
        love.graphics.printf(caughtFish, 0, 800, 600, "center")
    end

    -- Inventory Full Warning (screen space)
    if inventoryFull then
        love.graphics.setColor(1, 0, 0)
        love.graphics.printf("Inventory Full!", 0, 400, 600, "center")
    end

    -- Icebox Shortcut (screen space)
    love.graphics.setColor(0, 0, 0.1)
    love.graphics.print("'I' open Icebox", 491, 11)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("'I' open Icebox", 490, 10)

    -- Trading Post Shortcut (screen space)
    love.graphics.setColor(0, 0, 0.1)
    love.graphics.print("'P' open Trading Post", 447, 31)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("'P' open Trading Post", 446, 30)

    -- Zone indicator text (screen space)
    local zoneName = getCurrentZone()
    love.graphics.setColor(0.2, 0.3, 0.5) 
    love.graphics.printf(zoneName, 10, 860, 200, "left")

    -- Money overlay (screen space - always visible)
    ui.drawMoneyOverlay()
end

-- Money overlay in the top left corner (screen space)
function ui.drawMoneyOverlay()
    local money = gamedata.displayedMoney or 0

    love.graphics.setColor(0, 0, 0.1)
    love.graphics.print(string.format("$%.2f", money), 11, 11)

    love.graphics.setColor(1.0, 0.75, 0.0)
    love.graphics.print(string.format("$%.2f", money), 10, 10)
end

function ui.getDefaultFont()
    return defaultFont
end

return ui