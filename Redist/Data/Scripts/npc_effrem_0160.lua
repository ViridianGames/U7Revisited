--- Best guess: Manages Effrem's dialogue in Moonglow, discussing his stay-at-home role and wife Jillian, with gender-specific responses.
function npc_effrem_0160(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009

    if eventid == 1 then
        switch_talk_to(0, 160)
        var_0000 = get_player_name()
        var_0001 = get_lord_or_lady()
        var_0002 = "the Avatar"
        var_0003 = is_player_female()
        var_0004 = false
        var_0005 = npc_id_in_party(159)
        if var_0003 then
            var_0006 = "woman"
            var_0007 = "she"
        else
            var_0006 = "man"
            var_0007 = "he"
        end
        if not get_flag(500) then
            var_0008 = var_0000
        else
            var_0008 = var_0001
        end
        start_conversation()
        add_answer({"bye", "job", "name"})
        if not get_flag(514) then
            add_dialogue("You see a man with a sour expression on his face holding a baby boy. As he sees you, his face brightens.")
            set_flag(514, true)
        else
            add_dialogue("\"Hello again, " .. var_0008 .. ". I am here as usual, taking care of little Mikhail.\" Effrem grimaces.")
        end
        while true do
            start_conversation()
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"I am Effrem, " .. var_0001 .. ". I am but a simple resident of Moonglow.\"")
                if not get_flag(500) then
                    add_dialogue("\"What is thy name?\"")
                    var_0009 = utility_unknown_1035(var_0001, var_0002, var_0000)
                    if var_0009 == var_0000 then
                        add_dialogue("\"Hello, " .. var_0000 .. ".\" He turns to the baby. \"Say `hello' to " .. var_0000 .. ", Mikhail.\"")
                        set_flag(500, true)
                    elseif var_0009 == var_0001 then
                        add_dialogue("\"Fine, " .. var_0001 .. ", if that is the title by which thou dost wish to be called.\" He looks at the infant. \"The " .. var_0006 .. " is quite a snob is " .. var_0007 .. " not, Mikhail?\"")
                    elseif var_0009 == var_0002 then
                        add_dialogue("\"Aha, the Avatar, thou sayest. Whatever thou thinkest....\" He turns to the baby. \"This poor person here wants to be the Avatar. Too bad there is only one Avatar, eh Mikhail?\"")
                    end
                    remove_answer("name")
                    add_answer({"Moonglow", "Mikhail"})
                end
            elseif answer == "job" then
                add_dialogue("\"Me? I do not have a job. Not a real one like my wife has. All I do all day is watch over my little Mikhail, here.\" He turns to look at the baby, taking on a patronizing tone. \"Yes, I take care of thee, do I not? Yes, I do. I sure do.\" He kisses the boy and then looks back up at you, embarrassed. \"Where was I? Oh yes. All I do is take care of the boy. What I should be doing is working, not staying at home. That should be Jillian's job. She belongs here at home, not me.\"")
                if not var_0004 then
                    add_answer("Jillian")
                end
            elseif answer == "Mikhail" then
                add_dialogue("\"That is the name of my son. 'Tis a good name, yes?\"")
                remove_answer("Mikhail")
            elseif answer == "Jillian" or answer == "wife" then
                add_dialogue("\"My wife? Jillian? She's the scholar. She is a very good one, too. Not that I could not have done well. I could have. Better, in fact. But it is not worth arguing about now. She has her occupation, even if I do not have one. I should have a job, though. Dost thou not agree, " .. var_0001 .. "? This is not what a man ought to be doing. Staying at home raising the children, like this. 'Tis a disgrace!\"")
                if var_0005 then
                    switch_talk_to(0, 159)
                    add_dialogue("\"Now Effrem! Thou knowest perfectly well what we agreed when little Mikhail was born. Thou shouldst be ashamed, talking such nonsense.\"")
                    hide_npc(159)
                    switch_talk_to(0, 160)
                    add_dialogue("He raises his shoulders, making him appear quite sheepish.")
                end
                remove_answer({"Jillian", "wife"})
                var_0004 = true
            elseif answer == "Moonglow" then
                add_dialogue("\"What about Moonglow?\" He shrugs, \"'Tis a fair town, but a little too crowded these days. I hear it was a much nicer place back when Moonglow was separate from the Lycaeum. Much smaller. \"This place is too large to really get to know anyone. Not that I have had much of an opportunity, having to stay at home and take care of my son.\" He looks down at the boy, smiles, and tickles the baby's nose.")
                if not var_0004 then
                    add_answer("wife")
                end
                remove_answer("Moonglow")
            elseif answer == "bye" then
                if is_player_female() then
                    add_dialogue("\"Leaving so soon? Fine, leave me with the baby. Go on, leave me. Just like my wife!\"")
                else
                    add_dialogue("\"Leaving so soon? Ah, that's all right, " .. var_0001 .. ". I understand, thou hast real man things to do.\"")
                end
                break
            end
        end
    elseif eventid == 0 then
        utility_unknown_1070(160)
    end
    return
end