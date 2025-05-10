--- Best guess: Manages Grod’s dialogue, a troll torturer in a dungeon, proudly discussing his job and Fellowship membership, offering the player a chance to torture prisoners, with flag-based interactions and prisoner banter.
function func_049A(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E

    if eventid ~= 1 then
        return
    end

    start_conversation()
    switch_talk_to(0, 154)
    add_answer({"bye", "Fellowship", "job", "name"})
    var_0000 = unknown_08F7H(-1)
    var_0001 = unknown_08F7H(-2)
    var_0002 = unknown_08F7H(-240)
    var_0003 = unknown_08F7H(-220)
    var_0004 = get_lord_or_lady()
    var_0005 = unknown_0908H()
    unknown_003DH(unknown_001BH(154), 2)
    if not get_flag(702) then
        add_dialogue("The troll snarls at you, obviously displeased at your presence.")
        set_flag(702, true)
    else
        add_dialogue("\"What you want?\" asks Grod.")
    end
    while true do
        if cmps("name") then
            var_0006 = unknown_0067H()
            if var_0006 then
                add_dialogue("\"I Grod. Why you want know? Is voice unhappy?\"")
                var_0007 = unknown_090AH()
                if var_0007 then
                    add_dialogue("He seems truly worried.~~\"I will do job better. I promise! I beat harder and more often!\"")
                    if var_0002 then
                        add_dialogue("*")
                        switch_talk_to(0, -240)
                        if not get_flag(707) then
                            var_0008 = "Anton,"
                        else
                            var_0008 = "a prisoner,"
                        end
                        add_dialogue("\"Thank thee ever so much, " .. var_0004 .. ",\" says " .. var_0008 .. " sarcastically.")
                        hide_npc240)
                        switch_talk_to(0, 154)
                    end
                    if var_0002 and var_0003 then
                        switch_talk_to(0, -220)
                        add_dialogue("\"Now, now, Anton, the nice person was simply answering a question.\"")
                        hide_npc220)
                        switch_talk_to(0, 154)
                    end
                else
                    add_dialogue("\"Good. I do my job good!\"")
                end
            else
                add_dialogue("\"I Grod. Who you?\"")
                var_0005 = unknown_0908H()
                var_0009 = "the Avatar"
                var_000A = unknown_090BH({var_0004, var_0005, var_0009})
                if var_000A == var_0005 then
                    add_dialogue("\"I not know you.\" He shrugs.")
                elseif var_000A == var_0004 then
                    add_dialogue("\"Funny name. But, all humans have funny names.\" He shrugs.")
                elseif var_000A == var_0009 then
                    add_dialogue("\"The Avatar?\" He begins laughing. \"The Avatar not been here for...,\" he begins counting on his fingers. After several attempts, he gives up, saying, \"for many years!~~\"You no Avatar.\"")
                end
            end
            remove_answer("name")
        elseif cmps("job") then
            add_dialogue("\"I torture prisoners,\" he says, thumping his chest proudly.")
            if var_0001 then
                switch_talk_to(0, -2)
                add_dialogue("Spark's eyes light up.~~\"Torture? Wow!\" He quickly looks at you and changes expressions.~~ \"I, er, mean, that is very awful.\"")
                hide_npc2)
                switch_talk_to(0, 154)
            end
            var_000B = unknown_0067H()
            if var_000B then
                add_dialogue("\"Want to help?\"")
                var_000C = unknown_090AH()
                if var_000C then
                    if var_0003 and var_0002 then
                        add_dialogue("He points to one of the prisoners.~~\"He not fun like the other. Torture other first.\"")
                        switch_talk_to(0, -220)
                        add_dialogue("\"What? No, that's all right, " .. var_0004 .. ". Torture me, first.\"")
                        hide_npc220)
                        switch_talk_to(0, -240)
                        add_dialogue("\"Yes, " .. var_0004 .. ". Torture him first.\"")
                        hide_npc240)
                        switch_talk_to(0, -220)
                        add_dialogue("\"I thank thee,\" he says to the other.")
                        hide_npc220)
                        switch_talk_to(0, 154)
                        add_dialogue("\"Go ahead,\" says Grod.")
                        var_000D = unknown_002CH(true, 359, 359, 622, 1)
                        if var_000D then
                            add_dialogue("He hands you a whip.")
                        else
                            add_dialogue("\"You too wimpy to use whip!\"")
                        end
                        return
                    else
                        add_dialogue("\"No one here to abuse.\" He appears disappointed.")
                    end
                else
                    add_dialogue("\"You make funny joke. Go ahead, torture.\"")
                    return
                end
            end
            add_answer({"prisoners", "torture"})
        elseif cmps("Fellowship") then
            var_000E = unknown_0067H()
            if var_000E then
                add_dialogue("\"Yes,\" he nods. \"I belong, too. I strive for unity. I be worthy for my reward. And I trust my brother.\"~~ He smiles, obviously pleased with himself.\"")
                add_answer({"trust", "worthy", "strive"})
            else
                add_dialogue("\"Big group, many people. You should join!\"")
                add_answer("join")
            end
            remove_answer("Fellowship")
        elseif cmps({"trust", "worthy", "strive"}) then
            add_dialogue("\"You don't know?\" He frowns.~~ \"You should learn before the voice become angry!\"")
            remove_answer({"trust", "worthy", "strive"})
        elseif cmps("join") then
            add_dialogue("\"Good, join. See Abraham or Danag about join.\"")
            remove_answer("join")
        elseif cmps("prisoners") then
            if get_flag(738) and get_flag(737) then
                add_dialogue("\"None here at the moment...\" he appears truly disconcerted.")
            else
                add_dialogue("\"There one!\" he says, pointing to a man.")
                if not get_flag(737) and get_flag(738) then
                    add_dialogue("\"There another one!\" he says, indicating the other man.")
                    switch_talk_to(0, -220)
                    add_dialogue("\"How art thou today, " .. var_0004 .. "?\" he says, smiling.")
                    hide_npc220)
                    switch_talk_to(0, 154)
                end
            end
            remove_answer("prisoners")
        elseif cmps("torture") then
            add_dialogue("\"Much fun! Prisoners scream loudly.\"")
            if var_0003 then
                add_dialogue("\"Except that one. He not scream. He just talk. And talk. I get so bored I get mad. So I torture more. And,\" he throws up his hands, \"he just talk more! I no know what to do.\"")
            end
            if var_0000 then
                switch_talk_to(0, -1)
                add_dialogue("\"That is terrible, " .. var_0005 .. ". We must command him to stop!\"")
                hide_npc1)
                switch_talk_to(0, 154)
                if var_0003 then
                    add_dialogue("\"I try make him stop. But he talk and talk. You try? Maybe he stop.\"")
                end
                add_answer("stop torturing")
            end
            remove_answer("torture")
        elseif cmps("stop torturing") then
            add_dialogue("\"Oh, no! Grod love job! Grod never stop. You go away now.\"")
            return
        elseif cmps("bye") then
            break
        end
    end
    add_dialogue("\"Come back and visit Grod. Hear victims squeal!\"")
end