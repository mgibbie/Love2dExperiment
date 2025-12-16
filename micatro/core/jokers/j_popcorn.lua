-- Joker handler for j_popcorn
-- Popcorn: +20 Mult, -4 Mult per round played
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.JOKER_MAIN then
        return {mult = joker.ability.mult or 20}
    elseif ctx.type == CONTEXT.END_OF_ROUND then
        joker.ability.mult = (joker.ability.mult or 20) - (joker.ability.extra or 4)
        if joker.ability.mult <= 0 then
            return {destroy = true, message = "Eaten!"}
        end
    end
end
