-- Joker handler for j_triboulet (Legendary)
-- Triboulet: Played Kings and Queens each give X2 Mult
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.CARD_SCORED and ctx.card then
        if ctx.card.rank == "K" or ctx.card.rank == "Q" then
            return {xmult = joker.ability.extra or 2}
        end
    end
end
