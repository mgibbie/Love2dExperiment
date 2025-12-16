-- Joker handler for j_hit_the_road
-- Hit the Road: Gains X0.5 Mult for each Jack discarded this round, resets each round
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.JOKER_MAIN then
        local xm = joker.ability.x_mult or 1
        if xm > 1 then
            return {xmult = xm}
        end
    elseif ctx.type == CONTEXT.DISCARD and ctx.card then
        if ctx.card.rank == "J" then
            joker.ability.x_mult = (joker.ability.x_mult or 1) + (joker.ability.extra or 0.5)
        end
    elseif ctx.type == CONTEXT.END_OF_ROUND then
        joker.ability.x_mult = 1
    end
end

