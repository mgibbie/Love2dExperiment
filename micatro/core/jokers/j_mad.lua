-- Joker handler for j_mad
return function(joker, state, ctx, CONTEXT, Scoring)
if ctx.type == CONTEXT.HAND_PLAYED then
            if ctx.hand_name == "Two Pair" then
                return {mult = joker.ability.t_mult or 10}
            end
        end
end