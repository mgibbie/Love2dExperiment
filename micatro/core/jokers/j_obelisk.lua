-- Joker handler for j_obelisk
-- Obelisk: Gains X0.2 Mult per consecutive hand played that isn't your most played
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.JOKER_MAIN then
        local xm = joker.ability.x_mult or 1
        if xm > 1 then
            return {xmult = xm}
        end
    elseif ctx.type == CONTEXT.HAND_PLAYED then
        local mostPlayed = ""
        local mostCount = 0
        for hand, data in pairs(state.hands or {}) do
            if (data.played or 0) > mostCount then
                mostCount = data.played
                mostPlayed = hand
            end
        end
        
        if ctx.hand_name == mostPlayed then
            joker.ability.x_mult = 1
        else
            joker.ability.x_mult = (joker.ability.x_mult or 1) + (joker.ability.extra or 0.2)
        end
    end
end
