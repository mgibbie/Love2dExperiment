-- Joker handler for j_constellation
return function(joker, state, ctx, CONTEXT, Scoring)
if ctx.type == CONTEXT.JOKER_MAIN then
            local xm = joker.ability.Xmult or 1
            if xm > 1 then
                return {xmult = xm}
            end
        end
end