--- Best guess: Spawns an item (type 981) with positioning, likely for an event trigger.
function func_0807(eventid, objectref)
    local var_0000, var_0001, var_0002

    var_0000 = objectref
    if not get_flag(5) then
        set_object_type(981, var_0000) --- Guess: Sets item type
        var_0001 = {0, 2784, 1767}
        unknown_003EH(var_0001, var_0000) --- Guess: Sets NPC target
        var_0001[2] = var_0001[2] + 2
        unknown_003EH(var_0001, 356) --- Guess: Sets NPC target
        calle_0808H() --- External call to party management
        var_0002 = add_containerobject_s_at(356, {8, 1565, 17493, 7715})
        set_flag(5, true)
    end
end