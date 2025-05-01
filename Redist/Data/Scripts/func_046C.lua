-- Manages Reyna's dialogue near Empath Abbey, covering healing services, her mother's grave, and forest connections.
function func_046C(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14, local15, local16, local17, local18, local19, local20, local21, local22, local23, local24

    if eventid == 1 then
        switch_talk_to(108, 0)
        local0 = get_player_name()
        local1 = get_party_size()
        local2 = switch_talk_to(108)
        local3 = false
        local4 = true

        local5 = check_item(-359, -359, 999, 1, -357, 4) -- Unmapped intrinsic 0931
        add_answer({"bye", "job", "name"})

        if not get_flag(326) then
            add_answer("cemetery")
        end
        if not local5 then
            add_answer("brought flowers")
        end
        if not get_flag(355) then
            add_answer("heal")
            local4 = true
        end

        if not get_flag(326) then
            say("The woman greets you with shining eyes.")
            set_flag(326, true)
        else
            say("\"Hello, " .. local0 .. ",\" says Reyna.")
        end

        local6 = check_item(-1, 715, -356) -- Unmapped intrinsic
        if not local6 and not get_flag(296) then
            add_answer("cemetery")
        end
        if local5 and not get_flag(296) then
            add_answer("brought flowers")
        end
        if not get_flag(355) then
            add_answer("heal")
            local4 = true
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                say("\"I am Reyna,\" she says, brushing the hair out of her face.")
                remove_answer("name")
            elseif answer == "job" then
                say("\"I am a healer. I have chosen to set up shop here near the forest.\"")
                set_flag(355, true)
                if not local4 then
                    add_answer("heal")
                end
                add_answer("forest")
                if not get_flag(315) then
                    add_answer("animals")
                end
            elseif answer == "forest" then
                say("\"I wanted to live and work here because the land is very beautiful. I have found many things to do and see. Unfortunately, the forest is so spread out that I have not yet met many of the others who live in this area. I do know that the Abbey is just across the way from mine house.~~\"And somewhere nearby is a scholar.\" She appears thoughtful for a moment. \"Also, I believe there is a prison just east of the Abbey.\"")
                remove_answer("forest")
                add_answer({"prison", "scholar", "Abbey"})
            elseif answer == "prison" then
                say("\"I've never actually seen it,\" she laughs, \"but rumor has it that the cells are located right next to the court, for quick, easy imprisonment after the trial.\"")
                remove_answer("prison")
            elseif answer == "scholar" then
                say("\"From Aimi I have heard that he is brilliant, and... also a bit overzealous to instruct those interested in increasing their knowledge.\"")
                if not local3 then
                    add_answer("Aimi")
                end
                remove_answer("scholar")
            elseif answer == "Aimi" then
                set_flag(346, true)
                if not get_flag(346) then
                    say("\"She is the monk who tends the garden at the Abbey.\"")
                else
                    say("\"She is one of the monks who lives at the Abbey. At this time, she is the only other person I have actually met here in the forest.\"")
                end
                remove_answer("Aimi")
            elseif answer == "Abbey" then
                say("\"That is how this area -- Empath Abbey -- got its name, from the monks who live at the abbey of the Brotherhood of the Rose. They are said to make delicious wine. One of the monks cares for a beautiful garden in her spare time. In fact, I often buy flowers from her.~~ But,\" she grins, \"as for the other monks, all that I ever see them do is make wine and wander the countryside.\"")
                set_flag(346, true)
                remove_answer("Abbey")
                add_answer({"others", "flowers"})
            elseif answer == "others" then
                say("\"Aimi is the only one I have met, but I know there are one or two others who make wine there.\"")
                if not local3 then
                    add_answer("Aimi")
                end
                remove_answer("others")
            elseif answer == "flowers" then
                say("\"Yes, I get them for my mother.\"")
                if not get_flag(296) then
                    add_answer("mother")
                end
                remove_answer("flowers")
            elseif answer == "cemetery" or answer == "mother" then
                set_flag(296, true)
                if not local6 then
                    local7 = ""
                    for i = 0, 9 do
                        local8 = get_item_frame(local13)
                        if local8 == 4 then
                            local7 = "I realize there are already very beautiful flowers here, but there can never be enough to demonstrate how much she is missed."
                        end
                    end
                    say("She looks down at her feet, and then back up at you. It is obvious she is fighting an urge to cry.~~ \"Several months ago, my mother passed away in her home town. She was born here in the forests, and had asked to be buried here, near me. Every morning I come out here to visit her and set flowers by her grave.~~ \"But,\" a lone tear escapes and trickles down her cheek, \"I am the only member of our family who lives nearby. No one else is able to visit or leave flowers very often.~~\"Her grave looks so bare sometimes.\" She looks off into the horizon and sighs. \"" .. local7 .. " It would be nice if there were some way to have more flowers brought to her.\"~~She quickly turns and looks at you.~~\"I am terribly sorry for rambling on like that. Please excuse me, " .. local0 .. ".\"")
                    remove_answer({"cemetery", "mother"})
                    if local5 then
                        add_answer("have flowers")
                    end
                end
            elseif answer == "have flowers" or answer == "brought flowers" then
                say("Her eyes light up as she sees the bouquet of flowers.~~ \"They are lovely! Thou art too kind, " .. local0 .. ", to bring flowers for my mother! I cannot wait to set them by her grave.\"")
                set_flag(313, true)
                local9 = remove_item(-359, -359, 999, 1, 4) -- Unmapped intrinsic
                local10 = random(1, 6)
                if local10 == 1 or local10 == 2 then
                    local11 = 9
                elseif local10 == 3 or local10 == 4 or local10 == 5 then
                    local11 = 19
                elseif local10 == 6 then
                    local11 = 90
                end
                apply_effect(local11) -- Unmapped intrinsic 0911
                remove_answer({"brought flowers", "have flowers"})
            elseif answer == "heal" then
                if local1 == 3 or local1 == 4 or local1 == 5 then
                    set_flag(314, true)
                end
                if get_flag(314) then
                    if get_flag(313) then
                        local12 = true
                        say("\"For thy kindly gift of flowers, I will aid thee for half price.\" She smiles at you.")
                        heal_party(200, 5, 15) -- Unmapped intrinsic 08D2
                    else
                        heal_party(400, 10, 30) -- Unmapped intrinsic 08D2
                    end
                else
                    say("\"I am sorry, " .. local0 .. ", but, unless this is an emergency, I would prefer to wait until my shop is open.\"")
                    add_answer("emergency")
                end
            elseif answer == "emergency" then
                local13 = get_party_members()
                local14 = 0
                local15 = false
                for _, local16 in ipairs(local13) do
                    local14 = local14 + 1
                    local17 = get_npc_property(local16, 8)
                    if local17 then
                        local15 = true
                    end
                    local18 = get_npc_property(local16, 3)
                    if local18 < 10 then
                        local15 = true
                    end
                end
                if local14 > 1 then
                    local19 = " and your companions"
                else
                    local19 = ""
                end
                say("She quickly examines you" .. local19 .. ".")
                if local15 == true then
                    set_flag(314, true)
                    say("\"Thou art correct, " .. local0 .. ". This is a true emergency!\"")
                    add_answer("heal")
                else
                    say("\"I am sorry, but thy wounds are not mortal. Perhaps thou canst visit me when my shop is open.\"")
                end
                remove_answer("emergency")
            elseif answer == "animals" then
                say("She smiles shyly.~~\"I very much love animals. When I was very young, I found an ailing dove that I was unable to nurse back to health. Since that time, I began to study the healing arts, so that I would be able to help other animals who might need healing.~~ \"Of course,\" she laughs, \"now that I have the skills, I use them to help people, too.\"")
                remove_answer("animals")
            elseif answer == "bye" then
                say("\"Goodbye, " .. local0 .. ".")
                if get_flag(313) then
                    say("\"I thank thee for the bouquet!")
                end
                if local12 then
                    set_flag(313, false)
                end
                say("\"May health always follow thee!\"*")
                set_flag(314, false)
                break
            end
        end
    elseif eventid == 0 then
        return
    end
    return
end