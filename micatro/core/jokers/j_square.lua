-- Joker handler for j_square
-- Square Joker: Gains +4 Chips if played hand has exactly 4 cards
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.JOKER_MAIN then
        return {chips = joker.ability.extra and joker.ability.extra.chips or 0}
    elseif ctx.type == CONTEXT.HAND_PLAYED then
        if ctx.cards_played == 4 then
            joker.ability.extra = joker.ability.extra or {chips = 0, chip_mod = 4}
            joker.ability.extra.chips = joker.ability.extra.chips + joker.ability.extra.chip_mod
            return {message = "Upgrade!"}
        end
    end
end

