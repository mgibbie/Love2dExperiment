-- Joker handler for j_odd_todd
return function(joker, state, ctx, CONTEXT, Scoring)
if ctx.type == CONTEXT.CARD_SCORED and ctx.card then
            if Scoring.isOdd(ctx.card.rank) then
                return {chips = joker.ability.extra or 31}
            end
        end
end