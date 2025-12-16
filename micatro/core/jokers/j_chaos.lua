-- Joker handler for j_chaos
-- Chaos the Clown: 1 free Reroll per shop
-- This is a passive shop effect
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.SHOP_ENTERED then
        return {free_reroll = joker.ability.extra or 1}
    end
end

