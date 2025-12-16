-- Joker handler for j_space
return function(joker, state, ctx, CONTEXT, Scoring)
if ctx.type == CONTEXT.HAND_PLAYED then
            if math.random(joker.ability.extra or 4) == 1 then
                return {level_up_hand = ctx.hand_name}
            end
        end
end