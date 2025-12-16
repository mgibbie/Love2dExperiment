-- Joker handler for j_superposition
-- Superposition: Create Tarot if hand contains Ace and Straight
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.HAND_PLAYED then
        local hand = ctx.hand_name or ""
        local hasAce = false
        if ctx.scoring_cards then
            for _, card in ipairs(ctx.scoring_cards) do
                if card.rank == "A" then
                    hasAce = true
                    break
                end
            end
        end
        if hasAce and (hand == "Straight" or hand == "Straight Flush") then
            return {create_tarot = true}
        end
    end
end

