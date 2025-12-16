-- Joker handler for j_ceremonial
-- Ceremonial Dagger: When Blind is selected, destroy Joker to the right 
-- and permanently add double its sell value to this Mult
return function(joker, state, ctx, CONTEXT, Scoring)
    if ctx.type == CONTEXT.JOKER_MAIN then
        if joker.ability.mult and joker.ability.mult > 0 then
            return {mult = joker.ability.mult}
        end
    elseif ctx.type == CONTEXT.BLIND_SELECTED then
        -- Find joker to the right and destroy it
        return {ceremonial_trigger = true}
    end
end

