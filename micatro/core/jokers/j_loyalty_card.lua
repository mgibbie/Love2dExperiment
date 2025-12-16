-- Joker handler for j_loyalty_card
-- Loyalty Card: X4 Mult every 6 hands played
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.JOKER_MAIN then
        local every = joker.ability.extra and joker.ability.extra.every or 5
        local hands_played = state.hands_played_total or 0
        local loyalty_remaining = every - (hands_played % (every + 1))
        
        if loyalty_remaining == every then
            return {xmult = joker.ability.extra and joker.ability.extra.Xmult or 4}
        end
    end
end

