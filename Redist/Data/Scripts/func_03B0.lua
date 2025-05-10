--- Best guess: Triggers an NPC (ID 356) to spit and react, possibly a humorous or environmental interaction.
function func_03B0(eventid, objectref)
    local var_0000

    if eventid == 1 then
        if get_object_frame(objectref) == 0 and not unknown_0937H(356) then
            bark(356, "ptui!")
            if not unknown_0081H() then
                var_0000 = unknown_0002H({3, 24, 7768}, objectref)
            end
        end
    end
    return
end