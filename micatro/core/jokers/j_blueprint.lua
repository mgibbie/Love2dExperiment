-- Joker handler for j_blueprint
-- Blueprint: Copies ability of Joker to the right
return function(joker, state, ctx, CONTEXT, Scoring)
    -- Find joker to the right
    local myIndex = nil
    for i, j in ipairs(state.jokers or {}) do
        if j == joker then
            myIndex = i
            break
        end
    end
    
    if myIndex and state.jokers[myIndex + 1] then
        local otherJoker = state.jokers[myIndex + 1]
        -- Copy the other joker's effect (handled by main system)
        return {blueprint_copy = otherJoker}
    end
end

