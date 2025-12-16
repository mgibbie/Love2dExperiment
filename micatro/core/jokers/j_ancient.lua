-- Joker handler for j_ancient
-- Ancient Joker: Each played card of the current suit gives X1.5 Mult (suit changes each round)
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.CARD_SCORED and ctx.card then
        local targetSuit = state.ancient_card_suit or "Spades"
        if ctx.card.suit == targetSuit then
            return {xmult = joker.ability.extra or 1.5}
        end
    elseif ctx.type == CONTEXT.END_OF_ROUND then
        -- Change target suit for next round
        local suits = {"Hearts", "Diamonds", "Clubs", "Spades"}
        state.ancient_card_suit = suits[math.random(#suits)]
    end
end

