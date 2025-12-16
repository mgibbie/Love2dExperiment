-- Joker handler for j_abstract
return function(joker, state, ctx, CONTEXT, Scoring)
if ctx.type == CONTEXT.JOKER_MAIN then
            local jokerCount = #state.jokers or 0
            return {mult = (joker.ability.extra or 3) * jokerCount}
        end
end