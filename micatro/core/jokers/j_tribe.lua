-- Joker handler for j_tribe
-- The Tribe: X2 Mult if played hand contains a Flush
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.JOKER_MAIN then
        local hand = ctx.hand_name or ""
        if hand == "Flush" or hand == "Straight Flush" or hand == "Flush Five" 
           or hand == "Flush House" then
            return {xmult = joker.ability.x_mult or 2}
        end
    end
end
