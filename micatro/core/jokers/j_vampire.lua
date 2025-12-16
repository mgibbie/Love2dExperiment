-- Joker handler for j_vampire
-- Vampire: Gains X0.1 Mult per Enhanced card played, removes enhancement
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.JOKER_MAIN then
        local xm = joker.ability.x_mult or 1
        if xm > 1 then
            return {xmult = xm}
        end
    elseif ctx.type == CONTEXT.HAND_PLAYED then
        local enhanced = 0
        if ctx.scoring_cards then
            for _, card in ipairs(ctx.scoring_cards) do
                if card.enhancement and card.enhancement ~= "none" then
                    enhanced = enhanced + 1
                    -- Remove enhancement (handled by game state)
                end
            end
        end
        if enhanced > 0 then
            joker.ability.x_mult = (joker.ability.x_mult or 1) + (joker.ability.extra or 0.1) * enhanced
            return {remove_enhancements = true}
        end
    end
end

