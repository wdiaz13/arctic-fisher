-- main.lua
local fishing = require("scripts.fishing")
local fishdex = require("scripts.fishdex")
local ui = require("scripts.ui")
local shop = require("scripts.shop")
local sound = require("scripts.sound")
local ancientFont = love.graphics.newFont("assets/fonts/first-order.ttf", 14)

-- opening tag variables
local openingTagTimer = 10 -- 5s full + 5s fade out
local openingTagAlpha = 1
local isOpeningTagDone = false
local openingSnow = {}
local openingSnowSpawnTimer = 0


function love.load()
    love.window.setMode(600, 900)
    love.window.setTitle("Arctic Fisher")
    math.randomseed(os.time()) -- Seed the RNG with the current time
    math.random(); math.random(); math.random() -- Warm up the RNG
    ui.loadFonts()
    ui.initFish()
    fishing.load()
    sound.load()
    sound.play("ambientSurface")

    -- pre-fill the screen with snow for the opening tag
    for i = 1, 150 do
        table.insert(openingSnow, {
            x = math.random(-400, 800),
            y = math.random(-200, 900),
            speedY = math.random(60, 120),
            drift = math.random(40, 80),
            size = math.random(1, 2)
        })
    end
end

function love.update(dt)
    if not fishdex.isChestOpen() and not shop.isOpen() then
    fishing.update(dt)
    end

    ui.update(dt)
    fishdex.update(dt)

    -- opening tag logic
    if not isOpeningTagDone then
    openingTagTimer = openingTagTimer - dt
    if openingTagTimer <= 5 then
        openingTagAlpha = openingTagTimer / 5  -- fades from 1 → 0
    end
    if openingTagTimer <= 0 then
        isOpeningTagDone = true
        love.graphics.setFont(love.graphics.newFont(14))
    end
    
    -- snow spawn for opening tag
    openingSnowSpawnTimer = openingSnowSpawnTimer - dt
        if openingSnowSpawnTimer <= 0 then
            table.insert(openingSnow, {
                x = math.random(-400, 800),
                y = -20,
                speedY = math.random(60, 120),
                drift = math.random(40, 80),
                size = math.random(1, 2)
            })
            openingSnowSpawnTimer = 0.05
        end

        for i = #openingSnow, 1, -1 do
            local p = openingSnow[i]
            p.x = p.x + p.drift * dt
            p.y = p.y + p.speedY * dt
            if p.y > 900 then table.remove(openingSnow, i) end
        end
    return  -- block game input/logic during opening tag
    end
end

function love.draw()
    if fishdex.isChestOpen() then
        fishdex.drawChest()
    elseif shop.isOpen() then
        shop.draw()
    else
        ui.drawBackground()
        fishing.draw() -- optional, in case you add fishing-specific drawing
        ui.drawOverlay(
            fishing.getDepth(),
            fishing.getMessage(),
            fishing.getMoney(),
            fishing.isInventoryFull(),
            fishing.getCaughtFish()
        )
    end

    -- draw opening tag 
    if not isOpeningTagDone then

    -- Fade background
    love.graphics.setColor(0, 0, 0, openingTagAlpha)
    love.graphics.rectangle("fill", 0, 0, 600, 900)

    -- Draw snow
    for _, p in ipairs(openingSnow) do
        love.graphics.setColor(1, 1, 1, openingTagAlpha)
        love.graphics.rectangle("fill", p.x, p.y, p.size, p.size)
    end


    -- Draw title text
    local defaultFont = ui.getDefaultFont()
    love.graphics.setFont(defaultFont)

    local y = 430
    local alpha = openingTagAlpha

    local part1 = "Deep under the Arctic crust, the "
    local part2 = "old world"
    local part3 = " stirs."

    local totalWidth = defaultFont:getWidth(part1) + ancientFont:getWidth(part2) + defaultFont:getWidth(part3)
    local x = (600 - totalWidth) / 2

    -- part1
    love.graphics.setColor(1, 1, 1, alpha)
    love.graphics.setFont(defaultFont)
    love.graphics.print(part1, x, y)

    -- part2 (light blue, ancient font)
    x = x + defaultFont:getWidth(part1)
    love.graphics.setFont(ancientFont)
    love.graphics.setColor(0.8, 0.9, 1.0, alpha)
    love.graphics.print(part2, x, y)

    -- part3
    x = x + ancientFont:getWidth(part2)
    love.graphics.setFont(defaultFont)
    love.graphics.setColor(1, 1, 1, alpha)
    love.graphics.print(part3, x, y)


    return
end
end

function love.mousepressed(x, y, button)
    if fishdex.isChestOpen() then
        fishdex.mousepressed(x, y, button)
    elseif shop.isOpen() then
        shop.mousepressed(x, y, button)
    else
        fishing.mousepressed(x, y, button)
    end
end

function love.mousereleased(x, y, button)
    if not (fishdex.isChestOpen() or shop.isOpen()) then
        fishing.mousereleased(x, y, button)
    end
end

function love.keypressed(key)
    if key == "i" then
        fishdex.toggleChest()
    elseif key == "p" then
        shop.toggleShop()
    end
end
