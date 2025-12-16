-- Joker handler for j_trio
-- The Trio: X3 Mult if played hand contains a Three of a Kind
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.JOKER_MAIN then
        local hand = ctx.hand_name or ""
        if hand == "Three of a Kind" or hand == "Full House" or hand == "Four of a Kind" then
            return {xmult = joker.ability.x_mult or 3}
        end
    end
end
