-- Joker handler for j_seeing_double
-- Seeing Double: X2 Mult if hand contains Club and any other suit with matching rank
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.JOKER_MAIN then
        local hasClub = false
        local clubRanks = {}
        local otherRanks = {}
        
        if ctx.scoring_cards then
            for _, card in ipairs(ctx.scoring_cards) do
                if card.suit == "Clubs" then
                    hasClub = true
                    clubRanks[card.rank] = true
                else
                    otherRanks[card.rank] = true
                end
            end
        end
        
        if hasClub then
            for rank, _ in pairs(clubRanks) do
                if otherRanks[rank] then
                    return {xmult = joker.ability.extra or 2}
                end
            end
        end
    end
end

