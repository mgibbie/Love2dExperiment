-- Joker handler for j_gift
-- Gift Card: Add $1 of sell value to all Jokers and Consumables at end of round
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.END_OF_ROUND then
        return {add_sell_value = joker.ability.extra or 1}
    end
end

