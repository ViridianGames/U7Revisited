--- Best guess: Manages Sir Denton's dialogue in Serpent's Hold, a tavernkeeper providing extensive information about residents and aiding the statue defacement investigation.
function npc_sir_denton_0199(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    if eventid == 1 then
        switch_talk_to(0, 199)
        var_0000 = get_player_name()
        var_0001 = get_lord_or_lady()
        var_0002 = npc_id_in_party(-4)
        start_conversation()
        add_answer({"bye", "job", "name"})
        if get_flag(606) and not get_flag(609) then
            if not get_flag(629) then
                add_answer("help")
            elseif not get_flag(601) then
                add_answer("got fragments")
                remove_answer("help")
            end
        end
        if var_0002 then
            add_dialogue("\"Greetings to thee, Sir Dupre. Art thou back again for thy study of wines for Brommer?\"")
            switch_talk_to(0, -4)
            add_dialogue("\"Why, ah, yes, my good friend, Denton. I am, uh, still conducting that study.\" He turns to you and shrugs, grinning sheepishly.")
            hide_npc(4)
            switch_talk_to(0, -199)
        end
        if not get_flag(624) then
            add_dialogue("The man before you seems to stare at you blankly.")
            set_flag(624, true)
        else
            add_dialogue("\"Hello, \" .. var_0001 .. \",\" says Denton.")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"I am Sir Denton, \" .. var_0001 .. \".\"")
                set_flag(629, true)
                remove_answer("name")
                if get_flag(606) and not get_flag(601) and not get_flag(609) then
                    add_answer("help")
                end
            elseif answer == "job" then
                add_dialogue("\"I am the tavernkeeper, \" .. var_0001 .. \". I sell refreshment to the citizens of Britannia, most notably, the knights in Serpent's Hold.\"")
                add_answer({"knights", "Serpent's Hold", "sell"})
            elseif answer == "knights" then
                add_dialogue("\"Almost every resident here is a noble warrior. The exceptions would be Lady Jehanne, the provisioner; Lady Tory; Lady Leigh, the healer; and Menion, the trainer. I can also tell thee about all the other residents.\"")
                add_answer({"residents", "Menion", "Lady Leigh", "Lady Tory", "Lady Jehanne"})
                remove_answer("knights")
            elseif answer == "sell" then
                utility_unknown_0886()
            elseif answer == "Serpent's Hold" then
                add_dialogue("\"Serpent's Hold is located at precisely 53 degrees east and 165 degrees south.\"")
                remove_answer("Serpent's Hold")
            elseif answer == "residents" then
                add_dialogue("\"Yes, \" .. var_0001 .. \", I can tell thee about the following people: \"")
                save_answers()
                add_answer({"Sir Pendaran", "Sir Jordan", "Sir Horffe", "Sir Richter", "Lord John-Paul", "no one"})
            elseif answer == "no one" then
                restore_answers()
                remove_answer("residents")
            elseif answer == "Lord John-Paul" then
                add_dialogue("\"He is the Lord of Serpent's Hold. He is a capable leader and a fair man.\"")
                remove_answer("Lord John-Paul")
            elseif answer == "Lady Leigh" then
                add_dialogue("\"Her healing skills are said to be unparalleled.\"")
                remove_answer("Lady Leigh")
            elseif answer == "Sir Richter" then
                add_dialogue("\"He is second in command to Lord John-Paul. He is teaching me how to gamble well. In fact, he began increasing the lessons after joining The Fellowship.\"")
                add_answer("Fellowship")
                remove_answer("Sir Richter")
            elseif answer == "Sir Horffe" then
                add_dialogue("\"Sir Horffe is an excellent warrior. He is a gargoyle that was found by two knights when he was very young. They chose to raise him as their own child. He is very honorable.\"")
                remove_answer("Sir Horffe")
                if not get_flag(622) then
                    add_answer("Gargish accent")
                end
            elseif answer == "Gargish accent" then
                add_dialogue("\"Sir Horffe has chosen to use the Gargish syntax of our language so he may better maintain his cultural ties.\"")
                remove_answer("Gargish accent")
            elseif answer == "Sir Jordan" then
                add_dialogue("\"Despite his blindness, Sir Jordan perceives objects around him very well. He is an excellent tinkerer, and can repair many items.\"")
                remove_answer("Sir Jordan")
            elseif answer == "Lady Tory" then
                add_dialogue("\"I believe she is a druid. She was showing me how to be more compassionate than I was before. She is very good at knowing what others are feeling and why they are experiencing such emotions.\"")
                remove_answer("Lady Tory")
            elseif answer == "Menion" then
                add_dialogue("\"He is the fighting instructor. In his spare time, he likes to make swords. Menion has been kind enough to give me one of his creations.\"")
                remove_answer("Menion")
            elseif answer == "Sir Pendaran" then
                add_dialogue("\"Sir Pendaran is a knight of the Hold. He is very friendly, but I have been told he can be overbearing at times.\"")
                remove_answer("Sir Pendaran")
            elseif answer == "Lady Jehanne" then
                add_dialogue("\"She is the lady of Sir Pendaran. She has been helping me better my sense of humor.\"")
                add_answer("humor")
                remove_answer("Lady Jehanne")
            elseif answer == "humor" then
                add_dialogue("\"My jokes are very bad. If thou wouldst like, I will tell thee one.\"")
                var_0003 = ask_yes_no()
                if var_0003 then
                    add_dialogue("\"Why did the chicken cross the road?\"")
                    var_0004 = npc_id_in_party(-1)
                    var_0005 = npc_id_in_party(-2)
                    if var_0005 then
                        switch_talk_to(0, -2)
                        add_dialogue("\"To get to the other side! Oh, that joke is new,\" he says sarcastically.")
                        hide_npc(2)
                    end
                    if var_0004 then
                        switch_talk_to(0, -1)
                        add_dialogue("Iolo whispers in your ear.")
                        add_dialogue("\"" .. var_0000 .. \", we have heard that one before. 'Tis best we leave him before he indulges in another joke.\"")
                        hide_npc(1)
                    end
                    switch_talk_to(0, -199)
                    save_answers()
                    add_answer({"I don't know", "to get to the other side"})
                else
                    add_dialogue("He almost appears disappointed, but it seems more likely that it's your imagination.")
                end
                remove_answer("humor")
            elseif answer == "I don't know" then
                restore_answers()
                remove_answer("humor")
                add_dialogue("He gives a partial smile.")
                add_dialogue("\"To get to the other side. Didst thou think that was funny?\"")
                var_0006 = ask_yes_no()
                if var_0006 then
                    add_dialogue("He appears confused. \"That is odd, no one else thinks that joke is humorous.\"")
                    add_dialogue("\"Perhaps I am more funny than I thought...\"")
                else
                    add_dialogue("\"No one else finds it humorous either. I will continue practicing to be funny.\"")
                end
                remove_answer({"I don't know", "to get to the other side"})
            elseif answer == "to get to the other side" then
                restore_answers()
                remove_answer("humor")
                add_dialogue("\"Oh. Thou hast heard it before.\"")
                remove_answer({"to get to the other side", "I don't know"})
            elseif answer == "Fellowship" then
                add_dialogue("\"The Fellowship is a twenty-year-old organization that holds many festivals, parades, and celebrations. In addition, they maintain a shelter in the town of Paws. They have an underlying philosophy called the Triad of Inner Strength. This triad is broken into the three principles known as `strive for unity,' `trust thy brother,' and `worthiness precedes reward.'I will now explain the meaning of each principple.\"")
                var_0005 = npc_id_in_party(-2)
                if var_0005 then
                    switch_talk_to(0, -2)
                    add_dialogue("\"This Denton fellow is really long-winded.\"")
                    hide_npc(2)
                    switch_talk_to(0, -199)
                end
                add_dialogue("\"Strive for unity seems to mean that The Fellowship wants others to work together for the weal of society. Trust thy brother implies that each person should not question the actions of others. Worthiness precedes reward indicates that The Fellowship's attitude towards reward is that one must do well to be rewarded.\"")
                var_0007 = is_player_wearing_fellowship_medallion()
                if var_0007 then
                    add_dialogue("He looks at your medallion.")
                    add_dialogue("\"Is mine information correct?\"")
                    var_0008 = ask_yes_no()
                    if var_0008 then
                        add_dialogue("\"I thank thee. I always endeavor to be correct.\"")
                    else
                        add_dialogue("\"I shall attempt to become better informed.\"")
                    end
                end
                remove_answer("Fellowship")
            elseif answer == "help" then
                add_dialogue("\"Yes, \" .. var_0001 .. \", I can help thee investigate the crime. I believe the best way to begin would be by speaking with Sir Richter, since he is the one who searched the statue after the incident.\"")
                remove_answer("help")
            elseif answer == "got fragments" then
                add_dialogue("\"Perhaps thou shouldst have these stone chips examined by the healer, Lady Leigh.\"")
                if get_flag(607) then
                    add_answer("gargoyle blood")
                end
                remove_answer("got fragments")
            elseif answer == "gargoyle blood" then
                add_dialogue("\"That behavior does not seem typical of Sir Horffe. Thou mayest wish to report to Lord John-Paul, but I expect there is more to this. It would be a good idea to visit Lady Tory. She is very good at sensing the feelings of others, and may have learned something by observing the residents after the event.\"")
                remove_answer("gargoyle blood")
            elseif answer == "bye" then
                add_dialogue("\"Good day, \" .. var_0001 .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        utility_unknown_1070(199)
    end
    return
end