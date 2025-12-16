-- Joker handler for j_flower_pot
-- Flower Pot: X3 Mult if hand has Diamond, Club, Heart, and Spade
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.JOKER_MAIN then
        local suits = {Hearts = false, Diamonds = false, Clubs = false, Spades = false}
        if ctx.scoring_cards then
            for _, card in ipairs(ctx.scoring_cards) do
                if suits[card.suit] ~= nil then
                    suits[card.suit] = true
                end
            end
        end
        if suits.Hearts and suits.Diamonds and suits.Clubs and suits.Spades then
            return {xmult = joker.ability.extra or 3}
        end
    end
end

