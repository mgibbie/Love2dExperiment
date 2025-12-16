-- Joker handler for j_onyx_agate
-- Onyx Agate: Played Clubs give +7 Mult
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.CARD_SCORED and ctx.card then
        if ctx.card.suit == "Clubs" then
            return {mult = joker.ability.extra or 7}
        end
    end
end

