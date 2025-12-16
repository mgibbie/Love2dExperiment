-- Joker handler for j_delayed_grat
-- Delayed Gratification: Earn $2 per discard if no discards used by end of round
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.END_OF_ROUND then
        if state.discards_used == 0 then
            local discards = state.discards_per_round or 3
            return {dollars = (joker.ability.extra or 2) * discards}
        end
    end
end

