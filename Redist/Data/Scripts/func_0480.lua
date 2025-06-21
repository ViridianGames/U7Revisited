--- Best guess: Handles dialogue with Iriale Silvermist, a guard at the Meditation Retreat, enforcing the rule against entering a restricted cave, threatening combat, and reacting to mentions of Gorn.
function func_0480(eventid, objectref)
    local var_0000, var_0001, var_0002

    start_conversation()
    if eventid == 0 then
        abort()
    end
    switch_talk_to(128, 0)
    var_0000 = get_player_name()
    add_answer({"bye", "job", "name"})
    if not get_flag(699) then
        add_answer("Gorn")
    end
    if not get_flag(716) then
        add_dialogue("You see a striking woman in fighter's gear. She looks at you fiercely.")
        add_dialogue("\"Halt!\"")
        set_flag(716, true)
    else
        add_dialogue("\"What dost thou want?\" Iriale demands.")
    end
    while true do
        var_0001 = get_answer()
        if var_0001 == "name" then
            add_dialogue("\"I am called Iriale Silvermist. Who art thou?\"")
            var_0002 = ask_answer({"The Avatar", var_0000})
            if var_0002 == var_0000 then
                add_dialogue("\"I do not know thee!\"")
            elseif var_0002 == "The Avatar" then
                add_dialogue("\"I do not approve of jokes.\"")
            end
            remove_answer("name")
        elseif var_0001 == "job" then
            add_dialogue("Iriale smiles devilishly.")
            add_dialogue("\"I bar people from entering. Thou hast disobeyed the rule of the Meditation Retreat. Ian will be most displeased. Thou had best leave now.\"")
            add_answer({"Meditation Retreat", "rule"})
        elseif var_0001 == "rule" then
            add_dialogue("\"Thou dost know it. Attendees of the Retreat must stay out of this cave.\"")
            remove_answer("rule")
            var_0002 = npc_id_in_party(1) --- Guess: Checks player status
            if var_0002 then
                switch_talk_to(1, 0)
                add_dialogue("\"Come, " .. var_0000 .. ", we had better leave. I believe this woman is serious.\"")
                hide_npc(1)
                switch_talk_to(128, 0)
            end
        elseif var_0001 == "Gorn" then
            add_dialogue("\"Is that the name of that smelly barbarian who was here? If thou dost see him on the -way out-, tell him that if he approaches me again, I shall cut off his head!\"")
            remove_answer("Gorn")
        elseif var_0001 == "Meditation Retreat" then
            add_dialogue("\"Yes, I work for the Meditation Retreat.\"")
            add_dialogue("\"And I work for -him-. -He- does not want thee here. I give thee only one chance to turn around and leave.\"")
            add_dialogue("\"Wilt thou leave?\"")
            if select_option() then
                add_dialogue("\"Do so and I shall spare thee!\" She watches as you turn away.")
                unknown_001DH(7, get_npc_name(128)) --- Guess: Sets object behavior
                abort()
            else
                add_dialogue("She sees your jaw set with determination and nods her head. \"Then die, foolish one!\"")
                unknown_001DH(0, get_npc_name(128)) --- Guess: Sets object behavior
                abort()
            end
        elseif var_0001 == "bye" then
            break
        end
    end
    add_dialogue("\"Away with thee!\"")
    unknown_001DH(7, get_npc_name(128)) --- Guess: Sets object behavior
end