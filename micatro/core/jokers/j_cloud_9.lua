-- Joker handler for j_cloud_9
-- Cloud 9: Earn $1 for each 9 in full deck at end of round
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.END_OF_ROUND then
        local nineCount = 0
        for _, card in ipairs(state.deck or {}) do
            if card.rank == "9" then
                nineCount = nineCount + 1
            end
        end
        if nineCount > 0 then
            return {dollars = (joker.ability.extra or 1) * nineCount}
        end
    end
end

