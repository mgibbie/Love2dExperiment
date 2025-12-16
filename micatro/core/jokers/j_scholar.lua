-- Joker handler for j_scholar
return function(joker, state, ctx, CONTEXT, Scoring)
if ctx.type == CONTEXT.CARD_SCORED and ctx.card then
            if ctx.card.rank == "A" then
                return {
                    chips = joker.ability.extra and joker.ability.extra.chips or 20,
                    mult = joker.ability.extra and joker.ability.extra.mult or 4
                }
            end
        end
end