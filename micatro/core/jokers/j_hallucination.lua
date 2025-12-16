-- Joker handler for j_hallucination
-- Hallucination: 1 in 2 chance to create Tarot when opening Booster Pack
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.PACK_OPENED then
        local odds = joker.ability.extra or 2
        if math.random(odds) == 1 then
            return {create_tarot = true}
        end
    end
end

