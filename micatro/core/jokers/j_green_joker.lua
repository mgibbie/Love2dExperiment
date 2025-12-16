-- Joker handler for j_green_joker
return function(joker, state, ctx, CONTEXT, Scoring)
if ctx.type == CONTEXT.JOKER_MAIN then
            return {mult = joker.ability.mult or 0}
        elseif ctx.type == CONTEXT.HAND_PLAYED then
            joker.ability.mult = (joker.ability.mult or 0) + 1
        elseif ctx.type == CONTEXT.DISCARD then
            joker.ability.mult = math.max(0, (joker.ability.mult or 0) - 1)
        end
end