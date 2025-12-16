-- Joker handler for j_to_the_moon
-- To the Moon: Earn $1 interest per $5 held at end of round (max $5)
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.END_OF_ROUND then
        local interest = math.floor((state.money or 0) / 5)
        interest = math.min(interest, 5) -- Max $5 interest
        if interest > 0 then
            return {dollars = interest}
        end
    end
end

