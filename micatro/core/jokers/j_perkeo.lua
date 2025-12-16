-- Joker handler for j_perkeo (Legendary)
-- Perkeo: Creates a Negative copy of 1 random consumable card when leaving shop
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.SHOP_ENTERED then
        -- Handled when leaving shop
    elseif ctx.type == "ending_shop" then
        return {duplicate_random_consumable_negative = true}
    end
end
