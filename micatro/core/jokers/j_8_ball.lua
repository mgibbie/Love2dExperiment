-- Joker handler for j_8_ball
-- 8 Ball: 1 in 4 chance for each 8 played to create a Tarot card
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.CARD_SCORED and ctx.card then
        local odds = joker.ability.extra or 4
        if ctx.card.rank == "8" and math.random(odds) == 1 then
            return {create_tarot = true}
        end
    end
end

