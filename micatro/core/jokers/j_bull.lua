-- Joker handler for j_bull
return function(joker, state, ctx, CONTEXT, Scoring)
if ctx.type == CONTEXT.JOKER_MAIN then
            return {chips = (joker.ability.extra or 2) * (state.money or 0)}
        end
end