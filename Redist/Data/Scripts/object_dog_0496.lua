--- Best guess: Manages a dog NPC's interaction, displaying friendly barks (“Arf” or “Bark”) randomly or a greeting (“Good doggy”) when interacted with.
function object_dog_0496(eventid, objectref)
    local var_0000

    if eventid == 1 then
        start_conversation()
        add_dialogue("@Good doggy.@")
        -- calli 001D, 2 (unmapped)
        set_schedule_type(9, objectref)
    elseif eventid == 0 then
        var_0000 = random2(2, 1)
        if var_0000 == 1 then
            bark(objectref, "@Arf@")
        elseif var_0000 == 2 then
            bark(objectref, "@Bark@")
        end
    end
    return
end