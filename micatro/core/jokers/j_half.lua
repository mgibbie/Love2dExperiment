-- Joker handler for j_half
return function(joker, state, ctx, CONTEXT, Scoring)
if ctx.type == CONTEXT.HAND_PLAYED then
            if ctx.cards_played and ctx.cards_played <= (joker.ability.extra and joker.ability.extra.size or 3) then
                return {mult = joker.ability.extra and joker.ability.extra.mult or 20}
            end
        end
end