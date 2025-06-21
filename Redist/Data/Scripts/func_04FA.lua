--- Best guess: Manages Rankin’s dialogue in Moonglow, the Fellowship branch leader, addressing Balayna’s accusations, her death, and a suspicious liqueur vial.
function func_04FA(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B

    if eventid == 1 then
        switch_talk_to(0, 250)
        var_0000 = get_player_name()
        var_0001 = false
        var_0002 = npc_id_in_party(156)
        var_0003 = get_schedule()
        var_0004 = unknown_0931H(1, 359, 981, 1, 357)
        if var_0003 == 7 then
            if not get_flag(508) then
                add_dialogue("Rankin is unable to speak with you now, for he is conducting the Fellowship meeting.")
                unknown_08CFH()
                return
            else
                add_dialogue("The man is too busy to speak with you now, for he is conducting the Fellowship meeting.")
                unknown_08CFH()
                return
            end
        end
        start_conversation()
        add_answer({"bye", "Fellowship", "job", "name"})
        if not get_flag(644) then
            add_answer("Elizabeth and Abraham")
        end
        if not get_flag(508) then
            add_dialogue("The man greets you with a pleasant smile.")
            set_flag(508, true)
        else
            add_dialogue("Rankin smiles. \"Please tell me how I may be of assistance, " .. var_0000 .. ".\"")
            if not get_flag(472) and not get_flag(522) and not get_flag(523) then
                add_answer("Balayna's accusation")
            end
            if not get_flag(527) then
                add_answer("merchant")
            end
            if not get_flag(522) and not get_flag(528) then
                add_answer("Balayna")
            end
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"Thou mayest call me Rankin, " .. var_0000 .. ".\"")
                set_flag(523, true)
                remove_answer("name")
                if not get_flag(472) and not get_flag(522) and not var_0001 then
                    add_answer("Balayna's accusation")
                end
            elseif answer == "job" then
                add_dialogue("\"I am the new branch leader of The Fellowship here in Moonglow.\"")
                if not get_flag(501) then
                    add_answer("voice")
                end
                if not get_flag(472) and not get_flag(522) and not var_0001 then
                    add_answer("Balayna's accusation")
                end
                add_answer({"Moonglow", "new"})
            elseif answer == "Balayna" then
                unknown_0911H(50)
                if not get_flag(525) then
                    add_dialogue("\"What dost thou want to know about her, " .. var_0000 .. "?\"")
                    add_answer("liqueur")
                elseif not get_flag(524) then
                    if unknown_0065H(8) >= 6 then
                        add_dialogue("\"She has left for Britain on important business,\" he smiles. \"I do not expect her return any time soon.\"")
                    else
                        add_dialogue("\"Oh? Thou hast not seen her lately, either? I wonder what she has been up to.\" He gives a slight smile.")
                        if var_0004 then
                            add_dialogue("The Cube vibrates. \"Actually, I know exactly where she is.\"")
                            add_answer("where")
                        end
                    end
                elseif var_0002 then
                    add_dialogue("\"She is right there,\" he says, pointing to Balayna.")
                else
                    add_dialogue("\"I have not seen her in some time, " .. var_0000 .. ". Perhaps thou mayest find her in her house.\"")
                    unknown_003FH(156)
                    set_flag(524, true)
                    unknown_0066H(8)
                end
                remove_answer("Balayna")
            elseif answer == "where" then
                add_dialogue("\"She has conveniently stopped breathing!\" Rankin laughs.")
                remove_answer("where")
            elseif answer == "liqueur" then
                add_dialogue("\"Yes, I told thee the merchant brought it from Britain. Didst thou give it to her?\"")
                var_0006 = ask_yes_no()
                if var_0006 then
                    add_dialogue("\"What then,\" he asks, \"is the problem?\"")
                    save_answers()
                    add_answer({"no problem", "she died"})
                else
                    add_dialogue("\"Ah, well. Then I hope thou wilt have the chance later.\" He stares at you oddly for a moment, and then smiles again.")
                end
            elseif answer == "no problem" then
                add_dialogue("\"Excellent, then.\"")
                remove_answer("no problem")
                restore_answers()
            elseif answer == "she died" then
                set_flag(528, true)
                remove_answer({"she died", "no problem"})
                add_dialogue("\"What!\" he appears stunned. \"Died? How is that possible?\"")
                add_answer({"liqueur", "don't know"})
            elseif answer == "don't know" then
                add_dialogue("\"Well this is truly a tragedy! Please, " .. var_0000 .. ", I would prefer to be alone now. If thou wouldst be so kind...\"")
                return
            elseif answer == "liqueur" then
                remove_answer({"don't know", "liqueur"})
                restore_answers()
                add_dialogue("\"The liqueur? Why, art thou implying that the merchant had cause to kill her? That is absurd!\" He appears thoughtful.")
                add_dialogue("\"Or perhaps not. Mayhaps we will look into that, what sayest thou?\"")
                var_0007 = ask_yes_no()
                if var_0007 then
                    add_dialogue("\"Excellent. Let me know if thou dost find any information. Meanwhile, I will make arrangements for her funeral.\" He shakes his head sadly.")
                    set_flag(527, true)
                else
                    add_dialogue("\"Very well, then I must conduct the search on mine own, -after- I have arranged for the funeral.\"")
                    return
                end
            elseif answer == "merchant" then
                add_dialogue("\"Dost thou have any news of the travelling merchant who killed Balayna?\"")
                var_0008 = ask_yes_no()
                if var_0008 then
                    add_dialogue("\"Very good, " .. var_0000 .. ". What is thy news?\"")
                    save_answers()
                    add_answer({"dead", "not ready"})
                else
                    add_dialogue("\"Ah, well. Keep searching. I am positive thou wilt come across some information soon!\"")
                end
                remove_answer("merchant")
            elseif answer == "not ready" then
                add_dialogue("\"Very well, " .. var_0000 .. ", I can wait until thou hast learned more.\"")
                remove_answer("not ready")
                restore_answers()
            elseif answer == "dead" then
                add_dialogue("\"Really!\" he seems genuinely surprised. \"How, ah, wonderful.\" Then I guess the murder has been avenged.\"")
                set_flag(527, false)
                remove_answer("dead")
                restore_answers()
            elseif answer == "new" then
                add_dialogue("\"He grins, obviously embarrassed. \"I am sorry. Though the branch opened here several years ago, it is the newest branch on Britannia. I still consider myself a new branch head here.\"")
                remove_answer("new")
            elseif answer == "Moonglow" then
                add_dialogue("\"Ah, yes, Moonglow. It is a pleasant town. It is possible to find all sorts of people here.\"")
                add_answer("people")
                remove_answer("Moonglow")
            elseif answer == "people" then
                add_dialogue("\"I am sorry, but I prefer not to gossip.\"")
                remove_answer("people")
            elseif answer == "Fellowship" then
                var_0009 = is_player_wearing_fellowship_medallion()
                if var_0009 then
                    if not get_flag(6) then
                        add_dialogue("\"As is customary, our meetings are at 9 p.m. Please feel free to join us.\"")
                    else
                        add_dialogue("\"Thou shouldst return thy medallion to the person from whom it came. Only Fellowship members are permitted to wear them.\"")
                    end
                else
                    unknown_0919H()
                    add_dialogue("\"If thou hast a free moment, I would be quite happy to discuss our philosophy with thee.\"")
                    add_answer("philosophy")
                end
                remove_answer("Fellowship")
            elseif answer == "philosophy" then
                unknown_091AH()
                remove_answer("philosophy")
            elseif answer == "voice" then
                if not get_flag(6) then
                    add_dialogue("\"Relax, friend, thou wilt hear when the time is right.\"")
                else
                    add_dialogue("\"There is an inner voice that exists within each and every one of us. This voice is our companion and guide.\"")
                    add_dialogue("\"The deeper one's involvement with The Fellowship, the more often one is able to hear one's inner voice.\"")
                end
                remove_answer("voice")
            elseif answer == "Elizabeth and Abraham" then
                if not get_flag(579) then
                    add_dialogue("\"What dear people! They were just here in order to give me my training session. I was just appointed branch leader. This is a new branch, thou knowest. Anyway, Elizabeth and Abraham left to travel all the way to the gargoyle island, Terfin.\"")
                    set_flag(495, true)
                else
                    add_dialogue("\"I have not seen them since they gave me my training session, many days ago.\"")
                end
                remove_answer("Elizabeth and Abraham")
            elseif answer == "Balayna's accusation" then
                if var_0002 then
                    add_dialogue("\"Shhh! Talk to me about it later,\" he whispers, gesturing subtly towards Balayna, \"when she is not around.\"")
                else
                    add_dialogue("He begins to look amused.")
                    add_dialogue("\"I would not let it worry thee too much, " .. var_0000 .. ". I am afraid Balayna is a bit too ambitious. I would expect she overheard one of my conversion speeches and misunderstood my words. I will have to discuss this with her when I have more time so I may allay her fears.\" His eyes widen, as if he is remembering something.")
                    add_dialogue("\"I had forgotten, she requested a small vial of liqueur from an itinerant merchant who would be passing through Britain. He brought it here a few days ago and I have not had a chance to give it to her. Wouldst thou be willing to deliver it to her for me, " .. var_0000 .. "?\"")
                    var_000A = ask_yes_no()
                    if var_000A then
                        add_dialogue("\"Excellent, my friend.\"")
                        var_000B = unknown_002CH(false, 30, 359, 749, 1)
                        if var_000B then
                            add_dialogue("\"I thank thee.\" He gives you the vial of liquor.")
                            set_flag(526, true)
                        else
                            add_dialogue("\"Ah, well, thou art carrying too much. I will simply have to save it for when I have time to talk with her. Thank thee anyway.\"")
                            unknown_0066H(8)
                            unknown_003FH(156)
                            set_flag(524, true)
                        end
                    else
                        add_dialogue("\"Very well. I will have to save it for when I have time to talk with her. Thank thee anyway.\"")
                        unknown_0066H(8)
                        unknown_003FH(156)
                        set_flag(524, true)
                    end
                    set_flag(522, true)
                end
                remove_answer("Balayna's accusation")
                var_0001 = true
            elseif answer == "bye" then
                if not get_flag(6) then
                    add_dialogue("\"May the triad guide thy life.\"")
                else
                    add_dialogue("\"Shouldst thou find an interest in The Fellowship, " .. var_0000 .. ", seek Batlin in Britain. Farewell, " .. var_0000 .. ".\"")
                end
                break
            end
        end
    elseif eventid == 0 then
        unknown_092EH(250)
    end
    return
end