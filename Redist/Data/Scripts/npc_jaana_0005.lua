--- Best guess: Handles dialogue with Jaana in Cove, discussing her role as a healer, magic issues, and relationship with Lord Heather, with options to join or heal.
function npc_jaana_0005(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E

    start_conversation()
    if eventid == 1 then
        switch_talk_to(5)
        var_0000 = get_lord_or_lady()
        var_0001 = get_npc_name(5) --- Guess: Retrieves object reference from ID
        var_0002 = get_player_name()
        add_answer({"bye", "job", "name"})
        if is_int_in_array(var_0001, get_party_members()) then
            add_answer("leave")
        elseif not get_flag(24) then
            add_answer("join")
        end
        if not get_flag(228) and not get_flag(239) then
            add_answer("Lord Heather")
        end
        if get_flag(40) then
            add_answer("heal")
        end
        if not get_flag(24) then
            add_dialogue("You are surprised to see your old companion Jaana, looking only slightly aged since your last visit.")
            set_flag(24, true)
        else
            add_dialogue("\"Yes, " .. var_0002 .. "?\" Jaana asks.")
        end
        while true do
            var_0003 = get_answer()
            if var_0003 == "name" then
                add_dialogue("\"Why, I am Jaana. Thou shouldst remember me!\"")
                remove_answer("name")
                if not get_flag(228) then
                    add_answer("Lord Heather")
                end
                set_flag(239, true)
            elseif var_0003 == "job" then
                add_dialogue("\"I have been the Cove Healer for some time now, and can provide thee with mine healing services. Since magic is not reliable, I have been yearning to join a party of adventurers, such as mine old friends. I miss the old life!\"")
                add_answer({"magic", "friends", "heal"})
                set_flag(40, true)
                if not is_int_in_array(var_0001, get_party_members()) then
                    add_answer("join")
                end
            elseif var_0003 == "heal" then
                if is_int_in_array(var_0001, get_party_members()) then
                    if get_flag(41) then
                        var_0004 = get_timer(10) --- Guess: Checks party status or conditions
                    else
                        var_0004 = 5
                    end
                    if var_0004 < 4 then
                        add_dialogue("\"I am sorry, I must wait a while before I can heal again.\"")
                    else
                        utility_unknown_0926(0, 0, 0) --- Guess: Heals party member
                    end
                else
                    utility_unknown_0926(400, 15, 30) --- Guess: Heals party member
                end
            elseif var_0003 == "friends" then
                add_dialogue("\"Our old friends -- Iolo, Shamino, and Dupre. The men who conquer evil in the name of Lord British!\"")
                remove_answer("friends")
                add_answer({"Lord British", "Dupre", "Shamino", "Iolo"})
            elseif var_0003 == "join" then
                var_0005 = 0
                var_0006 = get_party_members()
                for var_0007 = 1, 8 do
                    var_0005 = var_0005 + 1
                end
                if var_0005 < 8 then
                    add_dialogue("\"I would be honored to join thee, " .. var_0000 .. "!\"")
                    add_to_party(5) --- Guess: Removes object from game
                    add_answer("leave")
                    remove_answer("join")
                else
                    add_dialogue("\"I do believe thou dost have too many members travelling in thy group. I shall wait until someone leaves and thou dost ask me again.\"")
                end
            elseif var_0003 == "leave" then
                add_dialogue("\"Dost thou want me to wait here or should I go home?\"")
                save_answers()
                var_0009 = ask_answer({"go home", "wait here"})
                if var_0009 == "wait here" then
                    add_dialogue("\"Very well. I shall wait until thou dost return.\"")
                    remove_from_party(5) --- Guess: Sets object state (e.g., active/inactive)
                    set_schedule_type(15, get_npc_name(5)) --- Guess: Sets a generic object property
                    abort()
                else
                    add_dialogue("\"I shall obey thy wish. I would be happy to re-join if thou shouldst ask. Goodbye.\"")
                    remove_from_party(5) --- Guess: Sets object state (e.g., active/inactive)
                    set_schedule_type(11, get_npc_name(5)) --- Guess: Sets a generic object property
                    abort()
                end
            elseif var_0003 == "magic" then
                if not get_flag(3) then
                    add_dialogue("\"My magic has been affected by something in the air, but I have found that my senses are still with me. Hast thou noticed that the mages in the land are afflicted in the head? It is most disconcerting. Nevertheless, I can manage to cast a spell or two most of the time.\"")
                else
                    add_dialogue("\"I feel that the ether is flowing smoothly now. Magic is alive again!\"")
                end
                remove_answer("magic")
            elseif var_0003 == "Lord Heather" then
                add_dialogue("Jaana blushes. \"Yes, I have been seeing our Town Mayor for some time now.\"")
                remove_answer("Lord Heather")
                var_000A = npc_id_in_party(77) --- Guess: Checks player status
                if var_000A then
                    switch_talk_to(77)
                    add_dialogue("\"I see that thou art leaving Cove for a while, my dear?\"")
                    switch_talk_to(5)
                    add_dialogue("\"Yes, milord. But I shall return. I promise thee.\"")
                    switch_talk_to(77)
                    add_dialogue("\"I shall try not to worry about thee, but it will be difficult.\"")
                    switch_talk_to(5)
                    add_dialogue("\"Do not worry. I shall be safe with the Avatar.\"")
                    switch_talk_to(77)
                    add_dialogue("\"I do hope so.\" The Mayor embraces Jaana.")
                    hide_npc(77)
                    switch_talk_to(5)
                end
            elseif var_0003 == "Iolo" then
                var_000B = npc_id_in_party(1) --- Guess: Checks player status
                if not var_000B then
                    add_dialogue("\"Where is he? 'Twould be good to see him!\"")
                else
                    add_dialogue("\"He looks the same to me! Perhaps he has a little more waistline than before... but that is to be expected if one stays away from adventuring for too long!\"")
                    switch_talk_to(1)
                    add_dialogue("\"What dost thou mean? 'Little more waistline' indeed!\"")
                    hide_npc(1)
                    switch_talk_to(5)
                    add_dialogue("\"No offense intended, Iolo!\"")
                end
                remove_answer("Iolo")
            elseif var_0003 == "Shamino" then
                var_000C = npc_id_in_party(3) --- Guess: Checks player status
                if not var_000C then
                    add_dialogue("\"Oh, I would love to see him. I wonder where he might be.\"")
                else
                    add_dialogue("\"Shamino, thou dost not look like a 'kid' anymore! What didst happen? Didst thou reach the venerable age of thirty?\"")
                    switch_talk_to(3)
                    add_dialogue("\"Hmph. I am still a kid at heart.\"")
                    hide_npc(3)
                    switch_talk_to(5)
                    add_dialogue("\"That is a relief.\" She grins cheekily.")
                end
                remove_answer("Shamino")
            elseif var_0003 == "Dupre" then
                var_000D = npc_id_in_party(4) --- Guess: Checks player status
                if not var_000D then
                    add_dialogue("\"I miss having a drink or two with that rogue! Let's go find that knight!\"")
                else
                    add_dialogue("\"For someone recently knighted, he has retained his good looks and boyish charm, hasn't he?\"")
                    switch_talk_to(4)
                    add_dialogue("\"Thou dost mean 'mannish' charm, dost thou not?\"")
                    switch_talk_to(5)
                    add_dialogue("\"Oh, pardon -me-, sir. Thine immaturity confused me for a moment.\"")
                    switch_talk_to(4)
                    add_dialogue("\"Art thou going to let her get away with that, " .. var_0002 .. "?\"")
                    var_000E = select_option()
                    if var_000E then
                        add_dialogue("Dupre is speechless and turns away in a huff.")
                        hide_npc(4)
                    else
                        add_dialogue("\"Good!\" Jaana winks at you from behind his back.")
                        hide_npc(4)
                    end
                end
                remove_answer("Dupre")
            elseif var_0003 == "Lord British" then
                add_dialogue("\"I have not seen our liege in many years.\"")
                remove_answer("Lord British")
            elseif var_0003 == "bye" then
                break
            end
        end
        add_dialogue("\"Goodbye, " .. var_0000 .. ".\"")
    elseif eventid == 0 then
        utility_unknown_1070(5) --- Guess: Triggers a game event
    end
end