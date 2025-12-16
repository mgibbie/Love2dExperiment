-- Joker handler for j_erosion
-- Erosion: +4 Mult for each card below starting deck size (52)
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.JOKER_MAIN then
        local startingSize = state.starting_deck_size or 52
        local currentSize = #(state.deck or {})
        local missingCards = math.max(0, startingSize - currentSize)
        if missingCards > 0 then
            return {mult = (joker.ability.extra or 4) * missingCards}
        end
    end
end
