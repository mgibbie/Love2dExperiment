-- Joker handler for j_dna
-- DNA: If first hand of round has only 1 card, add a permanent copy to deck
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.HAND_PLAYED then
        if state.hands_played_round == 0 and ctx.cards_played == 1 then
            return {copy_card_to_deck = true}
        end
    end
end

