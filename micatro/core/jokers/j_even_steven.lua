-- Joker handler for j_even_steven
return function(joker, state, ctx, CONTEXT, Scoring)
if ctx.type == CONTEXT.CARD_SCORED and ctx.card then
            if Scoring.isEven(ctx.card.rank) then
                return {mult = joker.ability.extra or 4}
            end
        end
end