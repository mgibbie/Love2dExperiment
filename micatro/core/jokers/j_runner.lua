-- Joker handler for j_runner
return function(joker, state, ctx, CONTEXT, Scoring)
if ctx.type == CONTEXT.JOKER_MAIN then
            return {chips = joker.ability.extra and joker.ability.extra.chips or 0}
        elseif ctx.type == CONTEXT.HAND_PLAYED then
            local hand = ctx.hand_name or ""
            if hand == "Straight" or hand == "Straight Flush" then
                joker.ability.extra = joker.ability.extra or {chips = 0, chip_mod = 15}
                joker.ability.extra.chips = joker.ability.extra.chips + joker.ability.extra.chip_mod
            end
        end
end