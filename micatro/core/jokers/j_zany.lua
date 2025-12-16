-- Joker handler for j_zany
return function(joker, state, ctx, CONTEXT, Scoring)
if ctx.type == CONTEXT.HAND_PLAYED then
            local hand = ctx.hand_name or ""
            if hand == "Three of a Kind" or hand == "Full House" or
               hand == "Four of a Kind" or hand == "Five of a Kind" then
                return {mult = joker.ability.t_mult or 12}
            end
        end
end