-- Joker Effects
-- Implementation of all joker calculate hooks (loads from individual files)

local Scoring = require("micatro.core.scoring")

local M = {}

-- Context types for joker triggers
M.CONTEXT = {
    JOKER_MAIN = "joker_main",           -- When scoring (main phase)
    CARD_SCORED = "card_scored",         -- After each card scores
    HAND_PLAYED = "hand_played",         -- After hand type is determined
    DISCARD = "discard",                 -- When cards are discarded
    END_OF_ROUND = "end_of_round",       -- At end of round
    BLIND_SELECTED = "blind_selected",   -- When blind is selected
    SHOP_ENTERED = "shop_entered",       -- When entering shop
    CARD_ADDED = "card_added",           -- When card added to deck
    CARD_DESTROYED = "card_destroyed",   -- When card is destroyed
    REROLL = "reroll",                   -- When shop is rerolled
    PACK_OPENED = "pack_opened",         -- When booster pack opened
    PACK_SKIPPED = "pack_skipped",       -- When booster pack skipped
    SELL = "sell",                       -- When selling
    BUY = "buy"                          -- When buying
}

-- Load joker handlers from individual files
local jokerIndex = require("micatro.core.jokers._index")

M.HANDLERS = {}
for _, jokerKey in ipairs(jokerIndex) do
    local ok, handler = pcall(require, "micatro.core.jokers." .. jokerKey)
    if ok and handler then
        -- Wrap the handler to pass CONTEXT and Scoring
        M.HANDLERS[jokerKey] = function(joker, state, ctx)
            return handler(joker, state, ctx, M.CONTEXT, Scoring)
        end
    end
end

-- Calculate joker effect based on joker type and context
function M.calculate(joker, gameState, context)
    local data = joker.data
    local ability = joker.ability
    local effect = {}
    
    if not data or not data.key then
        return effect
    end
    
    -- Route to specific joker handler
    local handler = M.HANDLERS[data.key]
    if handler then
        effect = handler(joker, gameState, context) or {}
    end
    
    return effect
end

-- Apply all joker effects for a given context
function M.applyAll(jokers, gameState, context)
    local result = {
        chips = 0,
        mult = 0,
        xmult = 1,
        dollars = 0,
        effects = {}
    }
    
    for i, joker in ipairs(jokers) do
        local effect = M.calculate(joker, gameState, context)
        
        if effect.chips then
            result.chips = result.chips + effect.chips
        end
        if effect.mult then
            result.mult = result.mult + effect.mult
        end
        if effect.xmult then
            result.xmult = result.xmult * effect.xmult
        end
        if effect.dollars then
            result.dollars = result.dollars + effect.dollars
        end
        
        -- Track special effects
        if effect.destroy then
            table.insert(result.effects, {type = "destroy", joker = joker, index = i})
        end
        if effect.create_tarot then
            table.insert(result.effects, {type = "create_tarot"})
        end
        if effect.level_up_hand then
            table.insert(result.effects, {type = "level_up", hand = effect.level_up_hand})
        end
    end
    
    return result
end

return M
