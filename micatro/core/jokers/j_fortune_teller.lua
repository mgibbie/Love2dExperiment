-- Joker handler for j_fortune_teller
-- Fortune Teller: +1 Mult per Tarot card used this run
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.JOKER_MAIN then
        local tarotCount = state.consumeable_usage_total and state.consumeable_usage_total.tarot or 0
        if tarotCount > 0 then
            return {mult = tarotCount}
        end
    end
end
