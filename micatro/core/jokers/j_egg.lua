-- Joker handler for j_egg
return function(joker, state, ctx, CONTEXT, Scoring)
if ctx.type == CONTEXT.END_OF_ROUND then
            joker.sell_value = (joker.sell_value or 0) + (joker.ability.extra or 3)
        end
end