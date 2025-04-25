-- Function 04B7: Teregus's altar keeper dialogue
function func_04B7(eventid, itemref)
    -- Local variables (6 as per .localc)
    local local0, local1, local2, local3, local4, local5

    if eventid == 0 then
        call_092FH(-183)
        return
    elseif eventid ~= 1 then
        return
    end

    _SwitchTalkTo(0, -183)
    local0 = call_0908H()
    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x0248) then
        say("You see a winged gargoyle in his physical prime.~~\"Hail, human! To be welcome to the house of the altars. To be helpful to you in any way?\"")
        set_flag(0x0248, true)
    else
        say("\"To have returned! To be glad to see you again, human,\" says Teregus. \"To be welcome to the house of the altars. To be helpful to you?\"")
    end

    if not get_flag(0x023F) then
        _AddAnswer("evidence")
    end
    if not get_flag(0x0254) and get_flag(0x0239) then
        _AddAnswer("Inamo")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"To be called Teregus.\"")
            set_flag(0x0254, true)
            if get_flag(0x0239) then
                _AddAnswer("Inamo")
            end
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("\"To be caring for the altars of Control, Passion, and Diligence. To be a position of great responsibility. To be especially important in these times of trouble.\"")
            _AddAnswer({"altars", "trouble"})
        elseif answer == "trouble" then
            say("\"To have been many disagreements in town lately. To be much tension between the followers of the principles of the altars and the followers of The Fellowship. To have heard rumors of threats to the altars.\"")
            _AddAnswer({"rumors", "Fellowship"})
            _RemoveAnswer("trouble")
        elseif answer == "Fellowship" then
            local1 = callis_0037(callis_001B(-184))
            if not local1 then
                say("\"To be glad that Quan is now running our branch. To believe that he is misguided, but to be a much more reasonable gargoyle to deal with now that Runeb is gone.\"")
            else
                say("\"To be wary of Fellowship ideals. To be ignoring the altars in their search for unity, and to be losing respect for the old ways. To be not bad. To tell you our branch is run by Quan and Runeb.\"")
            end
            _AddAnswer({"Runeb", "Quan"})
            _RemoveAnswer("Fellowship")
        elseif answer == "rumors" then
            if not callis_0037(callis_001B(-184)) then
                say("\"To be sorry that we have lost Runeb. Perhaps to be for the best. To be certainly overjoyed to have avoided damage to the altars.\"")
            else
                say("\"To have heard that someone in town is planning to destroy the physical representations of the altars. To be not the same, of course, as actually destroying the basic principles of Control, Passion, and Diligence, but to be bad for us nonetheless. To be finding out for us who is planning this, if there is time, perhaps. To return to me with evidence when you determine course of action. To be very grateful for your assistance.\"")
                set_flag(0x0253, true)
            end
            _RemoveAnswer("rumors")
        elseif answer == "evidence" then
            say("\"To have brought me something, some evidence about the rumors?\"")
            local2 = call_090AH()
            if local2 then
                say("\"To be wonderful! To see it, please.\"~~You hand him the note from Runeb that you found in Sarpling's shop.~~\"Ah. Runeb. To have suspected as much. To be always reaching for more by the most violent means.\"~~He sighs.~~\"To ask that you confront him with this evidence. To suggest that anything less will not reveal truth. To be prepared for anything, please, human, for to know not how he will react.\"~~He shakes his head.~~\"To be not hopeful for a peaceful solution. To thank you for your assistance.\"")
                local3 = false
            else
                say("\"To have found nothing yet? Ah, well. To return, please, when anything unusual is found. To suggest that you confront the suspect as soon as you have a clue. To wish to stop him before any damage is done to the altars.\"")
            end
            _RemoveAnswer("evidence")
        elseif answer == "Quan" then
            say("\"To be sad to have lost Quan to The Fellowship, human. To have been a good gargoyle when young, but to have fallen into bad company later. To have concentrated mostly on self-aggrandizement and hedonism in the last few years. To be a shame.\"")
            _RemoveAnswer("Quan")
        elseif answer == "Runeb" then
            say("\"To have been a sad case. To have wished to have been able to save him. To always have been uncontrollable, but to have gotten worse in the last few years. To have seemed to want to start as many fights as possible. To have found a reason for using his strength against all those weaker when to have joined The Fellowship.\"")
            _RemoveAnswer("Runeb")
        elseif answer == "Inamo" then
            say("He smiles sadly, but with obvious pride.")
            _RemoveAnswer("Inamo")
            if get_flag(0x023A) then
                say("\"To have been a fine young gargoyle. The pride of us all. To wish to know who was responsible for his dishonorable end.\"")
            else
                say("\"To miss him greatly. To have raised him from an egg. To have been rather vocal in his disagreements with The Fellowship. To have felt it safer for him to leave.\"~~He sighs, then looks up hopefully.~~\"To have news of him?\"")
                local4 = call_090AH()
                if local4 then
                    say("\"To be well?\"")
                    local5 = call_090AH()
                    if local5 then
                        say("\"To be good. To be hoping to hear from him soon.\"")
                    else
                        say("\"To be not well? To be terrible! To think there is anything to do to help?\"")
                        _AddAnswer("too late")
                    end
                else
                    say("\"Ah. Too bad. To be waiting long for news from him.\"")
                end
            end
        elseif answer == "too late" then
            say("\"To be too late? To mean what by too late? To tell me what has happened!\"~~He seems very distraught.")
            _AddAnswer("murdered")
            _RemoveAnswer("too late")
        elseif answer == "murdered" then
            say("\"To be murdered?\"~~He takes a step back, stunned by the news.~~\"To be murdered? To be unbelievable. To have no real enemies!\"~~He sighs heavily.~~\"To tell me, please, exactly what happened.\"~~You relate to him the particulars of Inamo's death. He sighs again.~~\"To be such a waste of gargoyle life. To be grateful if you would send news if you discover who was responsible for wanting him dead.\"~~He is quiet for a few moments, getting accustomed to the situation.~~\"To apologize. To need some time to grieve. Please to come back later.\"~~He turns away.")
            set_flag(0x023A, true)
            _RemoveAnswer("murdered")
            return
        elseif answer == "altars" then
            say("\"To be caretaker and group leader for the altars of the three principles. To wish to make a donation?\"")
            local2 = call_090AH()
            if local2 then
                say("\"Excellent. To which altar do you wish to donate?\"")
                _SaveAnswers()
                _AddAnswer({"Diligence", "Passion", "Control"})
            else
                say("\"Ah. To donate next time, perhaps.\"")
            end
            _RemoveAnswer("altars")
        elseif answer == "Diligence" or answer == "Passion" or answer == "Control" then
            say("\"To be an excellent choice. To meditate at the shrine for you for a donation of 5 gold. To be willing to donate 5 gold?\"")
            local2 = call_090AH()
            if local2 then
                local5 = callis_002B(true, -359, -359, 644, 5)
                if local5 then
                    say("\"To meditate for you this evening, human. To wish you well in your journeys.\"")
                else
                    say("\"To not have 5 gold? To return later when you have the gold. To meditate for your success on your journeys.\"~~He smiles kindly.")
                end
            else
                say("\"Ah. To have misunderstood. To apologize. To let me know if you change your mind.\"~~He looks disappointed.")
            end
            _RemoveAnswer({"Diligence", "Passion", "Control"})
            _RestoreAnswers()
        elseif answer == "bye" then
            say("\"To tell you goodbye for now, human. To return and be welcome.\"*")
            break
        end
    end

    return
end

-- Helper functions
function say(...)
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