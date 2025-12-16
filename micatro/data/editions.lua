-- Card edition definitions
-- Extracted from Balatro source P_CENTERS

local M = {}

M.EDITIONS = {
    e_base = {
        key = "e_base",
        name = "Base",
        order = 1,
        pos = {x = 0, y = 0},
        set = "Edition",
        config = {},
        shader = nil,
        description = "No edition"
    },
    
    e_foil = {
        key = "e_foil",
        name = "Foil",
        order = 2,
        pos = {x = 0, y = 0},
        set = "Edition",
        config = {
            extra = 50  -- +50 chips
        },
        shader = "foil",
        description = "+50 Chips"
    },
    
    e_holo = {
        key = "e_holo",
        name = "Holographic",
        order = 3,
        pos = {x = 0, y = 0},
        set = "Edition",
        config = {
            extra = 10  -- +10 mult
        },
        shader = "holographic",
        description = "+10 Mult"
    },
    
    e_polychrome = {
        key = "e_polychrome",
        name = "Polychrome",
        order = 4,
        pos = {x = 0, y = 0},
        set = "Edition",
        config = {
            extra = 1.5  -- x1.5 mult
        },
        shader = "polychrome",
        description = "x1.5 Mult"
    },
    
    e_negative = {
        key = "e_negative",
        name = "Negative",
        order = 5,
        pos = {x = 0, y = 0},
        set = "Edition",
        config = {
            extra = 1  -- +1 Joker slot
        },
        shader = "negative",
        description = "+1 Joker Slot"
    }
}

-- Shop costs for editions on jokers
M.EDITION_COSTS = {
    e_foil = 2,        -- +$2 to joker cost
    e_holo = 3,        -- +$3 to joker cost
    e_polychrome = 5,  -- +$5 to joker cost
    e_negative = 5     -- +$5 to joker cost
}

-- Get edition by key
function M.get(key)
    return M.EDITIONS[key]
end

-- Get all editions as an ordered list
function M.getAll()
    local list = {}
    for key, edition in pairs(M.EDITIONS) do
        table.insert(list, edition)
    end
    table.sort(list, function(a, b) return a.order < b.order end)
    return list
end

return M

