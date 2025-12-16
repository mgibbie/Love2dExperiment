-- Joker handler for j_red_card
-- Red Card: Gains +3 Mult when any Booster Pack is skipped
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.JOKER_MAIN then
        return {mult = joker.ability.mult or 0}
    elseif ctx.type == CONTEXT.PACK_SKIPPED then
        joker.ability.mult = (joker.ability.mult or 0) + (joker.ability.extra or 3)
        return {message = "Upgrade!"}
    end
end

