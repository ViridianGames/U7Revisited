--- Best guess: Manages a cat NPC’s interaction, displaying a player taunt (“Here kitty, kitty”), a hostile reaction (“I hate cats”) if a specific NPC is in the party, or a meow sound.
function func_01EF(eventid, objectref)
    local var_0000

    if eventid == 1 then
        start_conversation()
        add_dialogue("@Here kitty, kitty@")
        -- calli 001D, 2 (unmapped)
        unknown_001DH(0, objectref)
        -- calli 004B, 2 (unmapped)
        unknown_004BH(7, objectref)
        -- calli 004C, 2 (unmapped)
        unknown_004CH(356, objectref)
        if not npc_in_party(3) then
            var_0000 = unknown_0002H({4, "@I hate cats.@", {17490, 7715}}, 3)
        end
    elseif eventid == 0 then
        bark(objectref, "@Meow@")
    end
    return
end