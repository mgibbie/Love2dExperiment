-- Joker handler for j_mystic_summit
return function(joker, state, ctx, CONTEXT, Scoring)
if ctx.type == CONTEXT.JOKER_MAIN then
            if state.discards_remaining == 0 then
                return {mult = joker.ability.extra and joker.ability.extra.mult or 15}
            end
        end
end