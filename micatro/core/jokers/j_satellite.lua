-- Joker handler for j_satellite
-- Satellite: Earn $1 at end of round per unique Planet card used this run
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.END_OF_ROUND then
        local planetCount = 0
        if state.consumeable_usage then
            for _, usage in pairs(state.consumeable_usage) do
                if usage.set == "Planet" then
                    planetCount = planetCount + 1
                end
            end
        end
        if planetCount > 0 then
            return {dollars = (joker.ability.extra or 1) * planetCount}
        end
    end
end

