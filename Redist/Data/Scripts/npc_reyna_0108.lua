--- Best guess: Manages Reyna's dialogue, a healer near Empath Abbey, discussing her mother's grave, healing services, and local figures, with flag-based flower offerings and emergency healing checks using a loop.
function npc_reyna_0108(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011, var_0012, var_0013, var_0014, var_0015, var_0016, var_0017, var_0018

    if eventid ~= 1 then
        if eventid == 0 then
            return
        end
    end

    start_conversation()
    switch_talk_to(0, 108)
    var_0000 = get_lord_or_lady()
    var_0001 = get_schedule()
    var_0002 = 108
    var_0003 = false
    var_0004 = false
    var_0005 = utility_unknown_1073(4, 359, 999, 1, 357)
    add_answer({"bye", "job", "name"})
    if not get_flag(326) then
        add_dialogue("The woman greets you with shining eyes.")
        set_flag(326, true)
    else
        add_dialogue("\"Hello, " .. var_0000 .. ",\" says Reyna.")
    end
    var_0006 = find_nearest(-1, 715, 356)
    if var_0006 == 0 and not get_flag(296) then
        add_answer("cemetery")
    end
    if var_0005 and not get_flag(296) then
        add_answer("brought flowers")
    end
    if not get_flag(355) then
        add_answer("heal")
        var_0004 = true
    end
    while true do
        if cmps("name") then
            add_dialogue("\"I am Reyna,\" she says, brushing the hair out of her face.")
            remove_answer("name")
        elseif cmps("job") then
            add_dialogue("\"I am a healer. I have chosen to set up shop here near the forest.\"")
            set_flag(355, true)
            if not var_0004 then
                add_answer("heal")
            end
            add_answer("forest")
            if not get_flag(315) then
                add_answer("animals")
            end
        elseif cmps("forest") then
            add_dialogue("\"I wanted to live and work here because the land is very beautiful. I have found many things to do and see. Unfortunately, the forest is so spread out that I have yet to meet many of the others who live in this area. I do know that the Abbey is just across the way from mine house.~~\"And somewhere nearby is a scholar.\" She appears thoughtful for a moment. \"Also, I believe there is a prison just east of the Abbey.\"")
            remove_answer("forest")
            add_answer({"prison", "scholar", "Abbey"})
        elseif cmps("prison") then
            add_dialogue("\"I've never actually seen it,\" she laughs, \"but rumor has it that the cells are located right next to the court, for quick, easy imprisonment after the trial.\"")
            remove_answer("prison")
        elseif cmps("scholar") then
            add_dialogue("\"From Aimi I have heard that he is brilliant, and... also a bit overzealous to instruct those interested in increasing their knowledge.\"")
            if not var_0003 then
                add_answer("Aimi")
            end
            remove_answer("scholar")
        elseif cmps("Aimi") then
            var_0003 = true
            if not get_flag(346) then
                add_dialogue("\"She is the monk who tends the garden at the Abbey.\"")
            else
                add_dialogue("\"She is one of the monks who lives at the Abbey. At this time, she is the only other person I have actually met here in the forest.\"")
            end
            remove_answer("Aimi")
        elseif cmps("Abbey") then
            add_dialogue("\"That is how this area -- Empath Abbey -- got its name, from the monks who live at the abbey of the Brotherhood of the Rose. They are said to make delicious wine. One of the monks cares for a beautiful garden in her spare time. In fact, I often buy flowers from her.~~ But,\" she grins, \"as for the other monks, all that I ever see them do is make wine and wander the countryside.\"")
            set_flag(346, true)
            remove_answer("Abbey")
            add_answer({"others", "flowers"})
        elseif cmps("others") then
            add_dialogue("\"Aimi is the only one I have met, but I know there are one or two others who make wine there.\"")
            if not var_0003 then
                add_answer("Aimi")
            end
            remove_answer("others")
        elseif cmps("flowers") then
            add_dialogue("\"Yes, I get them for my mother.\"")
            if not get_flag(296) then
                add_answer("mother")
            end
            remove_answer("flowers")
        elseif cmps({"cemetery", "mother"}) then
            set_flag(296, true)
            if var_0006 == 0 then
                var_0007 = ""
                var_0008 = find_nearby(0, 10, 999, 108)
                for var_000B in ipairs(var_0008) do
                    if get_object_frame(var_000B) == 4 then
                        var_0007 = "I realize there are already \r\n      very beautiful flowers here, \r\n      but there can never be enough \r\n      to demonstrate how much she is \r\n      missed. "
                    end
                end
            end
            add_dialogue("She looks down at her feet, and then back up at you. It is obvious she is fighting an urge to cry.~~ \"Several months ago, my mother passed away in her home town. She was born here in the forests, and had asked to be buried here, near me. Every morning I come out here to visit her and set flowers by her grave.~~ \"But,\" a lone tear escapes and trickles down her cheek, \"I am the only member of our family who lives nearby. No one else is able to visit or leave flowers very often.~~\"Her grave looks so bare sometimes.\" She looks off into the horizon and sighs. \"" .. var_0007 .. "It would be nice if there were some way to have more flowers brought to her.\"~~She quickly turns and looks at you.~~\"I am terribly sorry for rambling on like that. Please excuse me, " .. var_0000 .. ".\"")
            remove_answer({"cemetery", "mother"})
            if var_0005 then
                add_answer("have flowers")
            end
        elseif cmps({"have flowers", "brought flowers"}) then
            add_dialogue("Her eyes light up as she sees the bouquet of flowers.~~ \"They are lovely! Thou art too kind, " .. var_0000 .. ", to bring flowers for my mother! I cannot wait to set them by her grave.\"")
            var_000C = remove_party_items(true, 4, 359, 999, 1)
            var_000D = random2(6, 1)
            if var_000D == 1 or var_000D == 2 then
                var_000E = 9
            elseif var_000D == 3 or var_000D == 4 or var_000D == 5 then
                var_000E = 19
            elseif var_000D == 6 then
                var_000E = 90
            end
            utility_unknown_1041(var_000E)
            set_flag(313, true)
            remove_answer({"brought flowers", "have flowers"})
        elseif cmps("heal") then
            if var_0001 == 3 or var_0001 == 4 or var_0001 == 5 then
                set_flag(314, true)
                if get_flag(313) then
                    var_000F = true
                    add_dialogue("\"For thy kindly gift of flowers, I will aid thee for half price.\" She smiles at you.")
                    utility_unknown_0978(200, 5, 15)
                else
                    utility_unknown_0978(400, 10, 30)
                end
            else
                add_dialogue("\"I am sorry, " .. var_0000 .. ", but, unless this is an emergency, I would prefer to wait until my shop is open.\"")
                add_answer("emergency")
            end
        elseif cmps("emergency") then
            var_0010 = get_party_members()
            var_0011 = 0
            var_0012 = false
            for var_0013 in ipairs(var_0010) do
                var_0011 = var_0011 + 1
                var_0016 = get_item_flag(8, var_0015)
                if var_0016 then
                    var_0012 = true
                end
                var_0017 = get_npc_quality(3, var_0015)
                if var_0017 < 10 then
                    var_0012 = true
                end
            end
            if var_0011 > 1 then
                var_0018 = " and your companions"
            else
                var_0018 = ""
            end
            add_dialogue("She quickly examines you" .. var_0018 .. ".")
            if var_0012 == true then
                set_flag(314, true)
                add_dialogue("\"Thou art correct, " .. var_0000 .. ". This is a true emergency!\"")
                add_answer("heal")
            else
                add_dialogue("\"I am sorry, but thy wounds are not mortal. Perhaps thou canst visit me when my shop is open.\"")
            end
            remove_answer("emergency")
        elseif cmps("animals") then
            add_dialogue("She smiles shyly.~~\"I very much love animals. When I was very young, I found an ailing dove that I was unable to nurse back to health. Since that time, I began to study the healing arts, so that I would be able to help other animals who might need healing.~~ \"Of course,\" she laughs, \"now that I have the skills, I use them to help people, too.\"")
            remove_answer("animals")
        elseif cmps("bye") then
            break
        end
    end
    add_dialogue("\"Goodbye, " .. var_0000 .. ".")
    if get_flag(313) then
        add_dialogue("\"I thank thee for the bouquet!")
        if var_000F then
            set_flag(313, false)
        end
    end
    add_dialogue("\"May health always follow thee!\"")
    set_flag(314, false)
    return
end