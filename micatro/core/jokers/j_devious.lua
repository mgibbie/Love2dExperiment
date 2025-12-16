-- Joker handler for j_devious
return function(joker, state, ctx, CONTEXT, Scoring)
if ctx.type == CONTEXT.HAND_PLAYED then
            local hand = ctx.hand_name or ""
            if hand == "Straight" or hand == "Straight Flush" then
                return {chips = joker.ability.t_chips or 100}
            end
        end
end