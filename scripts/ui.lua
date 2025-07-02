-- scripts/ui.lua
local gamedata = require("scripts.gamedata")

local ui = {}

local schoolFish = {}
local snowParticles = {}

local defaultFont
local signFont

function ui.loadFonts()
    defaultFont = love.graphics.newFont(14)
    signFont = love.graphics.newFont(28)
    love.graphics.setFont(defaultFont)
end

function ui.initFish()

    for i = 1, 10 do
        local yPos = math.random(250, 750) -- random y position for each fish
        table.insert(schoolFish, {
            x = math.random(-100, 600),-- random x position
            y = yPos, -- random y position
            originalY = yPos, -- store original y position for depth
            speed = math.random(20, 40), -- random speed
            direction = math.random(0, 1) == 0 and -1 or 1, -- random direction
            color = (math.random() < 0.1) and {.5, 0.2, 0.2} or {0.2, 0.3, 0.4}
        })
    end
end

local function spawnSnowflake()
    table.insert(snowParticles, {
        x = math.random(-100, 600),
        y = -10,
        speedY = math.random(40, 70),
        drift = math.random(30, 60), -- wind drift left/right
        alpha = 1 -- opacity full
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
    spawnSnowflake()
    ui.snowSpawnTimer = 0.05 -- tweak this for faster/slower snow
end
    
    
end


function ui.drawBackground()
    -- Arctic Horizon
    love.graphics.setColor(0.7, 0.9, 1.0)
    love.graphics.rectangle("fill", 0, 0, 600, 50)

    -- snowflakes
    for _, p in ipairs(snowParticles) do
        love.graphics.setColor(1, 1, 1, p.alpha)
        love.graphics.rectangle("fill", p.x, p.y, 2, 2) -- flake size
    end    

    -- Water Gradient
    for y = 50, 900 do
        local t = (y - 50) / (900 - 50)
        local r = 0.0
        local g = 0.2 * (1 - t)
        local b = 0.4 * (1 - t)
        love.graphics.setColor(r, g, b)
        love.graphics.rectangle("fill", 0, y, 600, 1)
    end

    for _, fish in ipairs(schoolFish) do
        love.graphics.setColor(fish.color)
        love.graphics.rectangle("fill", fish.x, fish.y, 5, 2)
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
    local lineLength = (gamedata.depth / 1.0) * 170
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(1)
    love.graphics.line(300, 50, 300, 50 + lineLength)

    -- Ripple Effect (if in bite state)
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

    -- Money Pop Effect (not working yet)
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

    -- Zone indicator text
    local zoneName = getCurrentZone()
    love.graphics.setColor(0.2, 0.3, 0.5) 
    love.graphics.printf("Zone: " .. zoneName, 10, 860, 200, "left")
end

function ui.getDefaultFont()
    return defaultFont
end

return ui
