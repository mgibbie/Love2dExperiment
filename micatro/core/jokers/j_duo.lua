-- Joker handler for j_duo
-- The Duo: X2 Mult if played hand contains a Pair
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.JOKER_MAIN then
        local hand = ctx.hand_name or ""
        if hand == "Pair" or hand == "Two Pair" or hand == "Full House" 
           or hand == "Three of a Kind" or hand == "Four of a Kind" then
            return {xmult = joker.ability.x_mult or 2}
        end
    end
end
