-- Joker handler for j_card_sharp
return function(joker, state, ctx, CONTEXT, Scoring)
if ctx.type == CONTEXT.HAND_PLAYED then
            local roundPlays = state.hands_played_round[ctx.hand_name] or 0
            if roundPlays >= 2 then
                return {xmult = joker.ability.extra and joker.ability.extra.Xmult or 3}
            end
        end
end