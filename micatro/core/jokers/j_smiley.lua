-- Joker handler for j_smiley
-- Smiley Face: Played face cards give +5 Mult
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.CARD_SCORED and ctx.card then
        if Scoring.isFaceCard(ctx.card) then
            return {mult = joker.ability.extra or 5}
        end
    end
end
