-- Joker handler for j_golden
-- Golden Joker: Earn $4 at end of round
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.END_OF_ROUND then
        return {dollars = joker.ability.extra or 4}
    end
end
