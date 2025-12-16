-- Joker handler for j_sly
return function(joker, state, ctx, CONTEXT, Scoring)
if ctx.type == CONTEXT.HAND_PLAYED then
            local hand = ctx.hand_name or ""
            if hand == "Pair" or hand == "Two Pair" or hand == "Full House" or
               hand:find("Kind") then
                return {chips = joker.ability.t_chips or 50}
            end
        end
end