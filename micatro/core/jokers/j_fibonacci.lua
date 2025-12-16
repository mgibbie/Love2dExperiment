-- Joker handler for j_fibonacci
return function(joker, state, ctx, CONTEXT, Scoring)
if ctx.type == CONTEXT.CARD_SCORED and ctx.card then
            local fib = {["A"] = true, ["2"] = true, ["3"] = true, ["5"] = true, ["8"] = true}
            if fib[ctx.card.rank] then
                return {mult = joker.ability.extra or 8}
            end
        end
end