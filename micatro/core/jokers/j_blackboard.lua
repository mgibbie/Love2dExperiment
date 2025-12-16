-- Joker handler for j_blackboard
return function(joker, state, ctx, CONTEXT, Scoring)
if ctx.type == CONTEXT.JOKER_MAIN then
            local allBlack = true
            for _, card in ipairs(state.hand) do
                if card.suit ~= "Spades" and card.suit ~= "Clubs" and card.enhancement ~= "m_wild" then
                    allBlack = false
                    break
                end
            end
            if allBlack and #state.hand > 0 then
                return {xmult = joker.ability.extra or 3}
            end
        end
end