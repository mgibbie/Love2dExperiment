-- Joker handler for j_mr_bones
-- Mr. Bones: Prevents death if chips scored are at least 25% of required, then destroys itself
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.END_OF_ROUND and ctx.game_over then
        local required = state.blind_chips or 0
        local scored = state.chips or 0
        if required > 0 and scored >= required * 0.25 then
            return {
                prevent_death = true,
                destroy = true,
                message = "Saved!"
            }
        end
    end
end

