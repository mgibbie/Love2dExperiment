-- Joker handler for j_flash
-- Flash Card: Gains +2 Mult per reroll in the shop
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.JOKER_MAIN then
        return {mult = joker.ability.mult or 0}
    elseif ctx.type == CONTEXT.REROLL then
        joker.ability.mult = (joker.ability.mult or 0) + (joker.ability.extra or 2)
    end
end
