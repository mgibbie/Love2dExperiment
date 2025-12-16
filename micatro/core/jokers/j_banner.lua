-- Joker handler for j_banner
return function(joker, state, ctx, CONTEXT, Scoring)
if ctx.type == CONTEXT.JOKER_MAIN then
            local discards = state.discards_remaining or 0
            return {chips = (joker.ability.extra or 30) * discards}
        end
end