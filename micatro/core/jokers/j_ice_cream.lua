-- Joker handler for j_ice_cream
return function(joker, state, ctx, CONTEXT, Scoring)
if ctx.type == CONTEXT.JOKER_MAIN then
            return {chips = joker.ability.extra and joker.ability.extra.chips or 100}
        elseif ctx.type == CONTEXT.HAND_PLAYED then
            joker.ability.extra = joker.ability.extra or {chips = 100, chip_mod = 5}
            joker.ability.extra.chips = joker.ability.extra.chips - joker.ability.extra.chip_mod
            if joker.ability.extra.chips <= 0 then
                -- Joker destroys itself
                return {destroy = true}
            end
        end
end