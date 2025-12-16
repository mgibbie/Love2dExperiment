-- Joker handler for j_crafty
return function(joker, state, ctx, CONTEXT, Scoring)
if ctx.type == CONTEXT.HAND_PLAYED then
            local hand = ctx.hand_name or ""
            if hand:find("Flush") then
                return {chips = joker.ability.t_chips or 80}
            end
        end
end