-- Card seal definitions
-- Extracted from Balatro source P_SEALS

local M = {}

M.SEALS = {
    Gold = {
        key = "Gold",
        name = "Gold Seal",
        order = 1,
        set = "Seal",
        config = {
            dollars = 3  -- Earn $3 when played
        },
        description = "Earn $3 when this card is played and scores"
    },
    
    Red = {
        key = "Red",
        name = "Red Seal",
        order = 2,
        set = "Seal",
        config = {
            retrigger = 1  -- Retrigger this card
        },
        description = "Retrigger this card"
    },
    
    Blue = {
        key = "Blue",
        name = "Blue Seal",
        order = 3,
        set = "Seal",
        config = {
            planet = true  -- Create planet card if held at end of round
        },
        description = "Creates the Planet card for final played poker hand if held in hand at end of round"
    },
    
    Purple = {
        key = "Purple",
        name = "Purple Seal",
        order = 4,
        set = "Seal",
        config = {
            tarot = true  -- Create tarot card when discarded
        },
        description = "Creates a Tarot card when discarded (must have room)"
    }
}

-- Get seal by key
function M.get(key)
    return M.SEALS[key]
end

-- Get all seals as an ordered list
function M.getAll()
    local list = {}
    for key, seal in pairs(M.SEALS) do
        table.insert(list, seal)
    end
    table.sort(list, function(a, b) return a.order < b.order end)
    return list
end

return M

