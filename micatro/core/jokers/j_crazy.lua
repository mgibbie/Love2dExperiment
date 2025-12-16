-- Joker handler for j_crazy
return function(joker, state, ctx, CONTEXT, Scoring)
if ctx.type == CONTEXT.HAND_PLAYED then
            local hand = ctx.hand_name or ""
            if hand == "Straight" or hand == "Straight Flush" then
                return {mult = joker.ability.t_mult or 12}
            end
        end
end