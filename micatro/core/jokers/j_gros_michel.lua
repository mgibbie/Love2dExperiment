-- Joker handler for j_gros_michel
-- Gros Michel: +15 Mult, 1 in 6 chance to be destroyed at end of round
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.JOKER_MAIN then
        return {mult = joker.ability.extra and joker.ability.extra.mult or 15}
    elseif ctx.type == CONTEXT.END_OF_ROUND then
        local odds = joker.ability.extra and joker.ability.extra.odds or 6
        if math.random(odds) == 1 then
            return {destroy = true, message = "Extinct!"}
        end
    end
end

