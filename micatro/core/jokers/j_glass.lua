-- Joker handler for j_glass
-- Glass Joker: Gains X0.75 Mult for every Glass card that is destroyed
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.JOKER_MAIN then
        local xm = joker.ability.x_mult or 1
        if xm > 1 then
            return {xmult = xm}
        end
    elseif ctx.type == CONTEXT.CARD_DESTROYED then
        if ctx.card and ctx.card.enhancement == "m_glass" then
            joker.ability.x_mult = (joker.ability.x_mult or 1) + (joker.ability.extra or 0.75)
        end
    end
end

