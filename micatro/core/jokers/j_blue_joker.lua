-- Joker handler for j_blue_joker
return function(joker, state, ctx, CONTEXT, Scoring)
if ctx.type == CONTEXT.JOKER_MAIN then
            local deckSize = #state.draw_pile + #state.discard_pile
            return {chips = (joker.ability.extra or 2) * deckSize}
        end
end