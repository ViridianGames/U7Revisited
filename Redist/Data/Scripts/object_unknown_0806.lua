--- Best guess: Manages dialogue with a Trinsic guard, requiring a password (Blackbird) to pass, with quest-related flag checks.
function object_unknown_0806(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 0 then
        abort()
    end
    var_0000 = get_schedule_type(get_npc_name(objectref))
    switch_talk_to(259, 0)
    add_answer({"bye", "job", "name"})
    if not get_flag(61) then
        add_answer("password")
    end
    add_dialogue("You see a tough-looking guard who takes his job -very- seriously.")
    while true do
        var_0002 = _AskAnswer()
        if var_0002 == "name" then
            add_dialogue("\"My name is not important.\"")
            remove_answer("name")
        elseif var_0002 == "job" then
            add_dialogue("\"I keep villains and knaves out of Trinsic and keep a record of all who leave. Thou must have a password to leave.\"")
            add_answer("password")
        elseif var_0002 == "password" then
            add_dialogue("\"What is the password?\"")
            var_0001 = {"Please", "Long live the king", "Uhh, I don't know"}
            if not get_flag(61) then
                table.insert(var_0001, "Blackbird")
            end
            var_0002 = utility_unknown_1035(var_0001)
            if var_0002 == "Blackbird" then
                var_0003 = utility_unknown_0820()
                set_flag(61, true)
                if var_0003 then
                    add_dialogue("\"Very well, thou mayest pass.\"")
                    abort()
                end
            else
                add_dialogue("\"Thou dost not know the password. Sorry. The Mayor can give thee the proper password.\"")
                set_flag(66, true)
            end
        elseif var_0002 == "bye" then
            break
        end
    end
    add_dialogue("\"Goodbye.\"")
end