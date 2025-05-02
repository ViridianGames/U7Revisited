-- Handles Iolo's dialogue and interactions in Trinsic, including initial cutscene, murder discussion, and party join/leave mechanics.

-- Global variables for answer handling, similar to erethian_inline.lua
answers = answers or {}
answer = answer or nil

function func_0401(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9
    local local10, local11, local12, local13, local14, local15, local16, local17, local18

    set_flag(20, true)
    local0 = get_player_name()
    local1 = get_party_members()
    local2 = switch_talk_to(1)
    local3 = get_player_name()
    local4 = is_player_female()

    if eventid == 3 then
        if not get_flag(59) and not get_flag(92) then
            play_music(35, 0)
            switch_talk_to(356, 16, {17493, 7715, 1706})
            add_dialogue("There, there...")
            add_dialogue("'Tis horrible!")
            add_dialogue("I know, 'tis shocking!")
            add_dialogue("Who could have done it?")
            add_dialogue("I know not...")
            add_dialogue("He had no enemies...")
            add_dialogue("Poor man.")
            add_dialogue("What is to be done?")
            add_dialogue("I know not...")
            set_flag(92, true)
            answers = {}
            answer = nil
            return
        end
    end

    if get_flag(59) == false and eventid == 2 then
        switch_talk_to(1, 0)
        add_dialogue("A rather large, familiar man looks up and sees you. The shock that is evident from his dumbfounded expression quickly evolves into delight. He smiles broadly.~~\"! If I did not trust the infallibility of mine own eyes, I would not believe it! I was just thinking to myself, 'If only the Avatar were here!' Then...~~\"Lo and behold! Who says that magic is dying! Here is living proof that it is not!~~ \"Dost thou realize, " .. local0 .. ", that it hath been 200 Britannian years since we last met? Why, thou hast not aged at all!\"")
        add_dialogue("Iolo winks conspiratorially. He whispers, \"Due no doubt to the difference in the structure of time in our original homeland and that of Britannia?\"~~He resumes speaking aloud. \"I have aged a little, as thou canst see. But of course, I have stayed here in Britannia all this time.~~\"Oh, but Avatar! Wait until I tell the others! They will be happy to see thee! Welcome to Trinsic!\"*")
        local6 = local4 and "her" or "him"
        add_dialogue("The distraught peasant interrupts Iolo. \"Show " .. local6 .. " the stables, milord. 'Tis horrible!\"*")
        hide_npc(11)
        switch_talk_to(1, 0)
        add_dialogue("Iolo nods, his joy fading quickly as he is reminded of the reason he was standing there in the first place.~~ \"Ah, yes. Our friend Petre here discovered something truly ghastly this morning. Take a look inside the stables. I shall accompany thee.\"")
        if not check_item_state() then
            add_dialogue("Iolo takes you aside and whispers, \"Avatar, for the sake of our mutual sanity, I strongly suggest that thou shouldst purchase a mouse.\"")
        end
        add_dialogue("", {8021, 20, 17447, 17452, 7715, 1786, 5})
        -- Earthquake effect (unmapped intrinsic 08DDH)
        switch_talk_to(11, 7)
        switch_talk_to(12, 3)
        switch_talk_to(1, 0)
        switch_talk_to(11, 0)
        if not get_flag(59) then
            add_dialogue({17492, 7715, 0, 0}, itemref)
            set_flag(59, true)
        end
        answers = {}
        answer = nil
        return
    end

    if eventid == 1 then
        local0 = get_player_name()
        local1 = get_party_members()
        local2 = switch_talk_to(1)
        local3 = get_player_name()
        local8 = npc_in_party(11)
        local9 = npc_in_party(3)
        local10 = false
        local11 = false

        -- Initialize answers table if empty, similar to erethian_inline.lua
        answers = {}
        add_answer({"bye", "job", "name"})
        if not get_flag(87) then
            add_answer("Trinsic")
        end
        if npc_in_party(1) then
            add_answer("leave")
        end
        if not npc_in_party(1) then
            add_answer("join")
        end
        if not get_flag(63) then
            add_answer("Fellowship")
        end
        if local8 then
            add_answer("Petre")
        end
        if not get_flag(60) and not get_flag(87) then
            add_answer("murder")
        else
            add_answer("stables")
        end
        if not get_flag(60) then
            remove_answer("stables")
        end

        -- Prompt for answer, similar to erethian_inline.lua
        if not answer then
            add_dialogue("\"Yes, my friend?\" Iolo asks.")
            start_conversation()
            answer = get_answer()
        end

        -- Process answer in a single pass, like erethian_inline.lua
        if answer == "name" then
            add_dialogue("Your friend snorts. \"What, art thou joking, " .. local3 .. "? Thou dost not know thine old friend Iolo?\"")
            remove_answer("name")
        elseif answer == "stables" then
            add_dialogue("\"Thou must see for thyself, " .. local0 .. ". Brace thyself, my friend. 'Tis truly a horrible sight.\"*")
            answers = {}
            answer = nil
            return
        elseif answer == "job" then
            add_dialogue("\"Why, right now 'tis adventuring with that most courageous of all legendary heroes, the Avatar!\"")
            add_answer("Avatar")
            remove_answer("job")
        elseif answer == "Avatar" then
            add_dialogue("\"Why, there is no doubt -thou- art the Avatar, " .. local0 .. "! However, thou mayest have some trouble convincing those who do not know thy face.~~\"Of course, thou -shouldst- be safe around thy friends!\"")
            remove_answer("Avatar")
            add_answer({"friends", "trouble"})
        elseif answer == "trouble" then
            add_dialogue("\"Well, after all, thou hast been gone for 200 years! Most of those who would recognize thee are long gone! Sorry to be blunt and all, my friend, but there it is.\"")
            remove_answer("trouble")
        elseif answer == "murder" then
            if not get_flag(61) then
                add_dialogue("\"Ugly, is it not? From what I have heard, neither Christopher nor Inamo deserved so grisly a death. Thou shouldst certainly ask everyone in town about it.\"")
                add_answer({"Inamo", "Christopher"})
            else
                add_dialogue("\"I wish thee luck in determining what is going on. I haven't a clue!\" Iolo grins broadly, patting you on the back.")
            end
            remove_answer("murder")
        elseif answer == "Lord British" then
            local10 = true
            if not get_flag(101) then
                add_dialogue("\"Well, between thee and me, I think that he hath aged much more than I!\"")
                add_dialogue("\"Full of information, that chap. But he never seems to leave Britain anymore.\"")
            else
                add_dialogue("\"My liege will be enormously pleased to see thee. We should travel to Britain post haste. I am sure he can give thee some valuable information and update thee on much of what thou hast missed in the 200 years of thine absence.\"")
            end
            if not local11 then
                add_answer("Britain")
            end
            add_answer("information")
            remove_answer("Lord British")
        elseif answer == "information" then
            add_dialogue("\"Certainly. LB is always a repository of the most amazing facts, eh? Probably something to do with listening and not always talking.\"")
            if local9 then
                add_dialogue("\"Right, Shamino?\"~~Shamino grunts and turns away as Iolo grins mischievously.")
            end
            add_dialogue("\"Speaking of information, reminds me of something! I have a little item which might be useful to thee. 'Tis an abacus. Use it to tally up all of our gold.\"")
            remove_answer("information")
        elseif answer == "friends" then
            add_dialogue("\"Thou must mean Shamino and Dupre.\"")
            remove_answer("friends")
            add_answer({"Dupre", "Shamino"})
        elseif answer == "Dupre" then
            local12 = get_item_type(-4)
            if local12 then
                add_dialogue("\"Why, he is right there, " .. local3 .. ".\"*")
                switch_talk_to(4, 0)
                add_dialogue("\"I am right here, " .. local3 .. ".\"*")
                hide_npc(4)
                switch_talk_to(1, 0)
                add_dialogue("\"See? I told thee!\"")
            else
                add_dialogue("\"I am sure we shall find him somewhere. Last I heard, he was in Jhelom. Didst thou know he was knighted?\"")
                if not get_item_type() then
                    add_dialogue("\"Hard to believe, is it not?\"")
                else
                    add_dialogue("\"It's true! Lord British knighted him recently. Why he did so, I cannot imagine!\"")
                end
                if not local10 then
                    add_answer("Lord British")
                end
            end
            remove_answer("Dupre")
        elseif answer == "Shamino" then
            if local9 then
                add_dialogue("\"Why, he is right there, " .. local3 .. ".\"*")
                switch_talk_to(3, 0)
                add_dialogue("\"I am right here, " .. local3 .. ".\"*")
                hide_npc(3)
                switch_talk_to(1, 0)
                add_dialogue("\"See? I told thee!\"")
            else
                add_dialogue("\"Thy best bet in finding that rascal is to look in Britain. He has a girlfriend employed as an actress at the Royal Theatre.\"")
                if not local11 then
                    add_answer("Britain")
                end
            end
            remove_answer("Shamino")
        elseif answer == "Trinsic" then
            add_dialogue("\"The town has changed little, has it not? Everyone seems a little defensive, though. When we ran into each other, I was passing through and had stopped to visit my friend Finnigan.\"")
            remove_answer("Trinsic")
            add_answer({"Finnigan", "defensive"})
        elseif answer == "defensive" then
            add_dialogue("\"I think it best for thee to speak with them thyself. There have been many changes since last thou didst visit, Avatar. I think thou wilt feel at times a bit... well, old-fashioned.\"")
            remove_answer("defensive")
        elseif answer == "Britain" then
            local11 = true
            add_dialogue("\"It has grown since thou last saw it. Paws is now a virtual township of Britain! It dominates the east coast of Britannia.~~\"Lord British's castle is still the overwhelming feature.\"")
            remove_answer("Britain")
            if not local10 then
                add_answer("Lord British")
            end
            add_answer("Paws")
        elseif answer == "Paws" then
            add_dialogue("\"It still lies between Britain and Trinsic, but it has grown further into Britain itself.\"")
            remove_answer("Paws")
        elseif answer == "Finnigan" then
            add_dialogue("\"He is a good man. The Mayor of Trinsic, he is. I have known him for years.\"")
            remove_answer("Finnigan")
        elseif answer == "Christopher" then
            add_dialogue("\"I did not know him, " .. local3 .. ".\"")
            remove_answer("Christopher")
        elseif answer == "Inamo" then
            add_dialogue("\"I never spoke with him. It is truly a shame. There are not many gargoyles living amongst the humans. This will only discourage the practice even more.\"")
            remove_answer("Inamo")
            add_answer("gargoyles")
        elseif answer == "leave" then
            add_dialogue("Iolo looks hurt. \"Thou dost really want me to leave?\"")
            local13 = get_item_type()
            if local13 then
                add_dialogue("\"Dost thou want me to wait here or dost thou want me to go home to Yew?\"")
                answers = {"go home", "wait here"} -- Override answers for leave choice
                answer = nil
                return
            else
                add_dialogue("\"Whew. Thou didst frighten me!\"")
            end
        elseif answer == "go home" then
            add_dialogue("\"Farewell, then. I shall always rejoin if thou dost so desire.\" Iolo turns away from you.*")
            switch_talk_to(1, 11)
            answers = {}
            answer = nil
            return
        elseif answer == "wait here" then
            add_dialogue("\"Very well. I shall wait here until thou dost return and ask me to rejoin.\"*")
            switch_talk_to(1, 15)
            answers = {}
            answer = nil
            return
        elseif answer == "join" then
            add_dialogue("\"I was waiting until thou didst ask me!\"")
            local15 = 0
            while local15 < 8 do
                local15 = local15 + 1
            end
            if local15 >= 8 then
                switch_talk_to(1)
                remove_answer("join")
                add_answer("leave")
            else
                add_dialogue("\"It seems that thou hast enough members travelling with thee already! I shall wait until someone leaves the group.\"")
            end
        elseif answer == "gargoyles" then
            add_dialogue("\"Since thou wert last in Britannia, the Gargoyles have begun to integrate with the humans. Most of them live on Sutek's old island, which was renamed 'Terfin'. However, thou mayest see one here and there throughout the land.\"")
            remove_answer("gargoyles")
        elseif answer == "Fellowship" then
            add_dialogue("\"I do not know much about them, except that they originated about twenty Britannian years ago. They seem to do good deeds and are looked at with favor by most everyone. They have branch offices all over Britannia. I have not personally had any dealings with them.\"")
            remove_answer("Fellowship")
        elseif answer == "Petre" then
            add_dialogue("\"He is just an acquaintance.\"")
            remove_answer("Petre")
        elseif answer == "bye" then
            add_dialogue("\"'Tis always a pleasure to speak with thee, my friend.\"*")
            answers = {}
            answer = nil
            return
        end

        -- Clear answer if not handled, allow next call to prompt again
        answer = nil
        return
    end

    if eventid == 0 then
        switch_talk_to(1)
        answers = {}
        answer = nil
    end
    return
end