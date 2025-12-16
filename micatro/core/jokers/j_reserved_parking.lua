-- Joker handler for j_reserved_parking
-- Reserved Parking: Face cards held in hand have 1 in 2 chance to give $1
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.CARD_SCORED and ctx.cardarea == "hand" and ctx.card then
        if Scoring.isFaceCard(ctx.card) then
            local odds = joker.ability.extra and joker.ability.extra.odds or 2
            if math.random(odds) == 1 then
                return {dollars = joker.ability.extra and joker.ability.extra.dollars or 1}
            end
        end
    end
end

