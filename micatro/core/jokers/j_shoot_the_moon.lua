-- Joker handler for j_shoot_the_moon
-- Shoot the Moon: Each Queen held in hand gives +13 Mult
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.CARD_SCORED and ctx.cardarea == "hand" and ctx.card then
        if ctx.card.rank == "Q" then
            return {mult = joker.ability.extra or 13}
        end
    end
end

