-- Joker handler for j_dusk
-- Dusk: Retrigger all played cards on final hand of round
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.CARD_SCORED and ctx.cardarea == "play" then
        if state.hands_remaining == 0 then
            return {
                repetitions = joker.ability.extra or 1,
                message = "Again!"
            }
        end
    end
end

