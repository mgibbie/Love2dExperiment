-- Joker handler for j_caino (Legendary)
-- Canio: Gains X1 Mult when a face card is destroyed
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.JOKER_MAIN then
        local xm = joker.ability.caino_xmult or 1
        if xm > 1 then
            return {xmult = xm}
        end
    elseif ctx.type == CONTEXT.CARD_DESTROYED or ctx.type == CONTEXT.CARD_REMOVED then
        if ctx.card and Scoring.isFaceCard(ctx.card) then
            joker.ability.caino_xmult = (joker.ability.caino_xmult or 1) + (joker.ability.extra or 1)
        end
    end
end
