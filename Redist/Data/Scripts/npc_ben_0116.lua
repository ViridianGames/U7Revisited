--- Best guess: Handles dialogue with Ben, a logger in Yew, discussing his family's logging tradition, the forest, and his agreement to stop cutting Silverleaf trees for the Emps by signing a contract.
function npc_ben_0116(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    start_conversation()
    if eventid == 1 then
        switch_talk_to(116, 0)
        var_0000 = get_lord_or_lady()
        add_answer({"bye", "job", "name"})
        if not get_flag(334) then
            add_dialogue("Resting an axe on his shoulder, a tall, broad-chested man smiles and nods at you.")
            set_flag(334, true)
        else
            add_dialogue("\"'ello, " .. var_0000 .. ". Good day, ay?\"")
        end
        while true do
            var_0001 = get_answer()
            if var_0001 == "name" then
                add_dialogue("\"Thou kin call me Ben, " .. var_0000 .. ". I live 'ere in the forest of Yew.\"")
                remove_answer("name")
                add_answer({"forest", "Yew"})
            elseif var_0001 == "job" then
                add_dialogue("\"I be a logger, " .. var_0000 .. ". 'Tis what I have done all my life. In fact, " .. var_0000 .. ", 'tis what my father did. And 'is father before 'im. And so on. We have been doin' this for more than ten generations.\"")
                if not get_flag(298) then
                    add_answer("Silverleaf")
                end
            elseif var_0001 == "Yew" then
                add_dialogue("\"It was once a large town, but now, 'tis but a smattering of cottages livin' throughout the woods.\"")
                remove_answer("Yew")
            elseif var_0001 == "forest" then
                add_dialogue("\"I am afraid, " .. var_0000 .. ", that I know no one in this area. But,\" he adds proudly, \"I do know 'oo runs the sawmill in Minoc. I also know that monks reside in the abbey, next to the high court.\"")
                add_answer({"high court", "sawmill"})
                remove_answer("forest")
            elseif var_0001 == "sawmill" then
                add_dialogue("\"The sawyer there is named William.\"")
                remove_answer("sawmill")
            elseif var_0001 == "high court" then
                add_dialogue("\"'Tis in the building just northeast of the Brotherhood. I know they keep prisoners there.\"")
                remove_answer("high court")
            elseif var_0001 == "Silverleaf" then
                add_dialogue("\"Why, yes, " .. var_0000 .. ", I cut down Silverleaf trees. They only grow in one area, so I 'afta travel quite a distance when I needs some of their wood. Why dost thou ask, " .. var_0000 .. "?\"")
                add_dialogue("\"Oh, I see,\" he grins, \"Thou wants some for thyself, ay?\"")
                var_0001 = select_option()
                if var_0001 then
                    add_dialogue("\"I am sorry, " .. var_0000 .. ", I do not know 'ow to prepare it. Perhaps thou shouldst try a pub.\"")
                else
                    add_dialogue("\"Thou'st got another reason for askin'?\"")
                    var_0002 = select_option()
                    if var_0002 then
                        save_answers()
                        add_answer("Emps")
                    else
                        add_dialogue("\"All right, " .. var_0000 .. ",\" he shrugs.")
                    end
                end
                add_answer("one area")
                remove_answer("Silverleaf")
            elseif var_0001 == "one area" then
                add_dialogue("\"They mainly populate the east part o' the Great Forest, way on the other side.\"")
                remove_answer("one area")
            elseif var_0001 == "Emps" then
                add_dialogue("\"What in the bloody 'ell are emps?\"")
                add_dialogue("After you quickly explain the Silverleaf Tree situation to him, he exclaims, \"Oh, well, that's 'orrible. I did not realize anyone -- er -- any other creature used the Silverleaf trees. What kin I do about it?\"")
                restore_answers()
                add_answer("sign contract")
                remove_answer("Emps")
            elseif var_0001 == "sign contract" then
                add_dialogue("\"Why, o' course I'll sign. No more Silverleaf trees for me.\"")
                var_0003 = utility_unknown_1073(359, 3, 797, 1, 357) --- Guess: Checks item in inventory
                if var_0003 then
                    add_dialogue("He takes the contract from you and signs it.")
                    var_0004 = npc_id_in_party(6) --- Guess: Checks player status
                    if var_0004 then
                        add_dialogue("He turns to Trellek. \"Please apologize to thy kindred for me. I never meant to destroy thine 'omes. Friends, ay?\"")
                        add_dialogue("Trellek smiles and nods.")
                    else
                        add_dialogue("\"And please apologize to the Emps for me, " .. var_0000 .. ". I never meant to destroy their 'omes.\"")
                    end
                    set_flag(299, true)
                    utility_unknown_1041(500) --- Guess: Submits item or advances quest
                else
                    add_dialogue("\"Well, I would sign it, but it seems thou hast lost it. If thou dost find it again I will be more than happy to help thee and the Emps.\"")
                end
                restore_answers()
                remove_answer("sign contract")
            elseif var_0001 == "bye" then
                break
            end
        end
        add_dialogue("\"G'bye, " .. var_0000 .. ". Pleasant journeys, ay.\"")
    elseif eventid == 0 then
        abort()
    end
end