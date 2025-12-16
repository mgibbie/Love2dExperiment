-- Joker handler for j_hologram
-- Hologram: Gains X0.25 Mult for each card added to deck
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.JOKER_MAIN then
        local xm = joker.ability.x_mult or 1
        if xm > 1 then
            return {xmult = xm}
        end
    elseif ctx.type == CONTEXT.CARD_ADDED then
        local cardsAdded = ctx.count or 1
        joker.ability.x_mult = (joker.ability.x_mult or 1) + (joker.ability.extra or 0.25) * cardsAdded
    end
end

