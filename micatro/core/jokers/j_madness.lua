-- Joker handler for j_madness
-- Madness: When Small/Big Blind selected, gain X0.5 Mult and destroy random Joker
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.JOKER_MAIN then
        local xm = joker.ability.x_mult or 1
        if xm > 1 then
            return {xmult = xm}
        end
    elseif ctx.type == CONTEXT.BLIND_SELECTED then
        if not ctx.boss_blind then
            joker.ability.x_mult = (joker.ability.x_mult or 1) + (joker.ability.extra or 0.5)
            return {destroy_random_joker = true}
        end
    end
end

