--- Best guess: Implements the dance spell (Por Xen), causing nearby NPCs to dance with random exclamations.
function utility_spell_0361(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A

    if eventid == 1 then
        destroy_object(objectref)
        bark(objectref, "@Por Xen@")
        if check_spell_requirements() then
            var_0000 = add_containerobject_s(objectref, {1641, 17493, 17514, 17520, 8037, 67, 7768})
            bark(objectref, "@Everybody DANCE now!@")
        else
            var_0000 = add_containerobject_s(objectref, {1542, 17493, 17514, 17520, 7781})
        end
    elseif eventid == 2 then
        var_0001 = 25
        var_0002 = get_nearby_npcs(var_0001) --- Guess: Gets nearby NPCs
        -- Guess: sloop triggers dance for NPCs
        for i = 1, 5 do
            var_0005 = ({3, 4, 5, 2, 198})[i]
            if not (var_0005 == var_0002[1] or var_0005 == var_0002[2]) then --  or ...
                var_0006 = get_npc_property(2, var_0005) --- Guess: Gets NPC property
                if var_0006 > 5 and var_0006 < 25 then
                    var_0007 = get_object_position(var_0005) --- Guess: Gets position data
                    apply_sprite_effect(-1, 0, 0, 0, var_0007[2], var_0007[1], 16) --- Guess: Applies sprite effect
                    update_npc_state(4, var_0005) --- Guess: Updates NPC state
                    set_object_flag(var_0005, 15)
                    var_0008 = {"@Yow!@", "@Boogie!@", "@I'm bad!@", "@Oh, yeah!@", "@Huh!@", "@Yeah!@", "@Dance!@"}
                    var_0009 = random(1, 7)
                    var_000A = random(10, 40)
                    npc_add_dialogue(var_0005, var_0008[var_0009]) --- Guess: NPC says random phrase
                    var_0000 = add_containerobject_s(var_0005, {var_000A, 1672, 17493, 7715})
                end
            end
        end
    end
end