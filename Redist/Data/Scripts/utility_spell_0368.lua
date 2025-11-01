--- Best guess: Implements the detect spell (Quas Wis), revealing NPC properties or states for party members.
function utility_spell_0368(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid == 1 then
        destroyobject_(objectref)
        bark(objectref, "@Quas Wis@")
        if check_spell_requirements() then
            var_0000 = add_containerobject_s(objectref, {1648, 17493, 17511, 17509, 17510, 17505, 8045, 65, 7768})
        else
            var_0000 = add_containerobject_s(objectref, {1542, 17493, 17511, 17509, 17510, 17505, 7789})
        end
    elseif eventid == 2 then
        var_0001 = find_nearby(8, 25, -1, objectref) --- Guess: Sets NPC location
        var_0002 = get_party_members()
        -- Guess: sloop reveals NPC properties
        for i = 1, 5 do
            var_0005 = ({3, 4, 5, 1, 62})[i]
            if not (var_0005 == var_0002[1] or var_0005 == var_0002[2]) then --  or ...
                if get_npc_property(2, var_0005) > 5 then
                    set_schedule_type(0, var_0005) --- Guess: Sets object behavior
                    set_npc_behavior(7, var_0005) --- Guess: Sets NPC behavior
                    get_avatar_ref() --- Guess: Resets dialogue state
                    set_npc_state(7, var_0005) --- Guess: Sets NPC state
                end
            end
        end
    end
end