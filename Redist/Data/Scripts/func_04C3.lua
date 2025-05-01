-- Function 04C3: Lord John-Paul's leadership dialogue and statue investigation
function func_04C3(eventid, itemref)
    -- Local variables (7 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6

    if eventid == 0 then
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(195, 0)
    local0 = call_0908H()
    local1 = call_0909H()
    local2 = call_08F7H(-197)
    local3 = false
    add_answer({"bye", "job", "name"})

    if not get_flag(0x026C) then
        add_dialogue("The very serious man breaks into a half-smile as he greets you.")
        local4 = callis_0019(-197, -195)
        if local4 < 10 then
            if not get_flag(0x026E) then
                add_dialogue("Horffe is standing at attention just behind him.")
            else
                add_dialogue("Standing at attention just behind him is a wingled gargoyle.")
            end
        end
        set_flag(0x026C, true)
    else
        add_dialogue("\"Good day to thee,\" says Lord John-Paul.")
    end

    if get_flag(0x025F) and not get_flag(0x0265) and not get_flag(0x0261) then
        add_answer("Sir Horffe responsible")
    end
    if get_flag(0x025D) and not get_flag(0x0261) then
        add_answer("Sir Pendaran responsible")
        remove_answer("Sir Horffe responsible")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"I am Lord John-Paul of Serpent's Hold. Thou art ", local0, ", the Avatar, correct?\"")
            local5 = call_090AH()
            if local5 then
                if get_flag(0x025E) and not get_flag(0x0260) then
                    add_dialogue("\"I remember thee.\"")
                else
                    add_dialogue("\"Excellent.\"")
                    if not get_flag(0x0263) then
                        add_dialogue("\"I have something that might interest thee.\"")
                    end
                    add_answer("I am interested")
                end
            else
                add_dialogue("He looks surprised. \"Forgive me, ", local1, ", I could have sworn... Ah, well, no matter.\"")
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
            add_dialogue("\"It began when he joined The Fellowship. He became more... what is the word... orderly.\"~~He smiles. \"I suppose there is a regimented structure within The Fellowship that has done him good, no?\"")
            remove_answer("changed")
            add_answer({"Fellowship", "orderly"})
        elseif answer == "Fellowship" then
            add_dialogue("\"I'm afraid I know so little about them. They seem to help many people. However, I have noticed Sir Horffe has become rather apprehensive since Richter joined.\"")
            local3 = true
            remove_answer("Fellowship")
        elseif answer == "orderly" then
            add_dialogue("\"It is difficult to explain. He seems more disciplined,\" he gives a short laugh, \"which, of course, is rather fitting for the Hold.\"")
            remove_answer("orderly")
        elseif answer == "Sir Horffe" then
            add_dialogue("\"He is the captain of the guards. I would have no other for his position. He is the most honorable warrior I have ever met.\"")
            if local2 then
                switch_talk_to(197, 0)
                add_dialogue("\"To thank you, Sir!\"")
                _HideNPC(-197)
                switch_talk_to(195, 0)
            end
            if not local3 then
                add_dialogue("\"He seems to have taken a dislike for The Fellowship, however. I have noticed he is reluctant to mention this around Sir Richter.\" He shrugs.")
            end
            remove_answer("Sir Horffe")
        elseif answer == "Serpent's Hold" then
            add_dialogue("\"It has changed little since thy last visit, ", local0, ". Of course, all of the people are new.\"")
            add_answer("people")
            remove_answer("Serpent's Hold")
        elseif answer == "people" then
            add_dialogue("\"I am afraid I must attend to other business shortly, and cannot show thee around. But I recommend that thou visitest the Hallowed Dock. Many of the Hold's knights frequent there in the evening.\"")
            remove_answer("people")
        elseif answer == "I am interested" then
            if not get_flag(0x0260) then
                add_dialogue("He smiles gratefully at you and begins pacing.~~ \"Very recently, a terrible crime was committed. It seems the statue of Lord British, the one in the Hold commons, was defaced by an unknown vandal.~~ \"Perhaps,\" he looks at you hopefully, \"thou couldst help track down the villain?\"")
                set_flag(0x0263, true)
                local6 = call_090AH()
                if local6 then
                    add_dialogue("\"Very good. The best way to begin is by speaking with Sir Denton, the tavernkeeper at the Hallowed Dock. His ability to solve puzzles and problems is remarkable. When thou hast solved this little mystery, please inform me of thy findings.\"")
                else
                    add_dialogue("\"Of course. I understand. Thou dost have much more important matters to resolve. I will call for an official from Yew to handle this issue.\"")
                    set_flag(0x0260, true)
                end
                set_flag(0x025E, true)
            else
                add_dialogue("\"Oh, yes, I forgot. I am terribly sorry to have disturbed thee twice with this matter. Please excuse my forgetfulness, ", local0, ". The matter is being handled.\"")
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
            add_dialogue("He appears puzzled.~~\"I see. And how didst thou reach this conclusion?\"")
            add_answer("Lady Jehanne")
            remove_answer("Sir Pendaran responsible")
        elseif answer == "Lady Jehanne" then
            call_0911H(100)
            add_dialogue("He smiles and extends his hand.~~\"Excellent job, ", local0, ". I cannot adequately express my gratitude. I will see that Sir Pendaran is properly reprimanded. I thank thee, ",
                local0, ".\"")
            if not get_flag(0x0262) then
                add_dialogue("\"Now I must apologize to Sir Horffe!\"")
                if local2 then
                    add_dialogue("*")
                    switch_talk_to(197, 0)
                    add_dialogue("\"To have no need! To be happy the true vandal is discovered.\"*")
                    _HideNPC(-197)
                    switch_talk_to(195, 0)
                end
            end
            set_flag(0x0261, true)
            remove_answer("Lady Jehanne")
            return
        elseif answer == "Sir Horffe responsible" then
            add_dialogue("He appears surprised.~~\"I see. And how didst thou reach this conclusion?\"")
            add_answer("gargoyle blood on fragments")
            remove_answer("Sir Horffe responsible")
        elseif answer == "gargoyle blood on fragments" then
            add_dialogue("\"Very well.\" He is obviously troubled.")
            if local2 then
                add_dialogue("He turns to reprimand the gargoyle at his side.*")
                return
            else
                add_dialogue("\"I will take care of this immediately!\"")
            end
            set_flag(0x0262, true)
            remove_answer("gargoyle blood on fragments")
        elseif answer == "bye" then
            add_dialogue("\"Carry on, ", local0, ".\"*")
            return
        end
    end

    return
end

-- Helper functions
function add_dialogue(...)
    print(table.concat({...}))
end

function wait_for_answer()
    return "bye" -- Placeholder
end

function get_flag(flag)
    return false -- Placeholder
end

function set_flag(flag, value)
    -- Placeholder
end