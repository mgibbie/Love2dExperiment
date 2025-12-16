-- Joker handler for j_ticket
-- Golden Ticket: Played Gold cards earn $4
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.CARD_SCORED and ctx.card then
        if ctx.card.enhancement == "m_gold" then
            return {dollars = joker.ability.extra or 4}
        end
    end
end

