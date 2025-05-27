--- Best guess: Handles dialogue with Trellek the Emp, discussing his role, family, and a whistle to talk to wisps, with conditions for joining.
function func_0406(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F

    start_conversation()
    if eventid == 1 then
        var_0000 = get_player_name()
        var_0001 = "Avatar"
        var_0002 = get_party_members()
        var_0003 = false
        var_0004 = get_npc_name(6) --- Guess: Retrieves object reference from ID
        var_0005 = get_npc_name(10) --- Guess: Retrieves object reference from ID
        var_0006 = check_inventory(359, 359, 772, 1, 357)
        switch_talk_to(6, 0)
        if not get_flag(308) then
            if not var_0006 then
                add_dialogue("The creature ignores you.")
                abort()
            else
                unknown_08EEH() --- Guess: Checks Emp-specific status
            end
        end
        add_answer({"bye", "job", "name"})
        if get_flag(294) then
            var_0007 = var_0000
        end
        if get_flag(295) then
            var_0007 = var_0001
        end
        if not get_flag(25) then
            add_dialogue("The ape-like creature peers at you intently for a few minutes. Then, shrugging, it walks cautiously up to you. \"I am Trellek. Your name is?\"")
            save_answers()
            var_0008 = ask_answer({var_0001, var_0000})
            if var_0008 == var_0000 then
                set_flag(294, true)
            end
            if var_0008 == var_0001 then
                set_flag(295, true)
            end
            set_flag(316, true)
            set_flag(25, true)
            add_dialogue("\"You are greeted.\"")
        else
            add_dialogue("The Emp peers at you intensely for a few minutes. Then, shrugging, it walks cautiously up to you. \"I am Trellek. Your name is?\"")
            save_answers()
            var_0008 = ask_answer({var_0001, var_0000})
            if var_0008 == var_0000 then
                set_flag(294, true)
                var_0007 = var_0000
            end
            if var_0008 == var_0001 then
                set_flag(295, true)
                var_0007 = var_0001
            end
            set_flag(25, true)
            add_dialogue("\"You are greeted, " .. var_0007 .. ".\"")
        end
        if get_flag(296) and not get_flag(342) then
            if not get_flag(344) then
                if not get_flag(341) then
                    add_answer("Saralek's idea")
                end
            else
                add_answer("No permission")
            end
        elseif not get_flag(306) then
            add_answer("wisps")
        end
        if get_flag(297) then
            add_answer("Julius")
        end
        if get_flag(337) and not get_flag(306) then
            add_answer("join")
        end
        while true do
            var_0009 = get_answer()
            if var_0009 == "name" then
                add_dialogue("\"My name is still Trellek.\"")
                remove_answer("name")
            elseif var_0009 == "job" then
                add_dialogue("He gives you a puzzled look.~~\"The meaning of `job' is not clear to me. Is `work' the word meant by you?\"")
                var_000A = select_option()
                if var_000A then
                    add_dialogue("\"I am a gatherer of food.\"")
                    add_answer("gatherer")
                else
                    add_dialogue("\"No job is had by me.\"")
                end
            elseif var_0009 == "gatherer" then
                add_dialogue("\"All Emps are food-gatherers. Mainly fruits are sought by us.\"")
                remove_answer("gatherer")
                add_answer({"Emps", "fruits"})
            elseif var_0009 == "fruits" then
                add_dialogue("\"Fruits are pleasant-tasting, like the honey you gave us!\"")
                remove_answer("fruits")
            elseif var_0009 == "Emps" then
                add_dialogue("\"I am an Emp. Saralek is an Emp. Salamon is an Emp. You,\" he smiles, \"are a human.\"")
                remove_answer("Emps")
                add_answer({"Salamon", "Saralek"})
            elseif var_0009 == "Saralek" then
                add_dialogue("\"Saralek is my bonded-one. `Wife' is what you would call her. My home is her home.\"")
                add_answer("home")
                remove_answer("Saralek")
            elseif var_0009 == "home" then
                add_dialogue("\"Silverleaf trees are our homes,\" he nods.")
                remove_answer("home")
                add_answer("Silverleaf trees")
            elseif var_0009 == "Silverleaf trees" then
                add_dialogue("\"Silverleaf trees cannot be explained by me in human terms. I am sorry. Another human should be asked by you?\" he shrugs, imitating the human gesture rather well.")
                remove_answer("Silverleaf trees")
            elseif var_0009 == "Salamon" then
                add_dialogue("\"Salamon is the wisest Emp. Humans have been met by her. -Many- things have been seen by her. She is very experienced and knowledgeable.\"")
                remove_answer("Salamon")
            elseif var_0009 == "wisps" then
                add_dialogue("\"Wisps are known to me,\" he nods. \"Wisps are found in the woods. What is your concern?\"")
                add_answer({"talk to wisps", "woods"})
                remove_answer("wisps")
            elseif var_0009 == "No permission" then
                add_dialogue("\"For you to talk to wisps is still your wish? Then helping you is my goal. A whistle can be made by me.\"")
                remove_answer("No permission")
                add_answer("whistle")
            elseif var_0009 == "Saralek's idea" then
                add_dialogue("\"Correct was my bonded-one. A whistle can be made by me.\"")
                add_answer("whistle")
                remove_answer("Saralek's idea")
            elseif var_0009 == "woods" then
                add_dialogue("\"The residence of the wisps is a stone building in a mountain in the middle of the forest.\"")
                remove_answer("woods")
            elseif var_0009 == "whistle" then
                add_dialogue("\"A whistling sound is made by Emps when talking is done by us. An imitation of that sound can be created by a special whistle,\" he says enthusiastically.~~He begins quickly searching around for a dead, hollow, fallen tree branch. Shortly he finds one that meets his satisfaction. Apparently embarrassed, he turns his back to you, and makes motions similar to one twisting a cork from a flagon.~~After a few minutes of this, he turns around and presents the whistle to you.")
                var_000B = unknown_002CH(false, 1, 359, 693, 1) --- Guess: Adds item to inventory
                if var_000B then
                    add_dialogue("\"Here is your whistle.\"")
                    unknown_0911H(50) --- Guess: Adds whistle item to inventory
                    set_flag(342, true)
                else
                    add_dialogue("\"Fewer items must be carried by you to take this whistle.\"")
                end
                remove_answer("whistle")
            elseif var_0009 == "talk to wisps" then
                add_dialogue("\"Your statement is a mystery. For me to talk to wisps is what you want?\"")
                var_000C = select_option()
                if var_000C then
                    add_dialogue("He looks around, apparently surveying the area.~~ \"No wisps are here for conversation.\"")
                    add_answer("go there")
                else
                    add_dialogue("\"Your want is not conveyed to me.\" He shrugs.")
                end
                remove_answer("talk to wisps")
            elseif var_0009 == "Julius" then
                play_music(0, 26)
                add_dialogue("\"Julius was a good human. His great deed was saving Emp family from big fire years ago.\" He stares at you directly.~~\"But, his story is sad, being about his death from too much smoke in his body. His body is in the cemetery near the Abbey. He is one human that Emps call 'hero'.\"")
                set_flag(297, true)
                remove_answer("Julius")
            elseif var_0009 == "go there" or var_0009 == "join" then
                add_dialogue("\"Your wish is for me to travel with you?\"")
                var_000D = select_option()
                if var_000D then
                    add_dialogue("\"My wish is that also. But that is not the wish of Saralek, my wife. Permission from her must first be gained.\"")
                    set_flag(306, true)
                else
                    add_dialogue("\"You are very odd, " .. var_0007 .. ".\"")
                end
                var_000E = true
                remove_answer({"join", "go there"})
            elseif var_0009 == "bye" then
                break
            end
        end
        add_dialogue("\"Good luck is hoped for you.\"")
    elseif eventid == 0 then
        var_000F = get_schedule() --- Guess: Checks game state or timer
        var_000D = get_npc_name(6) --- Guess: Retrieves object reference from ID
        var_000E = unknown_001CH(6) --- Guess: Gets object state
        var_000F = random(1, 4)
        var_0006 = check_inventory(359, 359, 772, 1, 357)
        if var_000E == 11 then
            if not var_0006 then
                var_000F = "@You are greeted.@"
            end
            if var_000F == 1 then
                var_000F = "@You are greeted.@"
            elseif var_000F == 2 then
                var_000F = "@Hello is said to you.@"
            elseif var_000F == 3 then
                var_000F = "@A good day is hoped for you.@"
            elseif var_000F == 4 then
                var_000F = "@The day is nice.@"
            end
        end
        if var_000E == 14 then
            var_000F = "@Zzzzz...@"
        end
        bark(6, var_000F)
    end
end