-- Joker handler for j_sixth_sense
-- Sixth Sense: If first hand of round is a single 6, destroy it and create Spectral card
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.HAND_PLAYED then
        if state.hands_played_round == 0 and ctx.cards_played == 1 then
            if ctx.scoring_cards and ctx.scoring_cards[1] and ctx.scoring_cards[1].rank == "6" then
                return {
                    destroy_card = ctx.scoring_cards[1],
                    create_spectral = true
                }
            end
        end
    end
end

