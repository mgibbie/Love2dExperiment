-- Joker handler for j_hiker
-- Hiker: Every played card permanently gains +5 Chips
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.CARD_SCORED and ctx.card then
        -- Add permanent chip bonus to the card
        ctx.card.perma_bonus = (ctx.card.perma_bonus or 0) + (joker.ability.extra or 5)
        return {message = "Upgrade!"}
    end
end

