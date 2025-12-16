-- Joker handler for j_trousers
-- Spare Trousers: Gains +2 Mult if played hand contains Two Pair
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.JOKER_MAIN then
        return {mult = joker.ability.mult or 0}
    elseif ctx.type == CONTEXT.HAND_PLAYED then
        local hand = ctx.hand_name or ""
        if hand == "Two Pair" or hand == "Full House" then
            joker.ability.mult = (joker.ability.mult or 0) + (joker.ability.extra or 2)
        end
    end
end
