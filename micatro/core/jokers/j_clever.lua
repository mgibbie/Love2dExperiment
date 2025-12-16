-- Joker handler for j_clever
return function(joker, state, ctx, CONTEXT, Scoring)
if ctx.type == CONTEXT.HAND_PLAYED then
            if ctx.hand_name == "Two Pair" then
                return {chips = joker.ability.t_chips or 80}
            end
        end
end