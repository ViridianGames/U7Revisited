--- Best guess: Manages a cat NPC's interaction, displaying a player taunt (“Here kitty, kitty”), a hostile reaction (“I hate cats”) if a specific NPC is in the party, or a meow sound.
function object_unknown_0495(eventid, objectref)
    local var_0000

    if eventid == 1 then
        start_conversation()
        add_dialogue("@Here kitty, kitty@")
        -- calli 001D, 2 (unmapped)
        set_schedule_type(0, objectref)
        -- calli 004B, 2 (unmapped)
        set_attack_mode(7, objectref)
        -- calli 004C, 2 (unmapped)
        set_oppressor(356, objectref)
        if not npc_in_party(3) then
            var_0000 = delayed_execute_usecode_array({4, "@I hate cats.@", {17490, 7715}}, 3)
        end
    elseif eventid == 0 then
        bark(objectref, "@Meow@")
    end
    return
end