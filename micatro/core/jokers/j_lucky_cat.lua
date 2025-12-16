-- Joker handler for j_lucky_cat
-- Lucky Cat: Gains X0.25 Mult each time a Lucky card triggers
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.JOKER_MAIN then
        local xm = joker.ability.x_mult or 1
        if xm > 1 then
            return {xmult = xm}
        end
    elseif ctx.type == CONTEXT.CARD_SCORED and ctx.card then
        if ctx.card.lucky_trigger then
            joker.ability.x_mult = (joker.ability.x_mult or 1) + (joker.ability.extra or 0.25)
        end
    end
end

