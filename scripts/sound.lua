-- scripts/sound.lua
local sound = {}
local sources = {}

function sound.load()
    sources["fishOn"] = love.audio.newSource("assets/sounds/fish_on.wav", "static")
    sources["fishOn"]:setVolume(0.50)

    sources["maxDepth"] = love.audio.newSource("assets/sounds/max_depth.wav", "static")
    sources["maxDepth"]:setVolume(0.30)

    sources["fishSurface"] = love.audio.newSource("assets/sounds/fish_surface.wav", "static")
    sources["fishSurface"]:setVolume(0.30)

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

return sound
