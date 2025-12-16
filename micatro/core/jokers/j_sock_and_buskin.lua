-- Joker handler for j_sock_and_buskin
-- Sock and Buskin: Retrigger all played face cards
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.CARD_SCORED and ctx.cardarea == "play" and ctx.card then
        if Scoring.isFaceCard(ctx.card) then
            return {
                repetitions = joker.ability.extra or 1,
                message = "Again!"
            }
        end
    end
end

