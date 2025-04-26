-- Manages Jaana's dialogue in Cove, including her healing services, relationship with Lord Heather, and party interactions.

-- Global variables for answer handling
answers = answers or {}
answer = answer or nil

function func_0405(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9
    local local10, local11, local12, local13, local14

    if eventid == 1 then
        switch_talk_to(-5, 0)
        local0 = is_player_female()
        local1 = get_party_members()
        local2 = switch_talk_to(-5)
        local3 = get_player_name()
        local4 = get_item_type(-1)
        local5 = get_item_type(-3)
        local6 = get_item_type(-4)
        local7 = get_item_type(-77)

        -- Initialize answers
        answers = {}
        add_answer({"bye", "job", "name"})
        if not get_flag(228) then
            add_answer("Lord Heather")
        end
        if not get_flag(239) then
            add_answer("heal")
        end
        if not get_flag(232) then
            add_answer("settle down")
        end
        if is_party_member(local2, local1) then
            add_answer("leave")
        end
        if not is_party_member(local2, local1) then
            add_answer("join")
        end

        if not answer then
            if not get_flag(24) then
                say("You are surprised to see your old companion Jaana, looking only slightly aged since your last visit.")
                set_flag(24, true)
            else
                say("\"Yes, " .. local3 .. "?\" Jaana asks.")
            end
            answer = get_answer()
            return
        end

        -- Process answer
        if answer == "name" then
            say("\"Why, I am Jaana. Thou shouldst remember me!\"")
            remove_answer("name")
            if not get_flag(228) then
                add_answer("Lord Heather")
            end
            set_flag(239, true)
        elseif answer == "job" then
            say("\"I have been the Cove Healer for some time now, and can provide thee with mine healing services. Since magic is not reliable, I have been yearning to join a party of adventurers, such as mine old friends. I miss the old life!\"")
            add_answer({"magic", "friends", "heal"})
            set_flag(40, true)
            if not is_party_member(local2, local1) then
                add_answer("join")
            end
        elseif answer == "heal" then
            if is_party_member(local2, local1) then
                if not get_flag(41) then
                    local8 = apply_effect(10)
                    if local8 then
                        say("Jaana performs a healing spell.")
                    end
                else
                    say("Jaana performs a minor healing spell.")
                end
            else
                apply_effect(400, 15, 30)
            end
        elseif answer == "friends" then
            say("\"Our old friends -- Iolo, Shamino, and Dupre. The men who conquer evil in the name of Lord British!\"")
            remove_answer("friends")
            add_answer({"Lord British", "Dupre", "Shamino", "Iolo"})
        elseif answer == "join" then
            local9 = 0
            local1 = get_party_members()
            while local9 < 8 do
                local9 = local9 + 1
            end
            if local9 >= 8 then
                say("\"I would be honored to join thee, " .. local3 .. "!\"")
                switch_talk_to(-5)
                add_answer("leave")
                remove_answer("join")
            else
                say("\"I do believe thou dost have too many members travelling in thy group. I shall wait until someone leaves and thou dost ask me again.\"")
            end
        elseif answer == "leave" then
            say("\"Dost thou want me to wait here or should I go home?\"")
            answers = {"go home", "wait here"}
            answer = nil
            return
        elseif answer == "go home" then
            say("\"I shall obey thy wish. I would be happy to re-join if thou shouldst ask. Goodbye.\"*")
            switch_talk_to(-5, 11)
            answers = {}
            answer = nil
            return
        elseif answer == "wait here" then
            say("\"Very well. I shall wait until thou dost return.\"*")
            switch_talk_to(-5, 15)
            answers = {}
            answer = nil
            return
        elseif answer == "magic" then
            if not get_flag(3) then
                say("\"My magic has been affected by something in the air, but I have found that my senses are still with me. Hast thou noticed that the mages in the land are afflicted in the head? It is most disconcerting. Nevertheless, I can manage to cast a spell or two most of the time.\"")
            else
                say("\"I feel that the ether is flowing smoothly now. Magic is alive again!\"")
            end
            remove_answer("magic")
        elseif answer == "Lord Heather" then
            say("Jaana blushes. \"Yes, I have been seeing our Town Mayor for some time now.\"")
            remove_answer("Lord Heather")
            if local7 then
                switch_talk_to(-77, 0)
                say("\"I see that thou art leaving Cove for a while, my dear?\"*")
                switch_talk_to(-5, 0)
                say("\"Yes, milord. But I shall return. I promise thee.\"*")
                switch_talk_to(-77, 0)
                say("\"I shall try not to worry about thee, but it will be difficult.\"*")
                switch_talk_to(-5, 0)
                say("\"Do not worry. I shall be safe with the Avatar.\"*")
                switch_talk_to(-77, 0)
                say("\"I do hope so.\" The Mayor embraces Jaana.*")
                hide_npc(-77)
                switch_talk_to(-5, 0)
            end
        elseif answer == "Iolo" then
            if local4 then
                say("\"He looks the same to me! Perhaps he has a little more waistline than before... but that is to be expected if one stays away from adventuring for too long!\"*")
                switch_talk_to(-1, 0)
                say("\"What dost thou mean? 'Little more waistline' indeed!\"*")
                hide_npc(-1)
                switch_talk_to(-5, 0)
                say("\"No offense intended, Iolo!\"")
            else
                say("\"Where is he? 'Twould be good to see him!\"")
            end
            remove_answer("Iolo")
        elseif answer == "Shamino" then
            if local5 then
                say("\"Shamino, thou dost not look like a 'kid' anymore! What didst happen? Didst thou reach the venerable age of thirty?\"*")
                switch_talk_to(-3, 0)
                say("\"Hmph. I am still a kid at heart.\"*")
                hide_npc(-3)
                switch_talk_to(-5, 0)
                say("\"That is a relief.\" She grins cheekily.")
            else
                say("\"Oh, I would love to see him. I wonder where he might be.\"")
            end
            remove_answer("Shamino")
        elseif answer == "Dupre" then
            if local6 then
                say("\"For someone recently knighted, he has retained his good looks and boyish charm, hasn't he?\"*")
                switch_talk_to(-4, 0)
                say("\"Thou dost mean 'mannish' charm, dost thou not?\"*")
                switch_talk_to(-5, 0)
                say("\"Oh, pardon -me-, sir. Thine immaturity confused me for a moment.\"*")
                switch_talk_to(-4, 0)
                say("\"Art thou going to let her get away with that, " .. local3 .. "?\"*")
                local11 = get_item_type()
                if local11 then
                    say("Dupre is speechless and turns away in a huff.*")
                else
                    say("\"Good!\" Jaana winks at you from behind his back.*")
                end
                hide_npc(-4)
            else
                say("\"I miss having a drink or two with that rogue! Let's go find that knight!\"")
            end
            remove_answer("Dupre")
        elseif answer == "Lord British" then
            say("\"I have not seen our liege in many years.\"")
            remove_answer("Lord British")
        elseif answer == "bye" then
            say("\"Goodbye, " .. local3 .. ".\"*")
            answers = {}
            answer = nil
            return
        end

        -- Clear answer if not handled
        answer = nil
        return
    elseif eventid == 0 then
        switch_talk_to(-5)
        answers = {}
        answer = nil
    end
    return
end