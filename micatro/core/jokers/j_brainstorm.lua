-- Joker handler for j_brainstorm
-- Brainstorm: Copies ability of leftmost Joker
return function(joker, state, ctx, CONTEXT, Scoring)
    if state.jokers and #state.jokers > 0 then
        local leftmost = state.jokers[1]
        if leftmost and leftmost ~= joker then
            -- Copy the leftmost joker's effect (handled by main system)
            return {brainstorm_copy = leftmost}
        end
    end
end

