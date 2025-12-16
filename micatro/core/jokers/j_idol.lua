-- Joker handler for j_idol
-- The Idol: Each played card of the current rank and suit gives X2 Mult
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.CARD_SCORED and ctx.card then
        local targetRank = state.idol_card_rank or "A"
        local targetSuit = state.idol_card_suit or "Hearts"
        if ctx.card.rank == targetRank and ctx.card.suit == targetSuit then
            return {xmult = joker.ability.extra or 2}
        end
    elseif ctx.type == CONTEXT.END_OF_ROUND then
        -- Change target card for next round
        local ranks = {"2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"}
        local suits = {"Hearts", "Diamonds", "Clubs", "Spades"}
        state.idol_card_rank = ranks[math.random(#ranks)]
        state.idol_card_suit = suits[math.random(#suits)]
    end
end

