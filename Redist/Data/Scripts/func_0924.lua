--- Best guess: Similar to func_0923, handles spell purchase with slight dialogue variation.
function func_0924(eventid, itemref, arg1, arg2)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    start_conversation()
    var_0002 = check_item_ownership(359, 644, 359, 357) --- Guess: Checks item ownership
    add_dialogue("@To be agreeable?@")
    if not get_dialogue_choice() then --- Guess: Gets dialogue choice
        var_0003 = 0
    else
        if var_0002 >= arg1 then
            var_0004 = check_inventory_space(359, 761, 359, 357) --- Guess: Checks inventory space
            if var_0004 then
                if add_spell_to_spellbook(var_0004, 0, arg2) then --- Guess: Adds spell to spellbook
                    var_0003 = 1
                    remove_item_from_inventory(true, 359, 644, arg1, 359) --- Guess: Removes item from inventory
                else
                    var_0003 = 4
                end
            else
                var_0003 = 2
            end
        else
            var_0003 = 3
        end
    end
    return var_0003
end