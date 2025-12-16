-- Joker handler for j_matador
-- Matador: Earn $8 if played hand triggers the Boss Blind ability
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.JOKER_MAIN then
        if state.blind_triggered then
            return {dollars = joker.ability.extra or 8}
        end
    end
end

