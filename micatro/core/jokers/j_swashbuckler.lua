-- Joker handler for j_swashbuckler
-- Swashbuckler: +Mult equal to the total sell value of all owned Jokers
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.JOKER_MAIN then
        local totalSellValue = 0
        for _, j in ipairs(state.jokers or {}) do
            totalSellValue = totalSellValue + (j.sell_value or 0)
        end
        return {mult = totalSellValue}
    end
end

