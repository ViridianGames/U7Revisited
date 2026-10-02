--- Best guess: Manages a ring of invisibility, toggling invisibility status for the wearer based on equip/unequip events.
function object_unknown_0296(eventid, objectref)
    local var_0000

    if eventid == 5 or eventid == 6 then
        var_0000 = get_container(objectref)
        while var_0000 ~= 0 and not is_npc(var_0000) do
            var_0000 = get_container(var_0000)
        end
        if var_0000 == 0 then
            flash_mouse(0)
        end
        if eventid == 5 then
            set_item_flag(0, var_0000)
        elseif eventid == 6 then
            clear_item_flag(0, var_0000)
        end
    end
end