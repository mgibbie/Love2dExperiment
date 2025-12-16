-- Joker handler for j_todo_list
-- To Do List: Earn $4 if poker hand is the listed hand, hand changes each round
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.HAND_PLAYED then
        local targetHand = joker.ability.to_do_poker_hand or "Pair"
        if ctx.hand_name == targetHand then
            return {dollars = joker.ability.extra and joker.ability.extra.dollars or 4}
        end
    elseif ctx.type == CONTEXT.END_OF_ROUND then
        -- Change target hand for next round
        local hands = {"High Card", "Pair", "Two Pair", "Three of a Kind", "Straight", "Flush", "Full House", "Four of a Kind"}
        joker.ability.to_do_poker_hand = hands[math.random(#hands)]
    end
end

