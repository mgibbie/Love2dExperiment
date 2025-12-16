-- Joker handler for j_ride_the_bus
return function(joker, state, ctx, CONTEXT, Scoring)
if ctx.type == CONTEXT.JOKER_MAIN then
            return {mult = joker.ability.mult or 0}
        elseif ctx.type == CONTEXT.HAND_PLAYED then
            -- Check if any scoring card is a face
            local hasFace = false
            if ctx.scoring_cards then
                for _, card in ipairs(ctx.scoring_cards) do
                    if Scoring.isFaceCard(card) then
                        hasFace = true
                        break
                    end
                end
            end
            if hasFace then
                joker.ability.mult = 0  -- Reset
            else
                joker.ability.mult = (joker.ability.mult or 0) + 1
            end
        end
end