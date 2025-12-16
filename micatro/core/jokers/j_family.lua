-- Joker handler for j_family
-- The Family: X4 Mult if played hand contains a Four of a Kind
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.JOKER_MAIN then
        local hand = ctx.hand_name or ""
        if hand == "Four of a Kind" then
            return {xmult = joker.ability.x_mult or 4}
        end
    end
end
