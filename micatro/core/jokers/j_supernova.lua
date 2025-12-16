-- Joker handler for j_supernova
return function(joker, state, ctx, CONTEXT, Scoring)
if ctx.type == CONTEXT.HAND_PLAYED then
            local count = state.hands_played[ctx.hand_name] or 0
            return {mult = count}
        end
end