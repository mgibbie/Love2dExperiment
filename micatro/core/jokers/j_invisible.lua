-- Joker handler for j_invisible
-- Invisible Joker: After 2 rounds, sell to duplicate random Joker
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.END_OF_ROUND then
        joker.ability.invis_rounds = (joker.ability.invis_rounds or 0) + 1
    elseif ctx.type == CONTEXT.SELL then
        if joker.ability.invis_rounds >= (joker.ability.extra or 2) then
            return {duplicate_random_joker = true}
        end
    end
end

