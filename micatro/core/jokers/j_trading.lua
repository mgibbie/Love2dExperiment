-- Joker handler for j_trading
-- Trading Card: If first discard of round has only 1 card, destroy it and earn $3
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.DISCARD then
        if state.discards_used_round == 0 and ctx.count == 1 then
            return {
                destroy_card = ctx.card,
                dollars = joker.ability.extra or 3
            }
        end
    end
end

