-- Poker hand definitions with base chips, mult, and leveling
-- Extracted from Balatro source

local M = {}

-- Hand type definitions with base values and level-up bonuses
M.HANDS = {
    ["High Card"] = {
        order = 12,
        base_chips = 5,
        base_mult = 1,
        level_chips = 10,
        level_mult = 1,
        min_cards = 1,
        example = {5}
    },
    ["Pair"] = {
        order = 11,
        base_chips = 10,
        base_mult = 2,
        level_chips = 15,
        level_mult = 1,
        min_cards = 2,
        example = {2, 2}
    },
    ["Two Pair"] = {
        order = 10,
        base_chips = 20,
        base_mult = 2,
        level_chips = 20,
        level_mult = 1,
        min_cards = 4,
        example = {2, 2, 3, 3}
    },
    ["Three of a Kind"] = {
        order = 9,
        base_chips = 30,
        base_mult = 3,
        level_chips = 20,
        level_mult = 2,
        min_cards = 3,
        example = {3, 3, 3}
    },
    ["Straight"] = {
        order = 8,
        base_chips = 30,
        base_mult = 4,
        level_chips = 30,
        level_mult = 3,
        min_cards = 5,
        example = {2, 3, 4, 5, 6}
    },
    ["Flush"] = {
        order = 7,
        base_chips = 35,
        base_mult = 4,
        level_chips = 15,
        level_mult = 2,
        min_cards = 5,
        example = {"H", "H", "H", "H", "H"}
    },
    ["Full House"] = {
        order = 6,
        base_chips = 40,
        base_mult = 4,
        level_chips = 25,
        level_mult = 2,
        min_cards = 5,
        example = {3, 3, 3, 2, 2}
    },
    ["Four of a Kind"] = {
        order = 5,
        base_chips = 60,
        base_mult = 7,
        level_chips = 30,
        level_mult = 3,
        min_cards = 4,
        example = {4, 4, 4, 4}
    },
    ["Straight Flush"] = {
        order = 4,
        base_chips = 100,
        base_mult = 8,
        level_chips = 40,
        level_mult = 4,
        min_cards = 5,
        example = {"5H", "6H", "7H", "8H", "9H"}
    },
    ["Five of a Kind"] = {
        order = 3,
        base_chips = 120,
        base_mult = 12,
        level_chips = 35,
        level_mult = 3,
        min_cards = 5,
        example = {5, 5, 5, 5, 5},
        requires_enhancement = true
    },
    ["Flush House"] = {
        order = 2,
        base_chips = 140,
        base_mult = 14,
        level_chips = 40,
        level_mult = 4,
        min_cards = 5,
        example = {"3H", "3H", "3H", "2H", "2H"},
        requires_enhancement = true
    },
    ["Flush Five"] = {
        order = 1,
        base_chips = 160,
        base_mult = 16,
        level_chips = 50,
        level_mult = 3,
        min_cards = 5,
        example = {"5H", "5H", "5H", "5H", "5H"},
        requires_enhancement = true
    }
}

-- Ordered list for display
M.HAND_ORDER = {
    "Flush Five",
    "Flush House", 
    "Five of a Kind",
    "Straight Flush",
    "Four of a Kind",
    "Full House",
    "Flush",
    "Straight",
    "Three of a Kind",
    "Two Pair",
    "Pair",
    "High Card"
}

-- Rank values for scoring
M.RANK_VALUES = {
    ["2"] = 2, ["3"] = 3, ["4"] = 4, ["5"] = 5, ["6"] = 6,
    ["7"] = 7, ["8"] = 8, ["9"] = 9, ["10"] = 10,
    ["J"] = 10, ["Q"] = 10, ["K"] = 10, ["A"] = 11
}

-- Rank order for straights (Ace can be high or low)
M.RANK_ORDER = {
    ["A"] = 14, ["K"] = 13, ["Q"] = 12, ["J"] = 11, ["10"] = 10,
    ["9"] = 9, ["8"] = 8, ["7"] = 7, ["6"] = 6, ["5"] = 5,
    ["4"] = 4, ["3"] = 3, ["2"] = 2
}

-- Suits
M.SUITS = {"Hearts", "Diamonds", "Clubs", "Spades"}

-- Get chips and mult for a hand at a given level
function M.getHandValue(handName, level)
    level = level or 1
    local hand = M.HANDS[handName]
    if not hand then return 0, 0 end
    
    local chips = hand.base_chips + (level - 1) * hand.level_chips
    local mult = hand.base_mult + (level - 1) * hand.level_mult
    
    return chips, mult
end

return M

