-- Deck (Back) definitions
-- Extracted from Balatro source P_CENTERS

local M = {}

M.DECKS = {
    b_red = {
        key = "b_red",
        name = "Red Deck",
        order = 1,
        pos = {x = 0, y = 0},
        set = "Back",
        unlocked = true,
        discovered = true,
        stake = 1,
        config = {
            discards = 1  -- +1 discard
        },
        description = "+1 discard every round"
    },
    
    b_blue = {
        key = "b_blue",
        name = "Blue Deck",
        order = 2,
        pos = {x = 0, y = 2},
        set = "Back",
        unlocked = false,
        stake = 1,
        config = {
            hands = 1  -- +1 hand
        },
        unlock_condition = {type = "discover_amount", amount = 20},
        description = "+1 hand every round"
    },
    
    b_yellow = {
        key = "b_yellow",
        name = "Yellow Deck",
        order = 3,
        pos = {x = 1, y = 2},
        set = "Back",
        unlocked = false,
        stake = 1,
        config = {
            dollars = 10  -- Start with +$10
        },
        unlock_condition = {type = "discover_amount", amount = 50},
        description = "Start with an extra $10"
    },
    
    b_green = {
        key = "b_green",
        name = "Green Deck",
        order = 4,
        pos = {x = 2, y = 2},
        set = "Back",
        unlocked = false,
        stake = 1,
        config = {
            extra_hand_bonus = 2,
            extra_discard_bonus = 1,
            no_interest = true
        },
        unlock_condition = {type = "discover_amount", amount = 75},
        description = "At end of each round: $2 per remaining Hand, $1 per remaining Discard. No interest"
    },
    
    b_black = {
        key = "b_black",
        name = "Black Deck",
        order = 5,
        pos = {x = 3, y = 2},
        set = "Back",
        unlocked = false,
        stake = 1,
        config = {
            hands = -1,
            joker_slot = 1  -- +1 joker slot
        },
        unlock_condition = {type = "discover_amount", amount = 100},
        description = "+1 Joker slot, -1 hand every round"
    },
    
    b_magic = {
        key = "b_magic",
        name = "Magic Deck",
        order = 6,
        pos = {x = 0, y = 3},
        set = "Back",
        unlocked = false,
        stake = 1,
        config = {
            voucher = "v_crystal_ball",
            consumables = {"c_fool", "c_fool"}
        },
        unlock_condition = {type = "win_deck", deck = "b_red"},
        description = "Start with Crystal Ball voucher and 2 copies of The Fool"
    },
    
    b_nebula = {
        key = "b_nebula",
        name = "Nebula Deck",
        order = 7,
        pos = {x = 3, y = 0},
        set = "Back",
        unlocked = false,
        stake = 1,
        config = {
            voucher = "v_telescope",
            consumable_slot = -1
        },
        unlock_condition = {type = "win_deck", deck = "b_blue"},
        description = "Start with Telescope voucher, -1 consumable slot"
    },
    
    b_ghost = {
        key = "b_ghost",
        name = "Ghost Deck",
        order = 8,
        pos = {x = 6, y = 2},
        set = "Back",
        unlocked = false,
        stake = 1,
        config = {
            spectral_rate = 2,
            consumables = {"c_hex"}
        },
        unlock_condition = {type = "win_deck", deck = "b_yellow"},
        description = "Spectral cards may appear in the shop, start with Hex card"
    },
    
    b_abandoned = {
        key = "b_abandoned",
        name = "Abandoned Deck",
        order = 9,
        pos = {x = 3, y = 3},
        set = "Back",
        unlocked = false,
        stake = 1,
        config = {
            remove_faces = true  -- No face cards in deck
        },
        unlock_condition = {type = "win_deck", deck = "b_green"},
        description = "Start with no face cards in your deck"
    },
    
    b_checkered = {
        key = "b_checkered",
        name = "Checkered Deck",
        order = 10,
        pos = {x = 1, y = 3},
        set = "Back",
        unlocked = false,
        stake = 1,
        config = {
            -- 26 Spades and 26 Hearts only
            only_suits = {"Spades", "Hearts"}
        },
        unlock_condition = {type = "win_deck", deck = "b_black"},
        description = "Start with 26 Spades and 26 Hearts in deck"
    },
    
    b_zodiac = {
        key = "b_zodiac",
        name = "Zodiac Deck",
        order = 11,
        pos = {x = 3, y = 4},
        set = "Back",
        unlocked = false,
        stake = 1,
        config = {
            vouchers = {"v_tarot_merchant", "v_planet_merchant", "v_overstock_norm"}
        },
        unlock_condition = {type = "win_stake", stake = 2},
        description = "Start with Tarot Merchant, Planet Merchant, and Overstock"
    },
    
    b_painted = {
        key = "b_painted",
        name = "Painted Deck",
        order = 12,
        pos = {x = 4, y = 3},
        set = "Back",
        unlocked = false,
        stake = 1,
        config = {
            hand_size = 2,
            joker_slot = -1
        },
        unlock_condition = {type = "win_stake", stake = 3},
        description = "+2 hand size, -1 Joker slot"
    },
    
    b_anaglyph = {
        key = "b_anaglyph",
        name = "Anaglyph Deck",
        order = 13,
        pos = {x = 2, y = 4},
        set = "Back",
        unlocked = false,
        stake = 1,
        config = {
            -- Double tag on boss blind defeat
            double_tag = true
        },
        unlock_condition = {type = "win_stake", stake = 4},
        description = "After defeating each Boss Blind, gain a Double Tag"
    },
    
    b_plasma = {
        key = "b_plasma",
        name = "Plasma Deck",
        order = 14,
        pos = {x = 4, y = 2},
        set = "Back",
        unlocked = false,
        stake = 1,
        config = {
            ante_scaling = 2  -- 2x ante scaling
        },
        unlock_condition = {type = "win_stake", stake = 5},
        description = "Balance Chips and Mult when calculating score. X2 base Blind size"
    },
    
    b_erratic = {
        key = "b_erratic",
        name = "Erratic Deck",
        order = 15,
        pos = {x = 2, y = 3},
        set = "Back",
        unlocked = false,
        stake = 1,
        config = {
            randomize_rank_suit = true
        },
        unlock_condition = {type = "win_stake", stake = 7},
        description = "All Ranks and Suits in deck are randomized"
    }
}

-- Get deck by key
function M.get(key)
    return M.DECKS[key]
end

-- Get all unlocked decks
function M.getUnlocked()
    local list = {}
    for key, deck in pairs(M.DECKS) do
        if deck.unlocked then
            table.insert(list, deck)
        end
    end
    table.sort(list, function(a, b) return a.order < b.order end)
    return list
end

-- Get all decks
function M.getAll()
    local list = {}
    for key, deck in pairs(M.DECKS) do
        table.insert(list, deck)
    end
    table.sort(list, function(a, b) return a.order < b.order end)
    return list
end

return M

