--- Best guess: Handles dialogue with Iolo in Trinsic, discussing the murder, companions, and quest progression, with options to join or leave.
function npc_iolo_0001(eventid, objectref)
    local player_name, player_member_names, party_member_1_name, lord_or_lady, player_female, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011, var_0012

    set_flag(20, true)
    player_name = get_player_name()
    player_member_names = get_party_members()
    party_member_1_name = get_npc_name(1)
    lord_or_lady = get_lord_or_lady()
    player_female = is_player_female()
    if eventid == 3 then
        --if not get_flag(59) and not get_flag(92) and not get_item_flag(16, 356) then --- Guess: Checks a flag on an object
            --play_music(0, 35)
            --play_music(0, 35)
            --wait()
            --var_0005 = delayed_execute_usecode_array(125, 1706, {17493, 7715}, 356) --- Guess: Executes a specific action with parameters
        -- Move the avatar offscreen
        hide_ui_elements()
        jump_camera_angle(315)
        stop_npc_schedule(11)
        stop_npc_schedule(12)
        set_npc_dest(11, 1068, 0, 2215)
        set_npc_visibility(0, false)
        --set_npc_pos(0, 16, 0, 16)
        block_input()
        fade_in(3)
        wait(3)
        bark_npc(1, "\"There, there...\"")
        wait(4)
        bark_npc(11, "\"'Tis horrible!\"")
        wait(4)
        bark_npc(1, "\"I know, 'tis shocking!\"")
        wait(4)
        bark_npc(11, "\"Who could have done it?\"")
        wait(4)
        bark_npc(1, "\"I know not...'\"")
        wait(4)
        bark_npc(11, "\"He had no enemies...\"")
        wait(4)
        bark_npc(1, "\"Poor man.\"")
        wait(4)
        bark_npc(11, "\"What is to be done?\"")
        wait(4)
        set_camera_angle(270)
        bark_npc(1, "\"I know not...\"")
        set_flag(92, true)
        local moongate_id = spawn_object(157, 0, 1080, 0, 2214)
        set_model_animation_frame(moongate_id, "idle", 4)
        wait(1)
        set_npc_dest(0, 1071, 0, 2214)
        set_npc_visibility(0, true)
        wait(1)
        destroy_object(moongate_id)
        wait(2)


        --start_npc_schedule(11)
        --start_npc_schedule(12)
        --set_pause(0)
        --resume_input()
            --return
        --else
            --add_to_party(1) --- Guess: Removes object from game
        --end


        start_conversation()
        add_dialogue("A rather large, familiar man looks up and sees you. The shock that is evident from his dumbfounded expression quickly evolves into delight. He smiles broadly.")
        add_dialogue("\"" .. player_name .. "! If I did not trust the infallibility of mine own eyes, I would not believe it! I was just thinking to myself, 'If only the Avatar were here!' Then...")
        add_dialogue("\"Lo and behold! Who says that magic is dying! Here is living proof that it is not!")
        add_dialogue("\"Dost thou realize, " .. player_name .. ", that it hath been 200 Britannian years since we last met? Why, thou hast not aged at all!\"")
        add_dialogue("Iolo winks conspiratorially. He whispers, \"Due no doubt to the difference in the structure of time in our original homeland and that of Britannia?\"")
        add_dialogue("He resumes speaking aloud. \"I have aged a little, as thou canst see. But of course, I have stayed here in Britannia all this time.")
        add_dialogue("\"Oh, but Avatar! Wait until I tell the others! They will be happy to see thee! Welcome to Trinsic!\"")
        var_0006 = get_him_or_her()
        second_speaker(11, 0, "The distraught peasant interrupts Iolo. \"Show " .. var_0006 .. " the stables, milord. 'Tis horrible!\"")
        add_dialogue("Iolo nods, his joy fading quickly as he is reminded of the reason he was standing there in the first place.")
        add_dialogue("\"Ah, yes. Our friend Petre here discovered something truly ghastly this morning. Take a look inside the stables. I shall accompany thee.\"")
        --end_conversation()
        -- var_0007 = delayed_execute_usecode_array(5, {1786, 8021, 20, 17447, 17452, 7715}, 356) --- Guess: Executes a specific action with parameters
        -- utility_earthquake_0989() --- Guess: Triggers an earthquake effect
        -- add_to_party(1) --- Guess: Removes object from game
        -- set_schedule_type(7, 11) --- Guess: Sets a generic object property
        -- set_schedule_type(3, 12) --- Guess: Sets a generic object property
        -- halt_scheduled(1) --- Guess: Updates object state or position
        -- halt_scheduled(11) --- Guess: Updates object state or position
        -- if not get_flag(59) then
        --     var_0005 = execute_usecode_array({0, 0, 17492, 7715}, objectref) --- Guess: Executes a specific action with parameters
        --     set_flag(59, true)
        -- end
        -- Wait for the conversation to finish.

        -- Inlining this is hacky, but everything about scripted sequences in
        -- Ultima VII is hacky.  At the very least, it ensures that the proper
        -- dialogues have been seen and the proper flags are set.
        set_camera_angle(0)
        set_npc_dest(12,  1065, 0, 2215)
        bark_npc(12, "I would have words with thee.")
        --wait(8)
        --debug_print("Wait over.")
        --start_conversation()
        switch_talk_to(12)
        add_dialogue("You see a middle-aged nobleman.")
        set_flag(76, true)
        add_dialogue("\"Iolo! Who is this stranger?\"")
        second_speaker(1, 0, "\"Why, this is the Avatar!\" Iolo proudly proclaims. \"Canst thou believe it? May I introduce thee? This is Finnigan, the Town Mayor. And this is " .. player_name .. ", the Avatar!\"")
        if is_player_female then
            second_speaker(1, 0, "\"I simply cannot believe he is here!\"")
        else
            second_speaker(1, 0, "\"I simply cannot believe she is here!\"")
        end
        add_dialogue("The Mayor looks you up and down, not sure if he believes Iolo or not. He looks at Iolo skeptically.")
        second_speaker(1, 0, "\"I swear to thee, it is the Avatar!\"")
        add_dialogue("The mayor looks at you again as if he were studying every pore on your face. Finally, he smiles.")
        add_dialogue("\"Welcome, Avatar.\"")
        add_dialogue("But just as suddenly, Finnigan's face becomes stern.")
        add_dialogue("\"A horrible murder has occurred. If thou art truly the Avatar, perhaps thou canst help us solve it. I would feel better if thou takest this matter into thine hands.")
        var_0005 = ask_yes_no("Thou shalt be handsomely rewarded if thou dost discover the name of the killer. Dost thou accept?\"")
        if var_0005 then
            set_flag(90, true)
            add_dialogue("\"Petre here knows something about all of this.\"")
            second_speaker(11, 0, "The peasant interjects. \"I discovered poor Christopher and the Gargoyle Inamo early this morning.\"")
            var_0006 = ask_yes_no("The Mayor continues. \"Hast thou searched the stables?\"")
            if var_0006 then
                var_000D = ask_multiple_choice({"\"What didst thou find?\"", "a body", "a bucket", "nothing"})
                --set_flag(72, true)
                if var_000D == "a body" then
                    add_dialogue("\"I know that! What ELSE didst thou find? Thou shouldst look again, Avatar!\"")
                elseif var_000D == "a bucket" then
                    add_dialogue("\"Yes, obviously it is filled with poor Christopher's own blood. But surely there was something else that might point us in the direction of the killer or killers - thou shouldst look again, Avatar.\"")
                elseif var_000D == "nothing" then
                    add_dialogue("\"Thou shouldst look again, 'Avatar'!\"")
                end
            else
                add_dialogue("\"Well, do so, then come speak with me!\"")
            end
        else
            add_dialogue("\"Well, thou could not be the real Avatar then!\"")
            set_flag(89, true)
        end

        set_pause(0)
        resume_input()
        show_ui_elements()
        --return
    elseif eventid == 1 then
        start_conversation()
        debug_print("func_0401: eventid == 1")
        player_name = get_player_name()
        player_member_names = get_party_members()
        party_member_1_name = get_npc_name(1) --- Guess: Retrieves object reference from ID
        lord_or_lady = get_lord_or_lady()
        --var_0008 = npc_id_in_party(11) --- Guess: Checks player status
        --var_0009 = npc_id_in_party(3) --- Guess: Checks player status
        var_000A = false
        var_000B = false
        add_answer({"bye", "job", "name"})
            -- if not get_flag(746) then
            --     if get_timer(11) < 1 then --- Guess: Checks party status or conditions
            --         add_dialogue("\"I am sorry, I do not join thieves.\"")
            --         abort()
            --     else
            --         add_dialogue("\"All right, I suppose thou hast learned thy lesson. I shall rejoin.\"")
            --         add_to_party(1) --- Guess: Removes object from game
            --         set_flag(746, false)
            --         abort()
            --     end
            -- end
            if not get_flag(87) then
                add_answer("Trinsic")
            end
            if is_string_in_array(party_member_1_name, player_member_names) then
                add_answer("leave")
            end
            if not is_string_in_array(party_member_1_name, player_member_names) then
                add_answer("join")
            end
            if get_flag(63) then
                add_answer("Fellowship")
            end
            if var_0008 then
                add_answer("Petre")
            end
            if get_flag(60) and not get_flag(87) then
                add_answer("murder")
            else
                add_answer("stables")
            end
            if get_flag(60) then
                remove_answer("stables")
            end
            add_dialogue("\"Yes, my friend?\" Iolo asks.")

            while true do
                coroutine.yield()
                var_000C = get_answer()
                if var_000C == "name" then
                    add_dialogue("Your friend snorts. \"What, art thou joking, " .. lord_or_lady .. "? Thou dost not know thine old friend Iolo?\"")
                    remove_answer("name")
                elseif var_000C == "stables" then
                    add_dialogue("\"Thou must see for thyself, " .. player_name .. ". Brace thyself, my friend. 'Tis truly a horrible sight.\"")
                    clear_answers()
                    return
                elseif var_000C == "job" then
                    add_dialogue("\"Why, right now 'tis adventuring with that most courageous of all legendary heroes, the Avatar!\"")
                    add_answer("Avatar")
                    remove_answer("job")
                elseif var_000C == "Avatar" then
                    add_dialogue("\"Why, there is no doubt -thou- art the Avatar, " .. player_name .. "! However, thou mayest have some trouble convincing those who do not know thy face.\"")
                    add_dialogue("\"Of course, thou -shouldst- be safe around thy friends!\"")
                    remove_answer("Avatar")
                    add_answer({"friends", "trouble"})
                elseif var_000C == "trouble" then
                    add_dialogue("\"Well, after all, thou hast been gone for 200 years! Most of those who would recognize thee are long gone! Sorry to be blunt and all, my friend, but there it is.\"")
                remove_answer("trouble")
                elseif var_000C == "murder" then
                    if not get_flag(61) then
                        add_dialogue("\"Ugly, is it not? From what I have heard, neither Christopher nor Inamo deserved so grisly a death. Thou shouldst certainly ask everyone in town about it.\"")
                    add_answer({"Inamo", "Christopher"})
                    else
                        add_dialogue("\"I wish thee luck in determining what is going on. I haven't a clue!\" Iolo grins broadly, patting you on the back.")
                    end
                remove_answer("murder")
                elseif var_000C == "Lord British" then
                var_000A = true
                    if get_flag(101) then
                        add_dialogue("\"Well, between thee and me, I think that he hath aged much more than I!\"")
                        add_dialogue("\"Full of information, that chap. But he never seems to leave Britain anymore.\"")
                    else
                        add_dialogue("\"My liege will be enormously pleased to see thee. We should travel to Britain post haste. I am sure he can give thee some valuable information and update thee on much of what thou hast missed in the 200 years of thine absence.\"")
                    end
                    if not var_000B then
                        add_answer("Britain")
                    end
                    add_answer("information")
                    remove_answer("Lord British")
                elseif var_000C == "information" then
                    add_dialogue("\"Certainly. LB is always a repository of the most amazing facts, eh? Probably something to do with listening and not always talking.\"")
                    if var_0009 then
                        add_dialogue("\"Right, Shamino?\"~~Shamino grunts and turns away as Iolo grins mischievously.")
                    end
                    add_dialogue("\"Speaking of information, reminds me of something! I have a little item which might be useful to thee. 'Tis an abacus. Use it to tally up all of our gold.\"")
                    remove_answer("information")
                elseif var_000C == "friends" then
                    add_dialogue("\"Thou must mean Shamino and Dupre.\"")
                    remove_answer("friends")
                    add_answer({"Dupre", "Shamino"})
                elseif var_000C == "Dupre" then
                    var_000C = npc_id_in_party(4) --- Guess: Checks player status
                    if var_000C then
                        add_dialogue("\"Why, he is right there, " .. lord_or_lady .. ".\"")
                        second_speaker(4, 0, "\"I am right here, " .. lord_or_lady .. ".\"")
                        add_dialogue("\"See? I told thee!\"")
                    else
                        if ask_yes_no("\"I am sure we shall find him somewhere. Last I heard, he was in Jhelom. Didst thou know he was knighted?\"") then
                                add_dialogue("\"Hard to believe, is it not?\"")
                            else
                                add_dialogue("\"It's true! Lord British knighted him recently. Why he did so, I cannot imagine!\"")
                        end
                        if not var_000A then
                            add_answer("Lord British")
                        end
                    end
                    remove_answer("Dupre")
                elseif var_000C == "Shamino" then
                    if var_0009 then
                        add_dialogue("\"Why, he is right there, " .. lord_or_lady .. ".\"")
                        second_speaker(3, 0, "\"I am right here, " .. lord_or_lady .. ".\"")
                        add_dialogue("\"See? I told thee!\"")
                    else
                        add_dialogue("\"Thy best bet in finding that rascal is to look in Britain. He has a girlfriend employed as an actress at the Royal Theatre.\"")
                        if not var_000B then
                            add_answer("Britain")
                        end
                    end
                    remove_answer("Shamino")
                elseif var_000C == "Trinsic" then
                    add_dialogue("\"The town has changed little, has it not? Everyone seems a little defensive, though. When we ran into each other, I was passing through and had stopped to visit my friend Finnigan.\"")
                    remove_answer("Trinsic")
                    add_answer({"Finnigan", "defensive"})
                elseif var_000C == "defensive" then
                    add_dialogue("\"I think it best for thee to speak with them thyself. There have been many changes since last thou didst visit, Avatar. I think thou wilt feel at times a bit... well, old-fashioned.\"")
                    remove_answer("defensive")
                elseif var_000C == "Britain" then
                    var_000B = true
                    add_dialogue("\"It has grown since thou last saw it. Paws is now a virtual township of Britain! It dominates the east coast of Britannia.~~\"Lord British's castle is still the overwhelming feature.\"")
                    remove_answer("Britain")
                    if not var_000A then
                        add_answer("Lord British")
                    end
                    add_answer("Paws")
                elseif var_000C == "Paws" then
                    add_dialogue("\"It still lies between Britain and Trinsic, but it has grown further into Britain itself.\"")
                    remove_answer("Paws")
                elseif var_000C == "Finnigan" then
                    add_dialogue("\"He is a good man. The Mayor of Trinsic, he is. I have known him for years.\"")
                    remove_answer("Finnigan")
                elseif var_000C == "Christopher" then
                    add_dialogue("\"I did not know him, " .. lord_or_lady .. ".\"")
                    remove_answer("Christopher")
                elseif var_000C == "Inamo" then
                    add_dialogue("\"I never spoke with him. It is truly a shame. There are not many gargoyles living amongst the humans. This will only discourage the practice even more.\"")
                    remove_answer("Inamo")
                    add_answer("gargoyles")
                elseif var_000C == "leave" then
                    add_dialogue("Iolo looks hurt. \"Thou dost really want me to leave?\"")
                    var_000D = select_option()
                    if var_000D then
                        add_dialogue("\"Dost thou want me to wait here or dost thou want me to go home to Yew?\"")
                        save_answers()
                        var_000E = ask_answer({"go home", "wait here"})
                        if var_000E == "wait here" then
                            add_dialogue("\"Very well. I shall wait here until thou dost return and ask me to rejoin.\"")
                            remove_from_party(1) --- Guess: Sets object state (e.g., active/inactive)
                            set_schedule_type(15, 1) --- Guess: Sets a generic object property
                            abort()
                        else
                            add_dialogue("\"Farewell, then. I shall always rejoin if thou dost so desire.\" Iolo turns away from you.")
                            remove_from_party(1) --- Guess: Sets object state (e.g., active/inactive)
                            set_schedule_type(11, 1) --- Guess: Sets a generic object property
                            abort()
                        end
                    else
                        add_dialogue("\"Whew. Thou didst frighten me!\"")
                    end
                elseif var_000C == "join" then
                    add_dialogue("\"I was waiting until thou didst ask me!\"")
                    var_000F = 0
                    for var_0010 = 1, 8 do
                        var_000F = var_000F + 1
                    end
                    if var_000F < 8 then
                        add_dialogue("\"It seems that thou hast enough members travelling with thee already! I shall wait until someone leaves the group.\"")
                    else
                        add_to_party(1) --- Guess: Removes object from game
                        remove_answer("join")
                        add_answer("leave")
                    end
                elseif var_000C == "gargoyles" then
                    add_dialogue("\"Since thou wert last in Britannia, the Gargoyles have begun to integrate with the humans. Most of them live on Sutek's old island, which was renamed 'Terfin'. However, thou mayest see one here and there throughout the land.\"")
                    remove_answer("gargoyles")
                elseif var_000C == "Fellowship" then
                    add_dialogue("\"I do not know much about them, except that they originated about twenty Britannian years ago. They seem to do good deeds and are looked at with favor by most everyone. They have branch offices all over Britannia. I have not personally had any dealings with them.\"")
                    remove_answer("Fellowship")
                elseif var_000C == "Petre" then
                    add_dialogue("\"He is just an acquaintance.\"")
                    remove_answer("Petre")
                elseif var_000C == "bye" then
                    add_dialogue("\"'Tis always a pleasure to speak with thee, my friend.\"")
                    clear_answers()
                end
            end
            elseif eventid == 0 then
                utility_unknown_1070(1) --- Guess: Triggers a game event
            end
        end