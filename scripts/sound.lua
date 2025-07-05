-- scripts/sound.lua
local sound = {}
local sources = {}

function sound.load()
    --fishOn
    sources["fishOn"] = love.audio.newSource("assets/sounds/fish_on.wav", "static")
    sources["fishOn"]:setVolume(0.50)

    --maxDepth
    sources["maxDepth"] = love.audio.newSource("assets/sounds/max_depth.wav", "static")
    sources["maxDepth"]:setVolume(0.40)

    --fishSurface
    sources["fishSurface"] = love.audio.newSource("assets/sounds/fish_surface.wav", "static")
    sources["fishSurface"]:setVolume(0.40)

    --slippedAway
    sources["slippedAway"] = love.audio.newSource("assets/sounds/slipped_away.wav", "static")
    sources["slippedAway"]:setVolume(0.50)

    --inventoryFull
    sources["inventoryFull"] = love.audio.newSource("assets/sounds/inventory_full.wav", "static")
    sources["inventoryFull"]:setVolume(0.60)

    --lineUpgrade
    sources["lineUpgrade"] = love.audio.newSource("assets/sounds/line_upgrade.wav", "static")
    sources["lineUpgrade"]:setVolume(0.70)

    --reelUpgrade
    sources["reelUpgrade"] = love.audio.newSource("assets/sounds/reel_upgrade.wav", "static")
    sources["reelUpgrade"]:setVolume(0.70)

    --rodUpgrade
    sources["rodUpgrade"] = love.audio.newSource("assets/sounds/rod_upgrade.wav", "static")
    sources["rodUpgrade"]:setVolume(0.70)

    --icebox select sounds
    sources["select"] = {
    love.audio.newSource("assets/sounds/select_1.wav", "static"),
    love.audio.newSource("assets/sounds/select_2.wav", "static"),
    love.audio.newSource("assets/sounds/select_3.wav", "static"),
    love.audio.newSource("assets/sounds/select_4.wav", "static")
}
    --volume for icebox select sounds
    for _, s in ipairs(sources["select"]) do
    s:setVolume(0.70)
    end

    --sell sounds
    sources["sell"] = {
    love.audio.newSource("assets/sounds/sell_1.wav", "static"),
    love.audio.newSource("assets/sounds/sell_2.wav", "static"),
    love.audio.newSource("assets/sounds/sell_3.wav", "static"),
    love.audio.newSource("assets/sounds/sell_4.wav", "static")
}
    --volume for sell sounds
    for _, s in ipairs(sources["sell"]) do
    s:setVolume(0.90)
    end

    --ambient stream
    sources["ambientSurface"] = love.audio.newSource("assets/sounds/ambient_surface.wav", "stream")
    sources["ambientSurface"]:setLooping(true)
    sources["ambientSurface"]:setVolume(0.70)

    -- Add more sounds 
end

-- function to play a sound by name
function sound.play(name)
    local sfx = sources[name]
    if sfx then
        sfx:stop()
        sfx:play()
    end
end

-- function to stop a sound by name
function sound.stop(name)
    local sfx = sources[name]
    if sfx then
        sfx:stop()
    end
end

-- function to play a random sound from a group
function sound.playRandom(name)
    local group = sources[name]
    if group and type(group) == "table" then
        local sfx = group[math.random(#group)]
        if sfx then
            sfx:stop()
            sfx:play()
        end
    end
end

return sound
