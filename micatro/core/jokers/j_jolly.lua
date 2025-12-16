-- Joker handler for j_jolly
return function(joker, state, ctx, CONTEXT, Scoring)
if ctx.type == CONTEXT.HAND_PLAYED then
            local hand = ctx.hand_name or ""
            if hand == "Pair" or hand == "Two Pair" or hand == "Full House" or
               hand:find("Kind") then
                return {mult = joker.ability.t_mult or 8}
            end
        end
end