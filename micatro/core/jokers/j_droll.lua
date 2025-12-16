-- Joker handler for j_droll
return function(joker, state, ctx, CONTEXT, Scoring)
if ctx.type == CONTEXT.HAND_PLAYED then
            local hand = ctx.hand_name or ""
            if hand:find("Flush") then
                return {mult = joker.ability.t_mult or 10}
            end
        end
end