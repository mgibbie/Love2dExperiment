-- Joker handler for j_rocket
-- Rocket: Earn $1 at end of round. Payout increases by $2 when Boss Blind is defeated
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.END_OF_ROUND then
        local payout = joker.ability.extra and joker.ability.extra.dollars or 1
        if ctx.boss_defeated then
            joker.ability.extra = joker.ability.extra or {dollars = 1, increase = 2}
            joker.ability.extra.dollars = joker.ability.extra.dollars + joker.ability.extra.increase
        end
        return {dollars = payout}
    end
end

