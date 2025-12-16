-- Joker handler for j_photograph
-- Photograph: First played face card gives X2 Mult
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.CARD_SCORED and ctx.card then
        -- Check if this is the first face card in scoring hand
        if ctx.scoring_cards then
            for i, card in ipairs(ctx.scoring_cards) do
                if Scoring.isFaceCard(card) then
                    if card == ctx.card then
                        return {xmult = joker.ability.extra or 2}
                    end
                    break -- Only first face card gets the bonus
                end
            end
        end
    end
end

