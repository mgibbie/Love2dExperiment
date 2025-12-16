-- Joker handler for j_turtle_bean
-- Turtle Bean: +5 hand size, reduces by 1 each round
return function(joker, state, ctx, CONTEXT, Scoring)
    -- Hand size modifier is applied in game state
    if ctx.type == CONTEXT.END_OF_ROUND then
        joker.ability.extra = joker.ability.extra or {h_size = 5, h_mod = 1}
        joker.ability.extra.h_size = joker.ability.extra.h_size - joker.ability.extra.h_mod
        if joker.ability.extra.h_size <= 0 then
            return {destroy = true, message = "Eaten!"}
        end
        return {reduce_hand_size = joker.ability.extra.h_mod}
    end
end

