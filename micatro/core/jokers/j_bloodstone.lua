-- Joker handler for j_bloodstone
-- Bloodstone: 1 in 2 chance for played Hearts to give X1.5 Mult
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.CARD_SCORED and ctx.card then
        if ctx.card.suit == "Hearts" then
            local odds = joker.ability.extra and joker.ability.extra.odds or 2
            if math.random(odds) == 1 then
                return {xmult = joker.ability.extra and joker.ability.extra.Xmult or 1.5}
            end
        end
    end
end

