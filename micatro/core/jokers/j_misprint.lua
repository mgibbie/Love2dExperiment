-- Joker handler for j_misprint
return function(joker, state, ctx, CONTEXT, Scoring)
if ctx.type == CONTEXT.JOKER_MAIN then
            local min = joker.ability.extra and joker.ability.extra.min or 0
            local max = joker.ability.extra and joker.ability.extra.max or 23
            return {mult = math.random(min, max)}
        end
end