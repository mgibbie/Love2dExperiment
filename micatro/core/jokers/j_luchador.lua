-- Joker handler for j_luchador
-- Luchador: Sell this card to disable current Boss Blind
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.SELL then
        if state.current_blind and state.current_blind.boss then
            return {disable_boss = true}
        end
    end
end

