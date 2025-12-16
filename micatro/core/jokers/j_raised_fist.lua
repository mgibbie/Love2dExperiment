-- Joker handler for j_raised_fist
-- Raised Fist: Adds double the rank of lowest ranked card held in hand to Mult
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.CARD_SCORED and ctx.cardarea == "hand" then
        -- Find lowest ranked card in hand
        local lowestRank = 15
        local lowestNominal = 15
        for _, card in ipairs(state.hand or {}) do
            local id = Scoring.getRankValue(card.rank)
            if id < lowestRank then
                lowestRank = id
                lowestNominal = card.nominal or id
            end
        end
        
        if ctx.card and Scoring.getRankValue(ctx.card.rank) == lowestRank then
            return {mult = 2 * lowestNominal}
        end
    end
end

