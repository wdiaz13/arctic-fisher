-- scripts/sound.lua
local sound = {}
local sources = {}

function sound.load()
    sources["fishOn"] = love.audio.newSource("assets/sounds/fish_on.wav", "static")
    -- Add more sounds here
end

function sound.play(name)
    local sfx = sources[name]
    if sfx then
        sfx:stop()
        sfx:play()
    end
end

return sound
