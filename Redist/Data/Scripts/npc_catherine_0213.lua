--- Best guess: Manages Catherine's dialogue in Vesper, a young girl who idolizes the Avatar and has secret interactions with a gargoyle, For-Lem.
function npc_catherine_0213(eventid, objectref)
    local var_0000, var_0001, var_0002

    if eventid == 1 then
        switch_talk_to(0, 213)
        var_0000 = get_lord_or_lady()
        start_conversation()
        add_answer({"bye", "job", "name"})
        var_0001 = npc_id_in_party(214)
        if var_0001 then
            add_answer("gargoyle")
            remove_answer("gargoyle")
            add_answer("For-Lem")
        elseif not get_flag(645) then
            add_answer("gargoyle")
        end
        if not get_flag(658) then
            add_dialogue("You see before you a young girl with a carefree expression. As she notices you, her eyes grow wide as she exclaims, \"Thou art the person in one of For... one of -my- story books! Thou art the Avatar!\"")
            set_flag(658, true)
        else
            add_dialogue("\"How dost thou do, \" .. var_0000 .. \" Avatar?\" She curtseys.")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"My name is Catherine, \" .. var_0000 .. \" Avatar.\"")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"I have no job, \" .. var_0000 .. \" Avatar. I live with my father and mother here in Vesper.\"")
                add_answer({"Vesper", "mother", "father"})
            elseif answer == "father" then
                add_dialogue("\"He is the overseer at the mines, \" .. var_0000 .. \" Avatar.\"")
                var_0002 = is_dead(get_npc_name(203))
                if var_0002 then
                    add_dialogue("\"Of course, he's gone now...\" She looks down at her feet.")
                end
                remove_answer("father")
            elseif answer == "mother" then
                add_dialogue("\"Yes, \" .. var_0000 .. \" Avatar. She is there right now.\" She points, apparently indicating her house.")
                remove_answer("mother")
            elseif answer == "Vesper" then
                add_dialogue("\"That is the name of our city, \" .. var_0000 .. \" Avatar. If thou art lost, thou mayest wish to speak with the town clerk.\"")
                remove_answer("Vesper")
            elseif answer == "gargoyle" then
                add_dialogue("\"I'm sorry, \" .. var_0000 .. \" Avatar, my mother told me never to speak with strangers.\" She quickly turns away.")
                return
            elseif answer == "For-Lem" then
                add_dialogue("A tear glistens as it rolls gently down her cheek. \"He is no more. My -- my father killed him for talking to me, and -- and 'tis all thy fault!\" She turns away, sobbing.")
                return
            elseif answer == "bye" then
                add_dialogue("\"Goodbye, \" .. var_0000 .. \" Avatar.\"")
                break
            end
        end
    elseif eventid == 0 then
        return
    end
    return
end