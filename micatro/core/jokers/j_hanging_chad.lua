-- Joker handler for j_hanging_chad
-- Hanging Chad: Retrigger first played card 2 additional times
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.CARD_SCORED and ctx.cardarea == "play" and ctx.card then
        -- Check if this is the first card in scoring hand
        if ctx.scoring_cards and ctx.scoring_cards[1] == ctx.card then
            return {
                repetitions = joker.ability.extra or 2,
                message = "Again!"
            }
        end
    end
end

