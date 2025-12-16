-- Joker handler for j_castle
-- Castle: +3 Chips per discarded card of current suit, suit changes each round
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.JOKER_MAIN then
        return {chips = joker.ability.extra and joker.ability.extra.chips or 0}
    elseif ctx.type == CONTEXT.DISCARD and ctx.card then
        local targetSuit = state.castle_card_suit or "Spades"
        if ctx.card.suit == targetSuit then
            joker.ability.extra = joker.ability.extra or {chips = 0, chip_mod = 3}
            joker.ability.extra.chips = joker.ability.extra.chips + joker.ability.extra.chip_mod
        end
    elseif ctx.type == CONTEXT.END_OF_ROUND then
        -- Change target suit for next round
        local suits = {"Hearts", "Diamonds", "Clubs", "Spades"}
        state.castle_card_suit = suits[math.random(#suits)]
    end
end

