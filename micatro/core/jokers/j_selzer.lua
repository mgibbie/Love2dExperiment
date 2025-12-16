-- Joker handler for j_selzer
-- Seltzer: Retrigger all played cards for the next 10 hands
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.CARD_SCORED and ctx.cardarea == "play" then
        if joker.ability.extra and joker.ability.extra > 0 then
            return {
                repetitions = 1,
                message = "Again!"
            }
        end
    elseif ctx.type == CONTEXT.HAND_PLAYED then
        joker.ability.extra = (joker.ability.extra or 10) - 1
        if joker.ability.extra <= 0 then
            return {destroy = true, message = "Drank!"}
        end
    end
end

