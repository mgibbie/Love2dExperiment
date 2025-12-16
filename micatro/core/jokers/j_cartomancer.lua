-- Joker handler for j_cartomancer
-- Cartomancer: Create Tarot card when Blind is selected
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.BLIND_SELECTED then
        return {create_tarot = true}
    end
end

