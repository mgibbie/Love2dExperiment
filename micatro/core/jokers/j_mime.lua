-- Joker handler for j_mime
-- Mime: Retrigger all card held in hand abilities
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.CARD_SCORED and ctx.cardarea == "hand" then
        -- Retrigger held card effects
        if ctx.card_effects and (next(ctx.card_effects[1]) or #ctx.card_effects > 1) then
            return {
                repetitions = joker.ability.extra or 1,
                message = "Again!"
            }
        end
    end
end

