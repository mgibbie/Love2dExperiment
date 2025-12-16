-- Joker handler for j_yorick (Legendary)
-- Yorick: Gains X1 Mult every 23 cards discarded, starting at X1
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.JOKER_MAIN then
        local xm = joker.ability.x_mult or 1
        if xm > 1 then
            return {xmult = xm}
        end
    elseif ctx.type == CONTEXT.DISCARD then
        joker.ability.yorick_discards = (joker.ability.yorick_discards or 0) + 1
        local required = joker.ability.extra and joker.ability.extra.discards or 23
        if joker.ability.yorick_discards >= required then
            joker.ability.yorick_discards = 0
            joker.ability.x_mult = (joker.ability.x_mult or 1) + (joker.ability.extra and joker.ability.extra.xmult or 1)
        end
    end
end
