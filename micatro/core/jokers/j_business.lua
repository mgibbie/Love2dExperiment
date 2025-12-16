-- Joker handler for j_business
-- Business Card: Played face cards have 1 in 2 chance to give $2
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.CARD_SCORED and ctx.card then
        if Scoring.isFaceCard(ctx.card) then
            local odds = joker.ability.extra or 2
            if math.random(odds) == 1 then
                return {dollars = 2}
            end
        end
    end
end

