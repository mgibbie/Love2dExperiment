-- Joker handler for j_acrobat
-- Acrobat: X3 Mult on final hand of round
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.JOKER_MAIN then
        if state.hands_remaining == 0 then
            return {xmult = joker.ability.extra or 3}
        end
    end
end

