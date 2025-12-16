-- Joker handler for j_campfire
-- Campfire: Gains X0.25 Mult for each card sold, resets when Boss Blind is defeated
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.JOKER_MAIN then
        local xm = joker.ability.x_mult or 1
        if xm > 1 then
            return {xmult = xm}
        end
    elseif ctx.type == CONTEXT.SELL then
        joker.ability.x_mult = (joker.ability.x_mult or 1) + (joker.ability.extra or 0.25)
    elseif ctx.type == CONTEXT.END_OF_ROUND then
        if ctx.boss_defeated then
            joker.ability.x_mult = 1
            return {message = "Reset"}
        end
    end
end

