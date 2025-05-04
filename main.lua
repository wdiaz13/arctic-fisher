-- main.lua

local fishing = require("scripts.fishing")
local fishdex = require("scripts.fishdex")
local ui = require("scripts.ui")
local shop = require("scripts.shop")

function love.load()
    love.window.setMode(600, 900)
    love.window.setTitle("Arctic Fisher")
    math.randomseed(os.time()) -- Seed the RNG with the current time
    math.random(); math.random(); math.random() -- Warm up the RNG
    ui.loadFonts()
    ui.initFish()
    fishing.load()
end

function love.update(dt)
    if fishdex.isChestOpen() or shop.isOpen() then
        -- Don't update fishing gameplay when viewing inventory/shop
        return
    end
    ui.update(dt)
    fishing.update(dt)
    fishdex.update(dt)
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
