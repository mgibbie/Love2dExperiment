-- Joker handler for j_scary_face
return function(joker, state, ctx, CONTEXT, Scoring)
if ctx.type == CONTEXT.CARD_SCORED and ctx.card then
            if Scoring.isFaceCard(ctx.card) then
                return {chips = joker.ability.extra or 30}
            end
        end
end