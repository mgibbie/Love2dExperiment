-- Joker handler for j_stencil
return function(joker, state, ctx, CONTEXT, Scoring)
if ctx.type == CONTEXT.JOKER_MAIN then
            local emptySlots = state.joker_slots - #state.jokers
            if emptySlots > 0 then
                return {xmult = 1 + emptySlots}
            end
        end
end