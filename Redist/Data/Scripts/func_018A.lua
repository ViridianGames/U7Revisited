--- Best guess: Manages a palace guard's dialogue, providing minimal responses about name and job, with random movement commands when idle, emphasizing authority.
function func_018A(eventid, objectref)
    start_conversation()
    local var_0000, var_0001, var_0002, var_0003

    var_0000 = unknown_001CH(get_npc_name(394))
    if eventid == 1 then
        switch_talk_to(258, 0)
        add_answer({"bye", "job", "name"})
        add_dialogue("You see a tough-looking palace guard who takes his job -very- seriously.")
        while true do
            local response = string.lower(unknown_XXXXH())
            if response == "name" then
                add_dialogue("\"I am a guard.\"")
                remove_answer("name")
            elseif response == "job" then
                add_dialogue("The man looks at you like you are an ignoramus. \"I am a guard for the palace, idiot. Thou shouldst go about thy business.\"")
            elseif response == "bye" then
                break
            end
        end
        add_dialogue("\"Goodbye.\"")
    elseif eventid == 0 then
        var_0001 = unknown_001CH(get_npc_name(394))
        if var_0001 == 29 then
            var_0002 = math.random(1, 4)
            if var_0002 == 1 then
                var_0003 = "@Move along!@"
            elseif var_0002 == 2 then
                var_0003 = "@Stand aside!@"
            elseif var_0002 == 3 then
                var_0003 = "@Go about thy business!@"
            elseif var_0002 == 4 then
                var_0003 = "@Keep moving!@"
            end
            unknown_0040H(var_0003, 394)
        end
    end
    return
end