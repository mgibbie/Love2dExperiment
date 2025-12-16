-- Joker handler for j_marble
-- Marble Joker: When Blind is selected, add a Stone card to your deck
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.BLIND_SELECTED then
        return {create_stone_card = true}
    end
end

