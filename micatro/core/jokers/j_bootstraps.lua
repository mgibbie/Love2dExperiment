-- Joker handler for j_bootstraps
-- Bootstraps: +2 Mult for every $5 you have
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.JOKER_MAIN then
        local money = state.money or 0
        local multPer = joker.ability.extra and joker.ability.extra.mult or 2
        local dollarsPer = joker.ability.extra and joker.ability.extra.dollars or 5
        local mult = multPer * math.floor(money / dollarsPer)
        if mult > 0 then
            return {mult = mult}
        end
    end
end

