-- Joker handler for j_steel_joker
return function(joker, state, ctx, CONTEXT, Scoring)
if ctx.type == CONTEXT.JOKER_MAIN then
            local steelCount = 0
            for _, card in ipairs(state.deck) do
                if card.enhancement == "m_steel" then
                    steelCount = steelCount + 1
                end
            end
            if steelCount > 0 then
                return {xmult = 1 + (joker.ability.extra or 0.2) * steelCount}
            end
        end
end