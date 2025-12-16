-- Joker handler for j_baseball
return function(joker, state, ctx, CONTEXT, Scoring)
if ctx.type == CONTEXT.JOKER_MAIN then
            local uncommonCount = 0
            for _, j in ipairs(state.jokers) do
                if j.data and j.data.rarity == 2 then
                    uncommonCount = uncommonCount + 1
                end
            end
            if uncommonCount > 0 then
                local xm = 1
                for i = 1, uncommonCount do
                    xm = xm * (joker.ability.extra or 1.5)
                end
                return {xmult = xm}
            end
        end
end