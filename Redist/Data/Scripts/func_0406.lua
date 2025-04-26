-- Manages Trellek the Emp's dialogue, covering his food gathering, wife Saralek, wisp knowledge, and potential party joining.

-- Global variables for answer handling
answers = answers or {}
answer = answer or nil

function func_0406(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9
    local local10, local11, local12, local13, local14, local15

    if eventid == 1 then
        local0 = get_player_name()
        local1 = "Avatar"
        local2 = get_party_members()
        local3 = false
        local4 = switch_talk_to(-6)
        local5 = get_item_type(-10)
        local6 = has_item(-359, -359, 772, 1, -357)

        switch_talk_to(-6, 0)

        if not get_flag(25) then
            local7 = local0
        elseif get_flag(310) then
            local7 = local0
        elseif get_flag(311) then
            local7 = local1
        end

        if not get_flag(25) then
            if not answer then
                say("The ape-like creature peers at you intently for a few minutes. Then, shrugging, it walks cautiously up to you. \"I am Trellek. Your name is?\"")
                answers = {local1, local0}
                answer = get_answer(answers)
                return
            elseif answer == local0 then
                say("\"So? What makes thee so special?\"*")
                local7 = local0
                set_flag(310, true)
            elseif answer == local1 then
                say("\"The last time I heard -that- one I fell off a prehistoric creature from Eodon!\"")
                local7 = local1
                set_flag(311, true)
            else
                answers = {}
                answer = nil
                return
            end
            if local5 then
                switch_talk_to(-1, 0)
                say("\"Boy, this is the Avatar! Upon my word he is! He has come to help thee!\"*")
                hide_npc(-1)
                switch_talk_to(-6, 0)
            end
            say("\"You are greeted.\"")
            set_flag(25, true)
            set_flag(316, true)
        else
            if not answer then
                say("\"You are greeted, " .. local7 .. ".\"")
                answers = {}
                add_answer({"bye", "job", "name"})
                if get_flag(312) and not get_flag(326) then
                    add_answer("Saralek's idea")
                elseif get_flag(325) then
                    add_answer("No permission")
                elseif not get_flag(306) then
                    add_answer("wisps")
                end
                if not get_flag(226) then
                    add_answer("Julius")
                end
                if not get_flag(337) and not get_flag(306) then
                    add_answer("join")
                end
                answer = get_answer()
                return
            end
        end

        -- Process answer
        if answer == "name" then
            say("\"My name is still Trellek.\"")
            remove_answer("name")
        elseif answer == "job" then
            say("He gives you a puzzled look.~~\"The meaning of `job' is not clear to me. Is `work' the word meant by you?\"")
            answers = {true, false}
            answer = nil
            return
        elseif answer == true then
            say("\"I am a gatherer of food.\"")
            add_answer("gatherer")
        elseif answer == false then
            say("\"No job is had by me.\"")
        elseif answer == "gatherer" then
            say("\"All Emps are food-gatherers. Mainly fruits are sought by us.\"")
            remove_answer("gatherer")
            add_answer({"Emps", "fruits"})
        elseif answer == "fruits" then
            say("\"Fruits are pleasant-tasting, like the honey you gave us!\"")
            remove_answer("fruits")
        elseif answer == "Emps" then
            say("\"I am an Emp. Saralek is an Emp. Salamon is an Emp. You,\" he smiles, \"are a human.\"")
            remove_answer("Emps")
            add_answer({"Salamon", "Saralek"})
        elseif answer == "Saralek" then
            say("\"Saralek is my bonded-one. `Wife' is what you would call her. My home is her home.\"")
            add_answer("home")
            remove_answer("Saralek")
        elseif answer == "home" then
            say("\"Silverleaf trees are our homes,\" he nods.")
            remove_answer("home")
            add_answer("Silverleaf trees")
        elseif answer == "Silverleaf trees" then
            say("\"Silverleaf trees cannot be explained by me in human terms. I am sorry. Another human should be asked by you?\" he shrugs, imitating the human gesture rather well.")
            remove_answer("Silverleaf trees")
        elseif answer == "Salamon" then
            say("\"Salamon is the wisest Emp. Humans have been met by her. -Many- things have been seen by her. She is very experienced and knowledgeable.\"")
            remove_answer("Salamon")
        elseif answer == "wisps" then
            say("\"Wisps are known to me,\" he nods. \"Wisps are found in the woods. What is your concern?\"")
            add_answer({"talk to wisps", "woods"})
            remove_answer("wisps")
        elseif answer == "No permission" then
            say("\"For you to talk to wisps is still your wish? Then helping you is my goal. A whistle can be made by me.\"")
            remove_answer("No permission")
            add_answer("whistle")
        elseif answer == "Saralek's idea" then
            say("\"Correct was my bonded-one. A whistle can be made by me.\"")
            add_answer("whistle")
            remove_answer("Saralek's idea")
        elseif answer == "woods" then
            say("\"The residence of the wisps is a stone building in a mountain in the middle of the forest.\"")
            remove_answer("woods")
        elseif answer == "whistle" then
            say("\"A whistling sound is made by Emps when talking is done by us. An imitation of that sound can be created by a special whistle,\" he says enthusiastically.~~He begins quickly searching around for a dead, hollow, fallen tree branch. Shortly he finds one that meets his satisfaction. Apparently embarrassed, he turns his back to you, and makes motions similar to one twisting a cork from a flagon.~~After a few minutes of this, he turns around and presents the whistle to you.")
            local10 = add_item(false, 1, -359, 693, 1)
            if not local10 then
                say("\"Here is your whistle.\"")
                apply_effect(50)
                set_flag(326, true)
            else
                say("\"Fewer items must be carried by you to take this whistle.\"")
            end
            remove_answer("whistle")
        elseif answer == "talk to wisps" then
            say("\"Your statement is a mystery. For me to talk to wisps is what you want?\"")
            answers = {true, false}
            answer = nil
            return
        elseif answer == true then
            say("He looks around, apparently surveying the area.~~ \"No wisps are here for conversation.\"")
            add_answer("go there")
        elseif answer == false then
            say("\"Your want is not conveyed to me.\" He shrugs.")
        elseif answer == "Julius" then
            play_music(26, 0)
            say("\"Julius was a good human. His great deed was saving Emp family from big fire years ago.\" He stares at you directly.~~\"But, his story is sad, being about his death from too much smoke in his body. His body is in the cemetery near the Abbey. He is one human that Emps call 'hero'.\"")
            set_flag(297, true)
            remove_answer("Julius")
        elseif answer == "join" then
            say("\"Your wish is for me to travel with you?\"")
            answers = {true, false}
            answer = nil
            return
        elseif answer == true then
            say("\"My wish is that also. But that is not the wish of Saralek, my wife. Permission from her must first be gained.\"")
            set_flag(306, true)
            remove_answer({"join", "go there"})
        elseif answer == false then
            say("\"You are very odd, " .. local7 .. ".\"")
            remove_answer({"join", "go there"})
        elseif answer == "bye" then
            say("\"Good luck is hoped for you.\"*")
            answers = {}
            answer = nil
            return
        end

        -- Clear answer if not handled
        answer = nil
        return
    elseif eventid == 0 then
        local12 = get_schedule()
        local13 = switch_talk_to(-6)
        local14 = check_item_state(-6)
        local15 = random(1, 4)
        local6 = has_item(-359, -359, 772, 1, -357)

        if local14 == 11 and not local6 then
            if local15 == 1 then
                local15 = "@You are greeted.@"
            elseif local15 == 2 then
                local15 = "@Hello is said to you.@"
            elseif local15 == 3 then
                local15 = "@A good day is hoped for you.@"
            elseif local15 == 4 then
                local15 = "@The day is nice.@"
            end
        elseif local14 == 14 then
            local15 = "@Zzzzz...@"
        end
        item_say(local15, -6)
        answers = {}
        answer = nil
    end
    return
end