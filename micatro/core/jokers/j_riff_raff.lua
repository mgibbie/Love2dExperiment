-- Joker handler for j_riff_raff
-- Riff-raff: When Blind is selected, create 2 Common Jokers
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.BLIND_SELECTED then
        return {create_common_jokers = joker.ability.extra or 2}
    end
end

