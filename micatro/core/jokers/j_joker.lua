-- Joker handler for j_joker
return function(joker, state, ctx, CONTEXT, Scoring)
if ctx.type == CONTEXT.JOKER_MAIN then
            return {mult = joker.ability.mult or 4}
        end
end