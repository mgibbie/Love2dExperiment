-- Joker handler for j_greedy_joker
return function(joker, state, ctx, CONTEXT, Scoring)
if ctx.type == CONTEXT.CARD_SCORED and ctx.card then
            if ctx.card.suit == "Diamonds" or ctx.card.enhancement == "m_wild" then
                return {mult = joker.ability.extra and joker.ability.extra.s_mult or 3}
            end
        end
end