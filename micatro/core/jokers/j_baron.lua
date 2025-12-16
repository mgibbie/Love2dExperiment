-- Joker handler for j_baron
return function(joker, state, ctx, CONTEXT, Scoring)
if ctx.type == CONTEXT.JOKER_MAIN then
            local kingCount = 0
            for _, card in ipairs(state.hand) do
                if card.rank == "K" then
                    kingCount = kingCount + 1
                end
            end
            if kingCount > 0 then
                local xm = 1
                for i = 1, kingCount do
                    xm = xm * (joker.ability.extra or 1.5)
                end
                return {xmult = xm}
            end
        end
end