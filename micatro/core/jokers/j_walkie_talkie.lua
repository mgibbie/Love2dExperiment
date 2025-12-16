-- Joker handler for j_walkie_talkie
-- Walkie Talkie: Each played 10 or 4 gives +10 Chips and +4 Mult
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.CARD_SCORED and ctx.card then
        if ctx.card.rank == "10" or ctx.card.rank == "4" then
            local chips = joker.ability.extra and joker.ability.extra.chips or 10
            local mult = joker.ability.extra and joker.ability.extra.mult or 4
            return {chips = chips, mult = mult}
        end
    end
end
