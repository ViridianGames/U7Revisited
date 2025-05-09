--- Best guess: Implements the summon spell (Vas Kal), spawning a creature with visual effects.
function func_0647(eventid, itemref)
    local var_0000

    if eventid == 1 then
        destroy_item(itemref)
        bark(itemref, "@Vas Kal@")
        if check_spell_requirements() then
            var_0000 = add_container_items(itemref, {62, 17496, 17514, 7785})
        else
            var_0000 = add_container_items(itemref, {1542, 17493, 17514, 7785})
        end
    end
end