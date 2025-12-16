-- Joker handler for j_rough_gem
-- Rough Gem: Played Diamonds earn $1
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.CARD_SCORED and ctx.card then
        if ctx.card.suit == "Diamonds" then
            return {dollars = joker.ability.extra or 1}
        end
    end
end

