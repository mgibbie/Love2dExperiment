-- Joker handler for j_stone
-- Stone Joker: +25 Chips for each Stone card in deck
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.JOKER_MAIN then
        local stoneCount = 0
        for _, card in ipairs(state.deck or {}) do
            if card.enhancement == "m_stone" then
                stoneCount = stoneCount + 1
            end
        end
        return {chips = (joker.ability.extra or 25) * stoneCount}
    end
end

