-- Joker handler for j_wee
-- Wee Joker: +8 Chips for each 2 played, gains +8 Chips permanently
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.CARD_SCORED and ctx.card then
        if ctx.card.rank == "2" then
            joker.ability.extra = joker.ability.extra or {chips = 0, chip_mod = 8}
            joker.ability.extra.chips = joker.ability.extra.chips + joker.ability.extra.chip_mod
            return {chips = joker.ability.extra.chip_mod, message = "Upgrade!"}
        end
    elseif ctx.type == CONTEXT.JOKER_MAIN then
        return {chips = joker.ability.extra and joker.ability.extra.chips or 0}
    end
end

