-- Function 04FA: Rankin's deceptive Fellowship dialogue and murder cover-up
function func_04FA(eventid, itemref)
    -- Local variables (12 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11

    if eventid == 0 then
        call_092EH(-250)
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(250, 0)
    local0 = call_0908H()
    local1 = false
    local2 = call_08F7H(-156)
    local3 = callis_003B()
    local4 = call_0931H(-359, -359, 981, 1, -357)

    if local3 == 7 then
        if not get_flag(0x01FC) then
            say("Rankin is unable to speak with you now, for he is conducting the Fellowship meeting.*")
        else
            say("The man is too busy to speak with you now, for he is conducting the Fellowship meeting.*")
        end
        call_08CFH()
        return
    end

    _AddAnswer({"bye", "Fellowship", "job", "name"})
    if not get_flag(0x0284) then
        _AddAnswer("Elizabeth and Abraham")
    end
    if not get_flag(0x01FC) then
        say("The man greets you with a pleasant smile.")
        set_flag(0x01FC, true)
    else
        say("Rankin smiles. \"Please tell me how I may be of assistance, ", local0, ".\"")
        if not get_flag(0x01D8) and not get_flag(0x020A) and not get_flag(0x020B) then
            _AddAnswer("Balayna's accusation")
        end
    end
    if not get_flag(0x020F) then
        _AddAnswer("merchant")
    end
    if not get_flag(0x020A) and not get_flag(0x0210) then
        _AddAnswer("Balayna")
    end
    _AddAnswer({"Moonglow", "new"})

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"Thou mayest call me Rankin, ", local0, ".\"")
            set_flag(0x020B, true)
            _RemoveAnswer("name")
            if not get_flag(0x01D8) and not get_flag(0x020A) and not local1 then
                _AddAnswer("Balayna's accusation")
            end
        elseif answer == "job" then
            say("\"I am the new branch leader of The Fellowship here in Moonglow.\"")
            if not get_flag(0x01F5) then
                _AddAnswer("voice")
            end
            if not get_flag(0x01D8) and not get_flag(0x020A) and not local1 then
                _AddAnswer("Balayna's accusation")
            end
        elseif answer == "Balayna" then
            call_0911H(50)
            if not get_flag(0x020D) then
                say("\"What dost thou want to know about her, ", local0, "?\"")
                _AddAnswer("liqueur")
            elseif not get_flag(0x020C) then
                local5 = callis_0065(8)
                if local5 > 6 then
                    say("\"She has left for Britain on important business,\" he smiles. \"I do not expect her return any time soon.\"")
                else
                    say("\"Oh? Thou hast not seen her lately, either? I wonder what she has been up to.\" He gives a slight smile.")
                    if local4 then
                        say("The Cube vibrates. \"Actually, I know exactly where she is.\"")
                        _AddAnswer("where")
                    end
                end
            elseif local2 then
                say("\"She is right there,\" he says, pointing to Balayna.")
            else
                say("\"I have not seen her in some time, ", local0, ". Perhaps thou mayest find her in her house.\"")
                call_003F(-156)
                set_flag(0x020C, true)
                callis_0066(8)
            end
            _RemoveAnswer("Balayna")
        elseif answer == "where" then
            say("\"She has conveniently stopped breathing!\" Rankin laughs.")
            _RemoveAnswer("where")
        elseif answer == "liqueur" then
            say("\"Yes, I told thee the merchant brought it from Britain. Didst thou give it to her?\"")
            local6 = call_090AH()
            if local6 then
                say("\"What then,\" he asks, \"is the problem?\"")
                _SaveAnswers()
                _AddAnswer({"no problem", "she died"})
            else
                say("\"Ah, well. Then I hope thou wilt have the chance later.\" He stares at you oddly for a moment, and then smiles again.")
            end
        elseif answer == "no problem" then
            say("\"Excellent, then.\"")
            _RemoveAnswer("no problem")
            _RestoreAnswers()
        elseif answer == "she died" then
            set_flag(0x0210, true)
            _RemoveAnswer({"she died", "no problem"})
            say("\"What!\" he appears stunned. \"Died? How is that possible?\"")
            _AddAnswer({"liqueur", "don't know"})
        elseif answer == "don't know" then
            say("\"Well this is truly a tragedy! Please, ", local0, ", I would prefer to be alone now. If thou wouldst be so kind...\"*")
            return
        elseif answer == "liqueur" then
            _RemoveAnswer({"don't know", "liqueur"})
            _RestoreAnswers()
            say("\"The liqueur? Why, art thou implying that the merchant had cause to kill her? That is absurd!\" He appears thoughtful.~ \"Or perhaps not. Mayhaps we will look into that, what sayest thou?\"")
            local7 = call_090AH()
            if local7 then
                say("\"Excellent. Let me know if thou dost find any information. Meanwhile, I will make arrangements for her funeral.\" He shakes his head sadly.")
                set_flag(0x020F, true)
            else
                say("\"Very well, then I must conduct the search on mine own, -after- I have arranged for the funeral.\"*")
                return
            end
        elseif answer == "merchant" then
            say("\"Dost thou have any news of the travelling merchant who killed Balayna?\"")
            local8 = call_090AH()
            if local8 then
                say("\"Very good, ", local0, ". What is thy news?\"")
                _SaveAnswers()
                _AddAnswer({"dead", "not ready"})
            else
                say("\"Ah, well. Keep searching. I am positive thou wilt come across some information soon!\"")
            end
            _RemoveAnswer("merchant")
        elseif answer == "not ready" then
            say("\"Very well, ", local0, ", I can wait until thou hast learned more.\"")
            _RemoveAnswer("not ready")
            _RestoreAnswers()
        elseif answer == "dead" then
            say("\"Really!\" he seems genuinely surprised. \"How, ah, wonderful.\" Then I guess the murder has been avenged.\"")
            set_flag(0x020F, false)
            _RemoveAnswer("dead")
            _RestoreAnswers()
        elseif answer == "new" then
            say("\"He grins, obviously embarrassed. \"I am sorry. Though the branch opened here several years ago, it is the newest branch on Britannia. I still consider myself a new branch head here.\"")
            _RemoveAnswer("new")
        elseif answer == "Moonglow" then
            say("\"Ah, yes, Moonglow. It is a pleasant town. It is possible to find all sorts of people here.\"")
            _AddAnswer("people")
            _RemoveAnswer("Moonglow")
        elseif answer == "people" then
            say("\"I am sorry, but I prefer not to gossip.\"")
            _RemoveAnswer("people")
        elseif answer == "Fellowship" then
            local9 = callis_0067()
            if local9 then
                if not get_flag(0x0006) then
                    say("\"As is customary, our meetings are at 9 p.m. Please feel free to join us.\"")
                else
                    say("\"Thou shouldst really return thy medallion to the person from whom it came. Only Fellowship members are permitted to wear them.\"")
                end
            else
                call_0919H()
                say("\"If thou hast a free moment, I would be quite happy to discuss our philosophy with thee.\"")
                _AddAnswer("philosophy")
            end
            _RemoveAnswer("Fellowship")
        elseif answer == "philosophy" then
            call_091AH()
            _RemoveAnswer("philosophy")
        elseif answer == "voice" then
            if not get_flag(0x0006) then
                say("\"Relax, friend, thou wilt hear when the time is right.\"")
            else
                say("\"There is an inner voice that exists within each and every one of us. This voice is our companion and guide.~~\"The deeper one's involvement with The Fellowship, the more often one is able to hear one's inner voice.\"")
            end
            _RemoveAnswer("voice")
        elseif answer == "Elizabeth and Abraham" then
            if not get_flag(0x0243) then
                say("\"What dear people! They were just here in order to give me my training session. I was just appointed branch leader. This is a new branch, thou knowest. Anyway, Elizabeth and Abraham left to travel all the way to the gargoyle island, Terfin.\"")
                set_flag(0x01EF, true)
            else
                say("\"I have not seen them since they gave me my training session, many days ago.\"")
            end
            _RemoveAnswer("Elizabeth and Abraham")
        elseif answer == "Balayna's accusation" then
            if local2 then
                say("\"Shhh! Talk to me about it later,\" he whispers, gesturing subtly towards Balayna, \"when she is not around.\"")
            else
                say("He begins to look amused.~~\"I would not let it worry thee too much, ", local0, ". I am afraid Balayna is a bit too ambitious. I would expect she overheard one of my conversion speeches and misunderstood my words. I will have to discuss this with her when I have more time so I may allay her fears.\" His eyes widen, as if he is remembering something.~~\"I had forgotten, she requested a small vial of liqueur from an itinerant merchant who would be passing through Britain. He brought it here a few days ago and I have not had a chance to give it to her. Wouldst thou be willing to deliver it to her for me, ", local0, "?\"")
                local10 = call_090AH()
                if local10 then
                    say("\"Excellent, my friend.\"")
                    local11 = callis_002C(false, 30, -359, 749, 1)
                    if local11 then
                        say("\"I thank thee.\" He gives you the vial of liquor.")
                        set_flag(0x020E, true)
                    else
                        say("\"Ah, well, thou art carrying too much. I will simply have to save it for when I have time to talk with her. Thank thee anyway.\"")
                        callis_0066(8)
                        call_003F(-156)
                        set_flag(0x020C, true)
                    end
                else
                    say("\"Very well. I will have to save it for when I have time to talk with her. Thank thee anyway.\"")
                    callis_0066(8)
                    call_003F(-156)
                    set_flag(0x020C, true)
                end
                set_flag(0x020A, true)
            end
            _RemoveAnswer("Balayna's accusation")
            local1 = true
        elseif answer == "bye" then
            if not get_flag(0x0006) then
                say("\"May the triad guide thy life.\"*")
            else
                say("\"Shouldst thou find an interest in The Fellowship, ", local0, ", seek Batlin in Britain. Farewell, ", local0, ".\"*")
            end
            return
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