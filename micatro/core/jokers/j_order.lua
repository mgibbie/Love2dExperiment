-- Joker handler for j_order
-- The Order: X3 Mult if played hand contains a Straight
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.JOKER_MAIN then
        local hand = ctx.hand_name or ""
        if hand == "Straight" or hand == "Straight Flush" then
            return {xmult = joker.ability.x_mult or 3}
        end
    end
end
