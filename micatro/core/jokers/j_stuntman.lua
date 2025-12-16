-- Joker handler for j_stuntman
-- Stuntman: +250 Chips, -2 hand size
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.JOKER_MAIN then
        return {chips = joker.ability.extra and joker.ability.extra.chip_mod or 250}
    end
    -- Hand size reduction is handled by game state
end

