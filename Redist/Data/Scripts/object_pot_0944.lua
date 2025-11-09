--- Best guess: Triggers an NPC (ID 356) to spit and react, possibly a humorous or environmental interaction.
function object_pot_0944(eventid, objectref)
    local var_0000

    if eventid == 1 then
        if get_object_frame(objectref) == 0 and not utility_unknown_1079(356) then
            bark(356, "ptui!")
            if not in_gump_mode() then
                var_0000 = delayed_execute_usecode_array({3, 24, 7768}, objectref)
            end
        end
    end
    return
end