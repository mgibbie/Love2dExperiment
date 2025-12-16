-- Joker handler for j_arrowhead
-- Arrowhead: Played Spades give +50 Chips
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.CARD_SCORED and ctx.card then
        if ctx.card.suit == "Spades" then
            return {chips = joker.ability.extra or 50}
        end
    end
end

