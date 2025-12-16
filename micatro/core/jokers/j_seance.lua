-- Joker handler for j_seance
-- Seance: If poker hand is a Straight Flush, create random Spectral card
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.HAND_PLAYED then
        local targetHand = joker.ability.extra and joker.ability.extra.poker_hand or "Straight Flush"
        if ctx.hand_name == targetHand then
            return {create_spectral = true}
        end
    end
end

