-- Joker handler for j_burnt
-- Burnt Joker: If first discard of round upgrades that poker hand
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.DISCARD then
        if state.discards_used_round == 0 then
            return {level_up_hand = ctx.hand_name}
        end
    end
end

