--- Best guess: Handles dialogue with Bradman, an archer trainer in Yew, discussing his training services, love for the forest, admiration for archers Iolo and Tseramed, and his friend Penni’s lack of hunting skill.
function func_0468(eventid, itemref)
    local var_0000, var_0001, var_0002

    start_conversation()
    if eventid == 1 then
        switch_talk_to(104, 0)
        var_0000 = get_player_title()
        add_answer({"bye", "job", "name"})
        if not get_flag(322) then
            add_dialogue("You see a man leaning on a longbow.")
            set_flag(322, true)
        else
            add_dialogue("Bradman greets you. \"Hail, " .. var_0000 .. ".\"")
        end
        while true do
            var_0001 = get_answer()
            if var_0001 == "name" then
                add_dialogue("\"I am Bradman.\"")
                remove_answer("name")
            elseif var_0001 == "job" then
                add_dialogue("\"Why, 'tis my job to train the many who visit Yew to become more agile.\"")
                add_answer({"many", "train", "Yew"})
                if get_flag(333) then
                    add_answer("Penni")
                end
            elseif var_0001 == "many" then
                add_dialogue("\"The forest attracts a lot of people who want to spend some time away from the larger towns like Minoc and Britain. So they come to Yew.\"")
                add_dialogue("\"And, something about the woods makes most people want to explore.\" He pats his bow.")
                add_dialogue("\"That is where this comes in. The bow is the tool of survival in the forest. And I,\" he jerks his thumb to his chest, \"teach proficiency with the bow.\"")
                remove_answer("many")
                add_answer({"bow", "explore"})
            elseif var_0001 == "explore" then
                add_dialogue("\"There are many exciting things to see in the forest. Not a day goes by when I do not see something interesting: a new type of bird, a beautiful butterfly, or, best of all -- a deer.\"")
                remove_answer("explore")
            elseif var_0001 == "bow" then
                add_dialogue("\"'Tis my weapon of choice. It takes a keen eye and a steady arm to shoot accurately. I think it has more finesse than a sword or a spear, for example.\"")
                remove_answer("bow")
            elseif var_0001 == "Yew" then
                add_dialogue("\"I love the forest. It is very beautiful. Also,\" he raises his bow, \"I moved out here to be near the two great archers, Iolo and Tseramed.\"")
                var_0001 = unknown_08F7H(1) --- Guess: Checks player status
                var_0002 = unknown_08F7H(10) --- Guess: Checks player status
                if var_0001 then
                    switch_talk_to(1, 0)
                    add_dialogue("Iolo blushes. \"I am honored, my friend. I was not aware I had an admirer in this part of the land.\" He bows to Bradman, who returns the gesture.")
                    hide_npc(1)
                    switch_talk_to(104, 0)
                end
                if var_0002 then
                    switch_talk_to(10, 0)
                    add_dialogue("\"Thank you for thy kind words, good sir. Perhaps we may practice sometime in the future.\"")
                    hide_npc(10)
                    switch_talk_to(104, 0)
                    add_dialogue("\"I would be greatly honored, milord!\"")
                else
                    add_answer("Tseramed")
                end
                remove_answer("Yew")
            elseif var_0001 == "Tseramed" then
                add_dialogue("\"He is a great archer who resides in the forest. He moved here to get away from the far-too-quickly growing towns.\"")
                remove_answer("Tseramed")
            elseif var_0001 == "train" then
                add_dialogue("\"If thou wantest to train, my charge is 30 gold. Art thou still interested?\"")
                if select_option() then
                    unknown_0856H(30, 1) --- Guess: Trains player
                else
                    add_dialogue("\"I understand, " .. var_0000 .. ".\"")
                end
            elseif var_0001 == "Penni" then
                add_dialogue("\"Thou hast met Penni? I hope thou hast not trained with her,\" he winks. \"She is a valuable friend, but she hunts as well as a weed and she is as clumsy as an ox. I am afraid she knows nothing about fighting.\"")
                remove_answer("Penni")
            elseif var_0001 == "bye" then
                break
            end
        end
        add_dialogue("\"May the trees part around thee, " .. var_0000 .. ".\"")
    elseif eventid == 0 then
        unknown_092EH(104) --- Guess: Triggers a game event
    end
end