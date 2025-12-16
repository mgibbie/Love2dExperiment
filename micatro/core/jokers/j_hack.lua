-- Joker handler for j_hack
-- Hack: Retrigger each played 2, 3, 4, or 5
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.CARD_SCORED and ctx.card and ctx.cardarea == "play" then
        local rank = ctx.card.rank
        if rank == "2" or rank == "3" or rank == "4" or rank == "5" then
            return {
                repetitions = joker.ability.extra or 1,
                message = "Again!"
            }
        end
    end
end

