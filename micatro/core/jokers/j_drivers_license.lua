-- Joker handler for j_drivers_license
-- Driver's License: X3 Mult if you have at least 16 Enhanced cards in deck
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.JOKER_MAIN then
        local enhancedCount = 0
        for _, card in ipairs(state.deck or {}) do
            if card.enhancement and card.enhancement ~= "none" then
                enhancedCount = enhancedCount + 1
            end
        end
        if enhancedCount >= 16 then
            return {xmult = joker.ability.extra or 3}
        end
    end
end

