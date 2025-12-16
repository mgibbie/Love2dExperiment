-- Card Definitions
-- Ported from battlecards Svelte project

local cards = {}

-- Card Types
cards.TYPES = {
    CREATURE = 'creature',
    SPELL = 'spell'
}

-- Card Classes
cards.CLASSES = {
    NEUTRAL = 'neutral',
    CENTURION = 'centurion',
    NATURALIST = 'naturalist',
    BOUNTY_HUNTER = 'bounty_hunter'
}

-- Card Rarities
cards.RARITIES = {
    COMMON = 'common',
    UNCOMMON = 'uncommon',
    RARE = 'rare',
    EPIC = 'epic',
    LEGENDARY = 'legendary',
    MYTHIC = 'mythic'
}

-- Rarity colors (gem and glow)
cards.rarityColors = {
    common = { gem = {0.9, 0.9, 0.9}, glow = {1, 1, 1} },
    uncommon = { gem = {0.23, 0.51, 0.96}, glow = {0.38, 0.65, 0.98} },
    rare = { gem = {0.66, 0.33, 0.97}, glow = {0.75, 0.52, 0.99} },
    epic = { gem = {0.94, 0.27, 0.27}, glow = {0.97, 0.44, 0.44} },
    legendary = { gem = {0.96, 0.62, 0.04}, glow = {0.98, 0.75, 0.14} },
    mythic = { gem = {0.1, 0.1, 0.1}, glow = {0.29, 0.29, 0.29} }
}

-- Color schemes for each class
cards.colorSchemes = {
    neutral = {
        primary = {0.29, 0.33, 0.39},
        secondary = {0.42, 0.45, 0.50},
        accent = {0.61, 0.64, 0.69},
        glow = {0.82, 0.84, 0.86}
    },
    centurion = {
        primary = {0.57, 0.25, 0.05},
        secondary = {0.83, 0.63, 0.09},
        accent = {0.98, 0.75, 0.14},
        glow = {0.99, 0.83, 0.30}
    },
    naturalist = {
        primary = {0.08, 0.33, 0.18},
        secondary = {0.13, 0.77, 0.37},
        accent = {0.29, 0.87, 0.50},
        glow = {0.53, 0.94, 0.67}
    },
    bounty_hunter = {
        primary = {0.27, 0.13, 0.05},
        secondary = {0.57, 0.25, 0.05},
        accent = {0.71, 0.33, 0.04},
        glow = {0.85, 0.46, 0.02}
    }
}

-- Sample cards for the game
cards.sampleCards = {
    -- === NEUTRAL CARDS ===
    {
        id = 'recruit',
        name = 'Recruit',
        type = 'creature',
        cardClass = 'neutral',
        rarity = 'common',
        cost = 1,
        attack = 1,
        health = 2,
        effect = 'A basic fighter ready for battle.',
        keywords = {}
    },
    {
        id = 'wandering-merchant',
        name = 'Wandering Merchant',
        type = 'creature',
        cardClass = 'neutral',
        rarity = 'uncommon',
        cost = 2,
        attack = 2,
        health = 2,
        effect = 'Battlecry: Draw a card.',
        keywords = {'Battlecry'}
    },
    {
        id = 'arcane-bolt',
        name = 'Arcane Bolt',
        type = 'spell',
        cardClass = 'neutral',
        rarity = 'common',
        cost = 2,
        effect = 'Deal 3 damage to any target.',
        keywords = {}
    },
    {
        id = 'healing-potion',
        name = 'Healing Potion',
        type = 'spell',
        cardClass = 'neutral',
        rarity = 'common',
        cost = 1,
        effect = 'Restore 5 health to your hero.',
        keywords = {}
    },

    -- === CENTURION CARDS (Gold) ===
    {
        id = 'shield-bearer',
        name = 'Shield Bearer',
        type = 'creature',
        cardClass = 'centurion',
        rarity = 'common',
        cost = 2,
        attack = 1,
        health = 4,
        effect = 'Taunt',
        keywords = {'Taunt'}
    },
    {
        id = 'legion-commander',
        name = 'Legion Commander',
        type = 'creature',
        cardClass = 'centurion',
        rarity = 'rare',
        cost = 4,
        attack = 3,
        health = 4,
        effect = 'Battlecry: Give adjacent creatures +1/+1.',
        tribe = 'Soldier',
        keywords = {'Battlecry'}
    },
    {
        id = 'golden-guardian',
        name = 'Golden Guardian',
        type = 'creature',
        cardClass = 'centurion',
        rarity = 'epic',
        cost = 5,
        attack = 4,
        health = 6,
        effect = 'Taunt. Divine Shield.',
        keywords = {'Taunt', 'Divine Shield'}
    },
    {
        id = 'fortify',
        name = 'Fortify',
        type = 'spell',
        cardClass = 'centurion',
        rarity = 'common',
        cost = 2,
        effect = 'Give a creature +0/+3 and Taunt.',
        keywords = {}
    },
    {
        id = 'rallying-cry',
        name = 'Rallying Cry',
        type = 'spell',
        cardClass = 'centurion',
        rarity = 'uncommon',
        cost = 3,
        effect = 'Give all friendly creatures +1/+1.',
        keywords = {}
    },
    {
        id = 'acidspitter',
        name = 'Acidspitter',
        type = 'creature',
        cardClass = 'centurion',
        rarity = 'rare',
        cost = 3,
        attack = 2,
        health = 2,
        tribe = 'Beast',
        effect = 'Deathtouch. Deathrattle: Deal 1 damage to a random opponent or creature.',
        keywords = {'Deathtouch', 'Deathrattle'}
    },
    {
        id = 'acidspitter-nest',
        name = 'Acidspitter Nest',
        type = 'creature',
        cardClass = 'centurion',
        rarity = 'epic',
        cost = 5,
        attack = 0,
        health = 7,
        tribe = 'Construct',
        effect = 'At the end of your turn create two Acidspitters.',
        keywords = {}
    },

    -- === NATURALIST CARDS (Green) ===
    {
        id = 'forest-sprite',
        name = 'Forest Sprite',
        type = 'creature',
        cardClass = 'naturalist',
        rarity = 'common',
        cost = 1,
        attack = 1,
        health = 1,
        effect = 'Deathrattle: Summon a 1/1 Seedling.',
        tribe = 'Spirit',
        keywords = {'Deathrattle'}
    },
    {
        id = 'pack-wolf',
        name = 'Pack Wolf',
        type = 'creature',
        cardClass = 'naturalist',
        rarity = 'uncommon',
        cost = 3,
        attack = 3,
        health = 3,
        effect = 'Battlecry: If you control another Beast, gain +2/+2.',
        tribe = 'Beast',
        keywords = {'Battlecry'}
    },
    {
        id = 'ancient-treant',
        name = 'Ancient Treant',
        type = 'creature',
        cardClass = 'naturalist',
        rarity = 'legendary',
        cost = 6,
        attack = 5,
        health = 8,
        effect = 'Taunt. At end of turn, restore 2 health to your hero.',
        tribe = 'Elemental',
        keywords = {'Taunt'}
    },
    {
        id = 'wild-growth',
        name = 'Wild Growth',
        type = 'spell',
        cardClass = 'naturalist',
        rarity = 'common',
        cost = 2,
        effect = 'Summon two 1/1 Animal tokens.',
        keywords = {}
    },
    {
        id = 'natures-blessing',
        name = "Nature's Blessing",
        type = 'spell',
        cardClass = 'naturalist',
        rarity = 'rare',
        cost = 3,
        effect = 'Restore 8 health. Draw a card.',
        keywords = {}
    },

    -- === BOUNTY HUNTER CARDS (Brown) ===
    {
        id = 'shadow-stalker',
        name = 'Shadow Stalker',
        type = 'creature',
        cardClass = 'bounty_hunter',
        rarity = 'uncommon',
        cost = 2,
        attack = 3,
        health = 2,
        effect = 'Stealth',
        keywords = {'Stealth'}
    },
    {
        id = 'contract-killer',
        name = 'Contract Killer',
        type = 'creature',
        cardClass = 'bounty_hunter',
        rarity = 'rare',
        cost = 4,
        attack = 4,
        health = 3,
        effect = 'Battlecry: Destroy a creature with 3 or less health.',
        keywords = {'Battlecry'}
    },
    {
        id = 'guild-assassin',
        name = 'Guild Assassin',
        type = 'creature',
        cardClass = 'bounty_hunter',
        rarity = 'legendary',
        cost = 5,
        attack = 5,
        health = 4,
        effect = 'Stealth. Deathtouch.',
        keywords = {'Stealth', 'Deathtouch'}
    },
    {
        id = 'mark-target',
        name = 'Mark Target',
        type = 'spell',
        cardClass = 'bounty_hunter',
        rarity = 'common',
        cost = 1,
        effect = 'Mark an enemy creature. When it dies, draw 2 cards.',
        keywords = {}
    },
    {
        id = 'backstab',
        name = 'Backstab',
        type = 'spell',
        cardClass = 'bounty_hunter',
        rarity = 'common',
        cost = 0,
        effect = 'Deal 2 damage to an undamaged creature.',
        keywords = {}
    },
    {
        id = 'westward-prosperity',
        name = 'Westward Prosperity',
        type = 'spell',
        cardClass = 'bounty_hunter',
        rarity = 'legendary',
        cost = 1,
        effect = 'Quest: Quickdraw 9 cards. Reward: Deal 9 damage to all enemies.',
        keywords = {'Quest'}
    },
    {
        id = 'tumbleweed-tactician',
        name = 'Tumbleweed Tactician',
        type = 'creature',
        cardClass = 'bounty_hunter',
        rarity = 'uncommon',
        cost = 4,
        attack = 3,
        health = 3,
        tribe = 'Lizardfolk',
        effect = 'Battlecry: Deal 3 damage to target creature. If it dies, create a 2/1 Tumbleweed with Rush.',
        keywords = {'Battlecry'}
    },
    {
        id = 'the-lone-ranger',
        name = 'The Lone Ranger',
        type = 'creature',
        cardClass = 'bounty_hunter',
        rarity = 'legendary',
        cost = 2,
        attack = 2,
        health = 2,
        tribe = 'Human',
        effect = 'Battlecry: Choose one - Destroy creature with cost 4 or less; or Copy creature with cost 2 or less.',
        keywords = {'Battlecry'}
    },
    {
        id = 'silencer',
        name = 'Silencer',
        type = 'spell',
        cardClass = 'bounty_hunter',
        rarity = 'uncommon',
        cost = 1,
        effect = 'Enchant Hero Weapon. Whenever you attack a creature, Silence it.',
        keywords = {'Aura'}
    },
    {
        id = 'running-gunner',
        name = 'Running Gunner',
        type = 'creature',
        cardClass = 'bounty_hunter',
        rarity = 'common',
        cost = 3,
        attack = 3,
        health = 2,
        tribe = 'Human',
        effect = 'Rush. Deathrattle: Deal 1 damage to each enemy creature and opponent.',
        keywords = {'Rush', 'Deathrattle'}
    },
    {
        id = 'regroup',
        name = 'Regroup',
        type = 'spell',
        cardClass = 'bounty_hunter',
        rarity = 'uncommon',
        cost = 1,
        effect = 'Draw a card for each creature you control that died this turn.',
        keywords = {}
    },
    {
        id = 'paid-off-patrolman',
        name = 'Paid Off Patrolman',
        type = 'creature',
        cardClass = 'bounty_hunter',
        rarity = 'common',
        cost = 7,
        attack = 5,
        health = 8,
        tribe = 'Human',
        effect = 'Taunt. Costs 1 less for each coin in your graveyard.',
        keywords = {'Taunt'}
    },
    {
        id = 'officer-octo',
        name = 'Officer Octo',
        type = 'creature',
        cardClass = 'bounty_hunter',
        rarity = 'legendary',
        cost = 4,
        attack = 2,
        health = 2,
        tribe = 'Beast',
        effect = 'Battlecry: Quickdraw 8.',
        keywords = {'Battlecry'}
    },
    {
        id = 'landlocked-privateer',
        name = 'Landlocked Privateer',
        type = 'creature',
        cardClass = 'bounty_hunter',
        rarity = 'common',
        cost = 1,
        attack = 1,
        health = 2,
        tribe = 'Pirate',
        effect = 'Inspire: Quickdraw 2.',
        keywords = {}
    },
    {
        id = 'harried-herdsman',
        name = 'Harried Herdsman',
        type = 'creature',
        cardClass = 'bounty_hunter',
        rarity = 'uncommon',
        cost = 5,
        attack = 4,
        health = 5,
        tribe = 'Human',
        effect = 'After you cast a Fire spell, each Beast you control attacks a random enemy.',
        keywords = {}
    }
}

-- Helper function to get card by ID
function cards.getById(id)
    for _, card in ipairs(cards.sampleCards) do
        if card.id == id then
            return card
        end
    end
    return nil
end

-- Helper function to get cards by class
function cards.getByClass(cardClass)
    local result = {}
    for _, card in ipairs(cards.sampleCards) do
        if card.cardClass == cardClass then
            table.insert(result, card)
        end
    end
    return result
end

-- Helper function to get all creature cards
function cards.getCreatures()
    local result = {}
    for _, card in ipairs(cards.sampleCards) do
        if card.type == 'creature' then
            table.insert(result, card)
        end
    end
    return result
end

-- Deep copy a card (for creating instances)
function cards.copy(card)
    local newCard = {}
    for k, v in pairs(card) do
        if type(v) == 'table' then
            newCard[k] = {}
            for i, val in ipairs(v) do
                newCard[k][i] = val
            end
        else
            newCard[k] = v
        end
    end
    return newCard
end

return cards

