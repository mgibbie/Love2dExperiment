-- Joker handler for j_burglar
-- Burglar: When Blind is selected, gain +3 Hands and lose all discards
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.BLIND_SELECTED then
        return {
            extra_hands = joker.ability.extra or 3,
            lose_discards = true
        }
    end
end

