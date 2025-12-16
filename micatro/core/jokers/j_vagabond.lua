-- Joker handler for j_vagabond
-- Vagabond: Create a Tarot card if hand is played with $4 or less
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.HAND_PLAYED then
        if (state.money or 0) <= (joker.ability.extra or 4) then
            return {create_tarot = true}
        end
    end
end
