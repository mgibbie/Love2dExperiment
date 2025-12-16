-- Joker handler for j_midas_mask
-- Midas Mask: All played face cards become Gold cards
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.HAND_PLAYED then
        local faceCards = {}
        if ctx.scoring_cards then
            for _, card in ipairs(ctx.scoring_cards) do
                if Scoring.isFaceCard(card) then
                    table.insert(faceCards, card)
                end
            end
        end
        if #faceCards > 0 then
            return {convert_to_gold = faceCards}
        end
    end
end

