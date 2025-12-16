-- Joker handler for j_certificate
-- Certificate: At start of round, add a random playing card with a random seal to hand
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.BLIND_SELECTED or ctx.type == "first_hand_drawn" then
        return {create_random_card_with_seal = true}
    end
end

