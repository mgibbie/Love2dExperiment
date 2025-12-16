-- Joker handler for j_faceless
-- Faceless Joker: Earn $5 if 3+ face cards are discarded at once
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.DISCARD then
        local faceCount = 0
        if ctx.discarded_cards then
            for _, card in ipairs(ctx.discarded_cards) do
                if Scoring.isFaceCard(card) then
                    faceCount = faceCount + 1
                end
            end
        end
        local required = joker.ability.extra and joker.ability.extra.faces or 3
        if faceCount >= required then
            return {dollars = joker.ability.extra and joker.ability.extra.dollars or 5}
        end
    end
end

