-- Joker handler for j_cavendish
-- Cavendish: X3 Mult, 1 in 1000 chance to be destroyed at end of round
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.JOKER_MAIN then
        return {xmult = joker.ability.extra and joker.ability.extra.Xmult or 3}
    elseif ctx.type == CONTEXT.END_OF_ROUND then
        local odds = joker.ability.extra and joker.ability.extra.odds or 1000
        if math.random(odds) == 1 then
            return {destroy = true, message = "Extinct!"}
        end
    end
end

