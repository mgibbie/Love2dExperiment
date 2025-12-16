-- Joker handler for j_throwback
-- Throwback: X0.25 Mult for each Blind skipped this run
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.JOKER_MAIN then
        local xm = joker.ability.x_mult or 1
        if xm > 1 then
            return {xmult = xm}
        end
    elseif ctx.type == CONTEXT.BLIND_SELECTED and ctx.skipped then
        joker.ability.x_mult = (joker.ability.x_mult or 1) + (joker.ability.extra or 0.25)
    end
end

