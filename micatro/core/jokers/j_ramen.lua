-- Joker handler for j_ramen
-- Ramen: X2 Mult, loses X0.01 Mult per card discarded
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.JOKER_MAIN then
        local xm = joker.ability.x_mult or 2
        if xm > 1 then
            return {xmult = xm}
        end
    elseif ctx.type == CONTEXT.DISCARD then
        joker.ability.x_mult = (joker.ability.x_mult or 2) - (joker.ability.extra or 0.01)
        if joker.ability.x_mult <= 1 then
            return {destroy = true, message = "Eaten!"}
        end
    end
end
