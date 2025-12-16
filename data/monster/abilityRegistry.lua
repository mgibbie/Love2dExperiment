-- Ability Registry
-- Centralized lookup for abilities with fail-safe fallbacks
-- Ensures missing abilities never crash the game

local abilities = require('data.monster.abilities')

local registry = {}

-- Safe fallback ability (no-op)
local FALLBACK_ABILITY = {
    name = "No Ability",
    id = "noability",
    description = "No effect",
    -- No triggers or effects
}

-- Ability definitions loaded from individual files
registry.data = abilities.data or {}

-- Get an ability by ID, returns fallback if missing
function registry.get(abilityId)
    if not abilityId then
        print("[WARN] AbilityRegistry.get() called with nil abilityId")
        return FALLBACK_ABILITY
    end

    -- Normalize ability ID (handle spaces, case)
    local normalizedId = string.lower(abilityId):gsub(" ", ""):gsub("-", "")

    local ability = registry.data[normalizedId]
    if ability then
        return ability
    end

    -- Log warning and return fallback
    print("[WARN] AbilityRegistry: Missing ability '" .. tostring(abilityId) .. "', using no-op fallback")
    return FALLBACK_ABILITY
end

-- Get all registered abilities (for validation/testing)
function registry.all()
    return registry.data
end

-- Check if an ability exists
function registry.has(abilityId)
    if not abilityId then return false end
    local normalizedId = string.lower(abilityId):gsub(" ", ""):gsub("-", "")
    return registry.data[normalizedId] ~= nil
end

-- Get count of registered abilities
function registry.count()
    local count = 0
    for _ in pairs(registry.data) do
        count = count + 1
    end
    return count
end

-- Register an ability (for future use when implementing abilities)
function registry.register(abilityId, abilityData)
    local normalizedId = string.lower(abilityId):gsub(" ", ""):gsub("-", "")
    registry.data[normalizedId] = abilityData
end

return registry

