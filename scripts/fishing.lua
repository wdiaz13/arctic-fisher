-- scripts/fishing.lua
local gamedata = require("scripts.gamedata")
local sound = require("scripts.sound")

local fishing = {}

-- Fishing States
local state = "idle" -- 'idle', 'dropping', 'waiting', 'bite', 'reeling', 'caught', 'missed'

-- Line Properties
local depth = 0
local maxDepth = 1.0
local dropSpeed = 0.2
local reelSpeed = 0.2

-- Timers
local biteTimer = 0
local fishOnTimer = 0
local missTimer = 0
local inventoryPopupTimer = 0
local rippleTimer = 0
local depthShakeTimer = 0
local depthShakeDuration = 0.25
local depthShakeStrength = 1.5

-- Inputs
local isHoldingDrop = false
local isHoldingReel = false

-- Inventory and Catch
local caughtFish = nil
local biteDepth = nil
local message = "Click and hold to drop your line!"

function fishing.load()
end

function fishing.update(dt)
    if fishing.isInventoryFull() then
        inventoryPopupTimer = inventoryPopupTimer - dt
        if inventoryPopupTimer <= 0 then
            inventoryPopupTimer = 0
        end
    end

    if isHoldingDrop and state == "idle" then
        state = "dropping"
        message = "Dropping the line..."
    end

    if isHoldingDrop and (state == "dropping" or state == "waiting") then
        gamedata.depth = math.min(gamedata.depth + dropSpeed * dt, maxDepth)
    elseif isHoldingReel and (state == "waiting" or state == "bite" or state == "reeling") then
        gamedata.depth = math.max(gamedata.depth - reelSpeed * dt, 0)
    end

    if state == "dropping" and gamedata.depth >= maxDepth then
        gamedata.depth = maxDepth
        sound.play("maxDepth")
        depthShakeTimer = depthShakeDuration
        fishing.startWaiting()
    elseif state == "waiting" then
        biteTimer = biteTimer - dt
        if biteTimer <= 0 and gamedata.depth > 0.5 then
            state = "bite"
            fishOnTimer = 2
            rippleTimer = 0
            biteDepth = gamedata.depth
            message = "Bite! Reel it in!"
            sound.play("fishOn")
        end
    elseif state == "bite" then
        fishOnTimer = fishOnTimer - dt
        rippleTimer = rippleTimer + dt
        if fishOnTimer <= 0 then
            message = "The fish got away!"
            fishing.startWaiting()
            biteDepth = nil -- reset bite depth
        end
    elseif state == "reeling" and gamedata.depth <= 0 then
        gamedata.depth = 0
        fishing.finalizeCatch()
    elseif state == "missed" then
        missTimer = missTimer - dt
        if missTimer <= 0 then
            if gamedata.depth >= 0.5 then
                fishing.startWaiting()
            else
                state = "idle"
                message = "Click and hold to drop your line!"
            end
        end
    end

    if gamedata.depth <= 0 and not caughtFish and (not isHoldingDrop and not isHoldingReel) and state ~= "reeling" then
        state = "idle"
        message = "Click and hold to drop your line!"
    end

    if depthShakeTimer > 0 then
        depthShakeTimer = depthShakeTimer - dt
        if depthShakeTimer < 0 then
            depthShakeTimer = 0
        end
    end
    gamedata.state = state
    gamedata.rippleTimer = rippleTimer
    gamedata.depthShakeTimer = depthShakeTimer
    gamedata.depthShakeStrength = depthShakeStrength
end

function fishing.draw()
    -- draw fishing elements if needed, moved to UI module
end

function fishing.mousepressed(x, y, button)
    if button == 1 then
        if state == "caught" or state == "missed" then
            caughtFish = nil
            message = "Dropping the line..."
            gamedata.depth = 0
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

function fishing.mousereleased(x, y, button)
    if button == 1 then
        isHoldingDrop = false
        if gamedata.depth >= 0.5 and state == "dropping" then
            fishing.startWaiting()
        end
    elseif button == 2 then
        isHoldingReel = false
        if state == "reeling" and gamedata.depth > 0 then
            state = "missed"
            sound.play("slippedAway")
            missTimer = 2
            message = "The fish slipped away!"
            caughtFish = nil
        end
    end
end

function fishing.startWaiting()
    biteTimer = math.random(2, 5)
    state = "waiting"
    message = "Waiting for a bite..."
end

function fishing.finalizeCatch()
    if state ~= "reeling" then return end

    if gamedata.iceChest and #gamedata.iceChest >= 6 then
        inventoryPopupTimer = 2
        message = "Inventory Full!"
        state = "waiting"
        biteDepth = nil -- reset bite depth
        return
    end

    local depth = biteDepth or gamedata.depth
    local selectedPool = nil

    for i = #gamedata.fishPools, 1, -1 do
        local zone = gamedata.fishPools[i] -- reverse loop lets zones overlap slightly without causing bugs
        if zone.minDepth and zone.maxDepth and depth >= zone.minDepth and depth <= zone.maxDepth then
            selectedPool = zone
            break
        end
    end

    if not selectedPool then
        print("No valid zone found for depth:", depth)
        message = "Nothing biting here..."
        state = "waiting"
        return
    end

    print("🎣 Using zone:", selectedPool.name, "at depth", depth)

    local roll = math.random()
    local cumulative = 0

    for _, fish in ipairs(selectedPool.fish) do
        cumulative = cumulative + fish.chance
        if roll <= cumulative then
            local weight = math.random() * (fish.maxWeight - fish.minWeight) + fish.minWeight
            caughtFish = string.format("Caught a %.1fkg %s!", weight, fish.name)
            table.insert(gamedata.iceChest, {name = fish.name, weight = weight, selected = false})
            sound.play("fishSurface")
            message = "Nice catch!"
            state = "caught"
            return
        end
    end

    -- fallback
    caughtFish = "Caught a mystery fish!"
    message = "You caught something!"
    state = "caught"
end


-- Getter functions for UI
function fishing.getDepth()
    return gamedata.depth
end

function fishing.getMessage()
    return message
end

function fishing.getMoney()
    return gamedata.money or 0
end

function fishing.getCaughtFish()
    return caughtFish
end

function fishing.isInventoryFull()
    return inventoryPopupTimer > 0
end

function fishing.increaseMaxDepth(amount)
    maxDepth = maxDepth + (amount or 1)
end

function fishing.increaseReelSpeed(factor)
    dropSpeed = dropSpeed * (factor or 2)
    reelSpeed = reelSpeed * (factor or 2)
end

return fishing
