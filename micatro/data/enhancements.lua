-- Card enhancement definitions
-- Extracted from Balatro source P_CENTERS

local M = {}

M.ENHANCEMENTS = {
    m_bonus = {
        key = "m_bonus",
        name = "Bonus Card",
        set = "Enhanced",
        order = 2,
        pos = {x = 1, y = 1},
        effect = "Bonus Card",
        config = {
            bonus = 30  -- +30 chips
        },
        description = "+30 Chips"
    },
    
    m_mult = {
        key = "m_mult",
        name = "Mult Card",
        set = "Enhanced",
        order = 3,
        pos = {x = 2, y = 1},
        effect = "Mult Card",
        config = {
            mult = 4  -- +4 mult
        },
        description = "+4 Mult"
    },
    
    m_wild = {
        key = "m_wild",
        name = "Wild Card",
        set = "Enhanced",
        order = 4,
        pos = {x = 3, y = 1},
        effect = "Wild Card",
        config = {},
        description = "Can be used as any suit"
    },
    
    m_glass = {
        key = "m_glass",
        name = "Glass Card",
        set = "Enhanced",
        order = 5,
        pos = {x = 5, y = 1},
        effect = "Glass Card",
        config = {
            Xmult = 2,      -- x2 mult
            extra = 4       -- 1 in 4 chance to destroy
        },
        description = "x2 Mult, 1 in 4 chance to destroy"
    },
    
    m_steel = {
        key = "m_steel",
        name = "Steel Card",
        set = "Enhanced",
        order = 6,
        pos = {x = 6, y = 1},
        effect = "Steel Card",
        config = {
            h_x_mult = 1.5  -- x1.5 mult while in hand
        },
        description = "x1.5 Mult while this card stays in hand"
    },
    
    m_stone = {
        key = "m_stone",
        name = "Stone Card",
        set = "Enhanced",
        order = 7,
        pos = {x = 5, y = 0},
        effect = "Stone Card",
        config = {
            bonus = 50  -- +50 chips, no rank or suit
        },
        description = "+50 Chips, no rank or suit"
    },
    
    m_gold = {
        key = "m_gold",
        name = "Gold Card",
        set = "Enhanced",
        order = 8,
        pos = {x = 6, y = 0},
        effect = "Gold Card",
        config = {
            h_dollars = 3  -- $3 if in hand at end of round
        },
        description = "$3 if this card is held in hand at end of round"
    },
    
    m_lucky = {
        key = "m_lucky",
        name = "Lucky Card",
        set = "Enhanced",
        order = 9,
        pos = {x = 4, y = 1},
        effect = "Lucky Card",
        config = {
            mult = 20,      -- 1 in 5 chance for +20 mult
            p_dollars = 20  -- 1 in 15 chance for $20
        },
        description = "1 in 5 chance for +20 Mult, 1 in 15 chance for $20"
    }
}

-- Get enhancement by key
function M.get(key)
    return M.ENHANCEMENTS[key]
end

-- Get all enhancements as an ordered list
function M.getAll()
    local list = {}
    for key, enhancement in pairs(M.ENHANCEMENTS) do
        table.insert(list, enhancement)
    end
    table.sort(list, function(a, b) return a.order < b.order end)
    return list
end

return M

