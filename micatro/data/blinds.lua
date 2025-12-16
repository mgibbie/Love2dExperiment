-- Blind definitions including boss blinds
-- Extracted from Balatro source P_BLINDS

local M = {}

M.BLINDS = {
    -- Standard blinds
    bl_small = {
        key = "bl_small",
        name = "Small Blind",
        order = 1,
        dollars = 3,
        mult = 1,
        pos = {x = 0, y = 0},
        boss = false,
        debuff = {},
        description = ""
    },
    
    bl_big = {
        key = "bl_big",
        name = "Big Blind",
        order = 2,
        dollars = 4,
        mult = 1.5,
        pos = {x = 0, y = 1},
        boss = false,
        debuff = {},
        description = ""
    },
    
    -- Boss blinds
    bl_hook = {
        key = "bl_hook",
        name = "The Hook",
        order = 3,
        dollars = 5,
        mult = 2,
        pos = {x = 0, y = 7},
        boss = {min = 1, max = 10},
        boss_colour = {0.66, 0.25, 0.14},
        debuff = {},
        description = "Discards 2 random cards per hand played"
    },
    
    bl_ox = {
        key = "bl_ox",
        name = "The Ox",
        order = 4,
        dollars = 5,
        mult = 2,
        pos = {x = 0, y = 2},
        boss = {min = 6, max = 10},
        boss_colour = {0.73, 0.36, 0.03},
        debuff = {},
        description = "Playing a #1# sets money to $0"
    },
    
    bl_house = {
        key = "bl_house",
        name = "The House",
        order = 5,
        dollars = 5,
        mult = 2,
        pos = {x = 0, y = 3},
        boss = {min = 2, max = 10},
        boss_colour = {0.32, 0.52, 0.66},
        debuff = {},
        description = "First hand is drawn face down"
    },
    
    bl_wall = {
        key = "bl_wall",
        name = "The Wall",
        order = 6,
        dollars = 5,
        mult = 4,
        pos = {x = 0, y = 9},
        boss = {min = 2, max = 10},
        boss_colour = {0.54, 0.35, 0.65},
        debuff = {},
        description = "Extra large blind"
    },
    
    bl_wheel = {
        key = "bl_wheel",
        name = "The Wheel",
        order = 7,
        dollars = 5,
        mult = 2,
        pos = {x = 0, y = 10},
        boss = {min = 2, max = 10},
        boss_colour = {0.31, 0.75, 0.49},
        debuff = {},
        description = "1 in 7 cards get drawn face down"
    },
    
    bl_arm = {
        key = "bl_arm",
        name = "The Arm",
        order = 8,
        dollars = 5,
        mult = 2,
        pos = {x = 0, y = 11},
        boss = {min = 2, max = 10},
        boss_colour = {0.41, 0.40, 0.95},
        debuff = {},
        description = "Decrease level of played poker hand by 1"
    },
    
    bl_club = {
        key = "bl_club",
        name = "The Club",
        order = 9,
        dollars = 5,
        mult = 2,
        pos = {x = 0, y = 4},
        boss = {min = 1, max = 10},
        boss_colour = {0.73, 0.80, 0.57},
        debuff = {suit = "Clubs"},
        description = "All Club cards are debuffed"
    },
    
    bl_fish = {
        key = "bl_fish",
        name = "The Fish",
        order = 10,
        dollars = 5,
        mult = 2,
        pos = {x = 0, y = 5},
        boss = {min = 2, max = 10},
        boss_colour = {0.24, 0.52, 0.74},
        debuff = {},
        description = "Cards drawn face down after each hand played"
    },
    
    bl_psychic = {
        key = "bl_psychic",
        name = "The Psychic",
        order = 11,
        dollars = 5,
        mult = 2,
        pos = {x = 0, y = 12},
        boss = {min = 1, max = 10},
        boss_colour = {0.94, 0.75, 0.24},
        debuff = {h_size_ge = 5},
        description = "Must play 5 cards"
    },
    
    bl_goad = {
        key = "bl_goad",
        name = "The Goad",
        order = 12,
        dollars = 5,
        mult = 2,
        pos = {x = 0, y = 13},
        boss = {min = 1, max = 10},
        boss_colour = {0.73, 0.36, 0.59},
        debuff = {suit = "Spades"},
        description = "All Spade cards are debuffed"
    },
    
    bl_water = {
        key = "bl_water",
        name = "The Water",
        order = 13,
        dollars = 5,
        mult = 2,
        pos = {x = 0, y = 14},
        boss = {min = 2, max = 10},
        boss_colour = {0.78, 0.88, 0.92},
        debuff = {},
        description = "Start with 0 discards"
    },
    
    bl_window = {
        key = "bl_window",
        name = "The Window",
        order = 14,
        dollars = 5,
        mult = 2,
        pos = {x = 0, y = 6},
        boss = {min = 1, max = 10},
        boss_colour = {0.66, 0.64, 0.58},
        debuff = {suit = "Diamonds"},
        description = "All Diamond cards are debuffed"
    },
    
    bl_manacle = {
        key = "bl_manacle",
        name = "The Manacle",
        order = 15,
        dollars = 5,
        mult = 2,
        pos = {x = 0, y = 8},
        boss = {min = 1, max = 10},
        boss_colour = {0.34, 0.34, 0.34},
        debuff = {},
        description = "-1 Hand Size"
    },
    
    bl_eye = {
        key = "bl_eye",
        name = "The Eye",
        order = 16,
        dollars = 5,
        mult = 2,
        pos = {x = 0, y = 17},
        boss = {min = 3, max = 10},
        boss_colour = {0.29, 0.44, 0.89},
        debuff = {},
        description = "No repeat hand types this round"
    },
    
    bl_mouth = {
        key = "bl_mouth",
        name = "The Mouth",
        order = 17,
        dollars = 5,
        mult = 2,
        pos = {x = 0, y = 18},
        boss = {min = 2, max = 10},
        boss_colour = {0.68, 0.44, 0.56},
        debuff = {},
        description = "Only play 1 hand type this round"
    },
    
    bl_plant = {
        key = "bl_plant",
        name = "The Plant",
        order = 18,
        dollars = 5,
        mult = 2,
        pos = {x = 0, y = 19},
        boss = {min = 4, max = 10},
        boss_colour = {0.44, 0.57, 0.52},
        debuff = {is_face = "face"},
        description = "All face cards are debuffed"
    },
    
    bl_serpent = {
        key = "bl_serpent",
        name = "The Serpent",
        order = 19,
        dollars = 5,
        mult = 2,
        pos = {x = 0, y = 15},
        boss = {min = 5, max = 10},
        boss_colour = {0.26, 0.60, 0.31},
        debuff = {},
        description = "After Play or Discard, always draw 3 cards"
    },
    
    bl_pillar = {
        key = "bl_pillar",
        name = "The Pillar",
        order = 20,
        dollars = 5,
        mult = 2,
        pos = {x = 0, y = 16},
        boss = {min = 1, max = 10},
        boss_colour = {0.49, 0.40, 0.32},
        debuff = {},
        description = "Cards played previously this Ante are debuffed"
    },
    
    bl_needle = {
        key = "bl_needle",
        name = "The Needle",
        order = 21,
        dollars = 5,
        mult = 1,
        pos = {x = 0, y = 20},
        boss = {min = 2, max = 10},
        boss_colour = {0.36, 0.43, 0.19},
        debuff = {},
        description = "Play only 1 hand"
    },
    
    bl_head = {
        key = "bl_head",
        name = "The Head",
        order = 22,
        dollars = 5,
        mult = 2,
        pos = {x = 0, y = 21},
        boss = {min = 1, max = 10},
        boss_colour = {0.67, 0.61, 0.71},
        debuff = {suit = "Hearts"},
        description = "All Heart cards are debuffed"
    },
    
    bl_tooth = {
        key = "bl_tooth",
        name = "The Tooth",
        order = 23,
        dollars = 5,
        mult = 2,
        pos = {x = 0, y = 22},
        boss = {min = 3, max = 10},
        boss_colour = {0.71, 0.18, 0.18},
        debuff = {},
        description = "Lose $1 per card played"
    },
    
    bl_flint = {
        key = "bl_flint",
        name = "The Flint",
        order = 24,
        dollars = 5,
        mult = 2,
        pos = {x = 0, y = 24},
        boss = {min = 2, max = 10},
        boss_colour = {0.90, 0.42, 0.18},
        debuff = {},
        description = "Base Chips and Mult are halved"
    },
    
    bl_mark = {
        key = "bl_mark",
        name = "The Mark",
        order = 25,
        dollars = 5,
        mult = 2,
        pos = {x = 0, y = 23},
        boss = {min = 2, max = 10},
        boss_colour = {0.42, 0.22, 0.28},
        debuff = {},
        description = "All face cards are drawn face down"
    },
    
    -- Final boss blinds (Ante 8)
    bl_final_acorn = {
        key = "bl_final_acorn",
        name = "Amber Acorn",
        order = 26,
        dollars = 8,
        mult = 2,
        pos = {x = 0, y = 27},
        boss = {showdown = true, min = 10, max = 10},
        boss_colour = {0.99, 0.64, 0},
        debuff = {},
        description = "Flips and shuffles all Joker cards"
    },
    
    bl_final_leaf = {
        key = "bl_final_leaf",
        name = "Verdant Leaf",
        order = 27,
        dollars = 8,
        mult = 2,
        pos = {x = 0, y = 28},
        boss = {showdown = true, min = 10, max = 10},
        boss_colour = {0.34, 0.65, 0.53},
        debuff = {},
        description = "All cards debuffed until 1 Joker sold"
    },
    
    bl_final_vessel = {
        key = "bl_final_vessel",
        name = "Violet Vessel",
        order = 28,
        dollars = 8,
        mult = 6,
        pos = {x = 0, y = 29},
        boss = {showdown = true, min = 10, max = 10},
        boss_colour = {0.54, 0.44, 0.88},
        debuff = {},
        description = "Very large blind"
    },
    
    bl_final_heart = {
        key = "bl_final_heart",
        name = "Crimson Heart",
        order = 29,
        dollars = 8,
        mult = 2,
        pos = {x = 0, y = 25},
        boss = {showdown = true, min = 10, max = 10},
        boss_colour = {0.67, 0.20, 0.20},
        debuff = {},
        description = "One random Joker disabled every hand"
    },
    
    bl_final_bell = {
        key = "bl_final_bell",
        name = "Cerulean Bell",
        order = 30,
        dollars = 8,
        mult = 2,
        pos = {x = 0, y = 26},
        boss = {showdown = true, min = 10, max = 10},
        boss_colour = {0, 0.61, 0.99},
        debuff = {},
        description = "Forces 1 card to always be selected"
    }
}

-- Calculate blind chip requirement based on ante
function M.getBlindChips(ante, blind_mult)
    -- Base chip requirements per ante
    local base_chips = {
        [1] = 300,
        [2] = 800,
        [3] = 2800,
        [4] = 6000,
        [5] = 11000,
        [6] = 20000,
        [7] = 35000,
        [8] = 50000
    }
    
    local base = base_chips[ante] or (50000 + (ante - 8) * 25000)
    return math.floor(base * (blind_mult or 1))
end

-- Get a random boss blind for the given ante
function M.getRandomBoss(ante)
    local valid = {}
    for key, blind in pairs(M.BLINDS) do
        if blind.boss and not blind.boss.showdown then
            if ante >= blind.boss.min and ante <= blind.boss.max then
                table.insert(valid, blind)
            end
        end
    end
    
    if #valid == 0 then return M.BLINDS.bl_hook end
    return valid[math.random(#valid)]
end

-- Get a final boss blind
function M.getFinalBoss()
    local finals = {"bl_final_acorn", "bl_final_leaf", "bl_final_vessel", "bl_final_heart", "bl_final_bell"}
    return M.BLINDS[finals[math.random(#finals)]]
end

return M

