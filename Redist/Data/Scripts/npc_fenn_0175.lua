--- Best guess: Manages Fenn's dialogue in Paws, a beggar defending Tobias, criticizing The Fellowship, and discussing his past with Komor and Merrick.
function npc_fenn_0175(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    if eventid == 1 then
        switch_talk_to(175)
        var_0000 = get_lord_or_lady()
        start_conversation()
        add_answer({"bye", "job", "name"})
        if get_flag(530) then
            add_answer("thief")
        end
        if not get_flag(552) then
            add_dialogue("You see a beggar. You cannot tell from the look on his face whether he is about to laugh or cry.")
            set_flag(552, true)
        else
            add_dialogue("\"Beg thy pardon, " .. var_0000 .. ",\" Fenn says.")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"My name is Fenn, " .. var_0000 .. ".\"")
                remove_answer("name")
            elseif answer == "thief" then
                if get_flag(536) then
                    add_dialogue("After you tell him about finding the venom vial, he says, \"Thou didst our town a service when thou didst uncover that no good brat Garritt as the thief! Perhaps now some people will start to realize the hypocrisy of the Fellowship!\"")
                elseif get_flag(531) then
                    add_dialogue("\"I know that boy Tobias is innocent of any wrong doing, no matter what Feridwyn and his Fellowship says.\"")
                else
                    add_dialogue("\"Be wary for there is a thief in this town! Some silver serpent venom was stolen from the merchant Morfin, who runs the slaughterhouse.\"")
                    set_flag(530, true)
                end
                remove_answer("thief")
            elseif answer == "job" then
                add_dialogue("He looks away from you shamefully. \"I have none, " .. var_0000 .. ".\"")
                add_answer("none")
            elseif answer == "none" then
                add_dialogue("\"I used to be a farmer in more prosperous times. I used to work with Komor and Merrick.\"")
                add_answer({"give", "Merrick", "Komor"})
                remove_answer("none")
            elseif answer == "Komor" then
                add_dialogue("\"He is my best friend and the bravest man I know.\"")
                var_0001 = npc_id_in_party(174)
                if var_0001 then
                    add_dialogue("*")
                    switch_talk_to(174)
                    add_dialogue("\"Oh, please! Thou art making mine eyes leak!\"")
                    hide_npc(174)
                    switch_talk_to(175)
                end
                remove_answer("Komor")
            elseif answer == "Merrick" then
                add_dialogue("\"Merrick joined The Fellowship so he could live in their shelter, the poor sod.\"")
                add_answer({"Fellowship", "shelter"})
                remove_answer("Merrick")
            elseif answer == "Fellowship" then
                add_dialogue("\"If The Fellowship truly wants to help people, why would they let us starve just because we do not want to join? They cannot answer that one!\"")
                add_answer("starve")
                remove_answer("Fellowship")
            elseif answer == "shelter" then
                add_dialogue("\"Hmf! If thou art so unfortunate as to want to live there, thou wouldst do better on the corner with Komor and I.\"")
                remove_answer("shelter")
                add_answer("corner")
            elseif answer == "corner" then
                add_dialogue("\"Even when pockets are light, there is still some mercy left in this world. Begging for money is not a proud profession, but there are worse ones.\"")
                add_answer("worse")
                remove_answer("corner")
            elseif answer == "worse" then
                add_dialogue("\"At least we do not have to do what Merrick does. He recruits for The Fellowship.\"")
                remove_answer("worse")
            elseif answer == "starve" then
                add_dialogue("\"Do not worry. We shall not starve. Camille sends her son Tobias with food and clothing for us every so often.\"")
                add_answer({"Tobias", "Camille"})
                remove_answer("starve")
            elseif answer == "Camille" then
                add_dialogue("\"Camille is a good woman. She lives at the farm bordering the dairy.\"")
                remove_answer("Camille")
            elseif answer == "Tobias" then
                add_dialogue("\"He is a fine lad, always willing to give us a hand. Unlike that rude urchin, Garritt.\"")
                if get_flag(531) then
                    add_answer("venom")
                end
                add_answer("Garritt")
                remove_answer("Tobias")
            elseif answer == "venom" then
                add_dialogue("\"Tobias would not become involved with that sort of affair. I know for certain he is no thief.\"")
                remove_answer("venom")
                add_answer("involved")
            elseif answer == "involved" then
                add_dialogue("\"If thou art seeking out this venom thief, thou wouldst do well to ask Andrew about it.\"")
                add_answer("Andrew")
                remove_answer("involved")
            elseif answer == "Andrew" then
                add_dialogue("\"Andrew owns the dairy and lives across from Camille's farm and the slaughterhouse. He might have seen something.\"")
                remove_answer("Andrew")
            elseif answer == "Garritt" then
                add_dialogue("\"He is the son of Feridwyn and Brita, who run the shelter. Garritt crosses the road to avoid us.\"")
                var_0001 = npc_id_in_party(174)
                if var_0001 then
                    add_dialogue("*")
                    switch_talk_to(174)
                    add_dialogue("\"We would not want the likes of him walking down our side of the road anyway!\"")
                    hide_npc(174)
                    switch_talk_to(175)
                end
                remove_answer("Garritt")
            elseif answer == "give" then
                add_dialogue("\"Wilt thou give me a bit of money?\"")
                if ask_yes_no() then
                    add_dialogue("How much?")
                    save_answers()
                    var_0002 = utility_unknown_1035("5", "4", "3", "2", "1", "0")
                    var_0003 = count_objects(359, 644, 357)
                    if var_0003 >= var_0002 and var_0002 ~= "0" then
                        var_0004 = remove_party_items(true, 359, 644, 359, var_0002)
                        add_dialogue("\"Thank thee, " .. var_0000 .. ".\"")
                    else
                        add_dialogue("\"It appears thou dost not have any money either!\"")
                    end
                    if var_0003 == 0 then
                        add_dialogue("\"I am truly sorry if I have bothered thee, " .. var_0000 .. ".\"")
                    end
                    restore_answers()
                else
                    add_dialogue("Fenn hangs his head low.")
                end
                remove_answer("give")
            elseif answer == "bye" then
                add_dialogue("\"Good fortune to ye, " .. var_0000 .. ".\"")
                break
            end
        end
    elseif eventid == 0 then
        var_0005 = get_schedule(175)
        var_0006 = get_schedule_type(get_npc_name(175))
        var_0007 = random2(4, 1)
        if var_0006 == 11 then
            if var_0007 == 1 then
                var_0008 = "@A coin for some food?@"
            elseif var_0007 == 2 then
                var_0008 = "@Please aid a poor beggar!@"
            elseif var_0007 == 3 then
                var_0008 = "@Show some generosity!@"
            elseif var_0007 == 4 then
                var_0008 = "@Help one less fortunate!@"
            end
            bark(175, var_0008)
        else
            utility_unknown_1070(175)
        end
    end
    return
end