-- Joker handler for j_chicot (Legendary)
-- Chicot: Disables effect of every Boss Blind
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.BLIND_SELECTED then
        if ctx.boss_blind then
            return {disable_boss = true}
        end
    end
end
