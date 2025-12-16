-- Joker handler for j_diet_cola
-- Diet Cola: Sell this card to create a free Double Tag
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.SELL then
        return {create_double_tag = true}
    end
end

