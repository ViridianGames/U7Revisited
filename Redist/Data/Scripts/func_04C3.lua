--- Best guess: Manages Lord John-Paul’s dialogue in Serpent’s Hold, the overseer investigating the defacement of Lord British’s statue.
function func_04C3(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006

    if eventid == 1 then
        switch_talk_to(0, 195)
        var_0000 = get_player_name()
        var_0001 = get_lord_or_lady()
        var_0002 = npc_id_in_party(-197)
        var_0003 = false
        start_conversation()
        add_answer({"bye", "job", "name"})
        if get_flag(607) and not get_flag(613) then
            add_answer("Sir Horffe responsible")
        end
        if get_flag(605) and not get_flag(609) then
            add_answer("Sir Pendaran responsible")
            remove_answer("Sir Horffe responsible")
        end
        if not get_flag(620) then
            add_dialogue("The very serious man breaks into a half-smile as he greets you.")
            var_0004 = unknown_0019H(-197, -195)
            if var_0004 < 10 then
                if not get_flag(622) then
                    add_dialogue("Horffe is standing at attention just behind him.")
                else
                    add_dialogue("Standing at attention just behind him is a wingled gargoyle.")
                end
            end
            set_flag(620, true)
        else
            add_dialogue("\"Good day to thee,\" says Lord John-Paul.")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"I am Lord John-Paul of Serpent's Hold. Thou art \" .. var_0000 .. \", the Avatar, correct?\"")
                var_0005 = ask_yes_no()
                if var_0005 then
                    if get_flag(606) and not get_flag(608) then
                        add_dialogue("\"I remember thee.\"")
                    else
                        add_dialogue("\"Excellent.\"")
                        if not get_flag(611) then
                            add_dialogue("\"I have something that might interest thee.\"")
                        end
                        add_answer("I am interested")
                    end
                else
                    add_dialogue("He looks surprised. \"Forgive me, \" .. var_0001 .. \", I could have sworn... Ah, well, no matter.\"")
                end
                remove_answer("name")
                add_answer("Serpent's Hold")
            elseif answer == "job" then
                add_dialogue("\"I am charged with overseeing the Hold.\"")
                add_answer("overseeing")
            elseif answer == "overseeing" then
                add_dialogue("\"It is not a difficult job. Sir Richter and Sir Horffe insure that things run smoothly as often as possible.\"")
                remove_answer("overseeing")
                add_answer({"Sir Horffe", "Sir Richter"})
            elseif answer == "Sir Richter" then
                add_dialogue("\"He is in charge of the Hold when I am otherwise occupied. He has seemed somewhat changed of late, but I trust him nonetheless.\"")
                remove_answer("Sir Richter")
                add_answer("changed")
            elseif answer == "changed" then
                add_dialogue("\"It began when he joined The Fellowship. He became more... what is the word... orderly.\"")
                add_dialogue("He smiles. \"I suppose there is a regimented structure within The Fellowship that has done him good, no?\"")
                remove_answer("changed")
                add_answer({"Fellowship", "orderly"})
            elseif answer == "Fellowship" then
                add_dialogue("\"I'm afraid I know so little about them. They seem to help many people. However, I have noticed Sir Horffe has become rather apprehensive since Richter joined.\"")
                var_0003 = true
                remove_answer("Fellowship")
            elseif answer == "orderly" then
                add_dialogue("\"It is difficult to explain. He seems more disciplined,\" he gives a short laugh, \"which, of course, is rather fitting for the Hold.\"")
                remove_answer("orderly")
            elseif answer == "Sir Horffe" then
                add_dialogue("\"He is the captain of the guards. I would have no other for his position. He is the most honorable warrior I have ever met.\"")
                if var_0002 then
                    switch_talk_to(0, -197)
                    add_dialogue("\"To thank you, Sir!\"")
                    hide_npc(197)
                    switch_talk_to(0, -195)
                end
                if not var_0003 then
                    add_dialogue("\"He seems to have taken a dislike for The Fellowship, however. I have noticed he is reluctant to mention this around Sir Richter.\" He shrugs.")
                end
                remove_answer("Sir Horffe")
            elseif answer == "Serpent's Hold" then
                add_dialogue("\"It has changed little since thy last visit, \" .. var_0000 .. \". Of course, all of the people are new.\"")
                add_answer("people")
                remove_answer("Serpent's Hold")
            elseif answer == "people" then
                add_dialogue("\"I am afraid I must attend to other business shortly, and cannot show thee around. But I recommend that thou visitest the Hallowed Dock. Many of the Hold's knights frequent there in the evening.\"")
                remove_answer("people")
            elseif answer == "I am interested" then
                if not get_flag(608) then
                    add_dialogue("He smiles gratefully at you and begins pacing.")
                    add_dialogue("\"Very recently, a terrible crime was committed. It seems the statue of Lord British, the one in the Hold commons, was defaced by an unknown vandal.\"")
                    add_dialogue("\"Perhaps,\" he looks at you hopefully, \"thou couldst help track down the villain?\"")
                    set_flag(611, true)
                    var_0006 = ask_yes_no()
                    if var_0006 then
                        add_dialogue("\"Very good. The best way to begin is by speaking with Sir Denton, the tavernkeeper at the Hallowed Dock. His ability to solve puzzles and problems is remarkable. When thou hast solved this little mystery, please inform me of thy findings.\"")
                    else
                        add_dialogue("\"Of course. I understand. Thou dost have much more important matters to resolve. I will call for an official from Yew to handle this issue.\"")
                        set_flag(608, true)
                    end
                    set_flag(606, true)
                else
                    add_dialogue("\"Oh, yes, I forgot. I am terribly sorry to have disturbed thee twice with this matter. Please excuse my forgetfulness, \" .. var_0000 .. \". The matter is being handled.\"")
                    add_answer("handled?")
                end
                remove_answer("I am interested")
            elseif answer == "handled?" then
                add_dialogue("\"I have sent for a judge from the High Court in Yew. I realize thou dost not have the time for such petty matters.\"")
                add_answer("I have the time")
                remove_answer("handled?")
            elseif answer == "I have the time" then
                add_dialogue("\"Yes, yes, thou art very kind, but I am sure there are much more important matters thou must attend to. I thank thee none the less.\"")
                remove_answer("I have the time")
                add_answer("-I- -want- -to- -do- -it-!")
            elseif answer == "-I- -want- -to- -do- -it-!" then
                add_dialogue("\"Oh, I see. Well, in that case. The best way to begin is by speaking with Sir Denton, the tavernkeeper at the Hallowed Dock. His ability to solve puzzles and problems is remarkable. Please come to me with thy findings after thou hast solved this little mystery.\"")
                remove_answer("-I- -want- -to- -do- -it-!")
            elseif answer == "Sir Pendaran responsible" then
                add_dialogue("He appears puzzled.")
                add_dialogue("\"I see. And how didst thou reach this conclusion?\"")
                add_answer("Lady Jehanne")
                remove_answer("Sir Pendaran responsible")
            elseif answer == "Lady Jehanne" then
                unknown_0911H(100)
                add_dialogue("He smiles and extends his hand.")
                add_dialogue("\"Excellent job, \" .. var_0000 .. \". I cannot adequately express my gratitude. I will see that Sir Pendaran is properly reprimanded. I thank thee, \" .. var_0000 .. \".\"")
                if not get_flag(610) then
                    add_dialogue("\"Now I must apologize to Sir Horffe!\"")
                    if var_0002 then
                        add_dialogue("*")
                        switch_talk_to(0, -197)
                        add_dialogue("\"To have no need! To be happy the true vandal is discovered.\"")
                        hide_npc(197)
                        switch_talk_to(0, -195)
                    end
                end
                set_flag(609, true)
                remove_answer("Lady Jehanne")
            elseif answer == "Sir Horffe responsible" then
                add_dialogue("He appears surprised.")
                add_dialogue("\"I see. And how didst thou reach this conclusion?\"")
                add_answer("gargoyle blood on fragments")
                remove_answer("Sir Horffe responsible")
            elseif answer == "gargoyle blood on fragments" then
                add_dialogue("\"Very well.\" He is obviously troubled.")
                if var_0002 then
                    add_dialogue("He turns to reprimand the gargoyle at his side.")
                    return
                else
                    add_dialogue("\"I will take care of this immediately!\"")
                end
                set_flag(610, true)
                remove_answer("gargoyle blood on fragments")
            elseif answer == "bye" then
                add_dialogue("\"Carry on, \" .. var_0000 .. \".\"")
                break
            end
        end
    elseif eventid == 0 then
        return
    end
    return
end