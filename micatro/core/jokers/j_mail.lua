-- Joker handler for j_mail
-- Mail-In Rebate: Earn $5 for each discarded card of the current rank (changes each round)
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.DISCARD and ctx.card then
        local targetRank = state.mail_card_rank or "2"
        if ctx.card.rank == targetRank then
            return {dollars = joker.ability.extra or 5}
        end
    elseif ctx.type == CONTEXT.END_OF_ROUND then
        -- Change target rank for next round
        local ranks = {"2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"}
        state.mail_card_rank = ranks[math.random(#ranks)]
    end
end

