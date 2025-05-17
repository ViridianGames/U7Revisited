--- Best guess: Handles dialogue with Zella, a trainer in Britain specializing in boxing, discussing her combat philosophy and offering training for 45 gold.
function func_0424(eventid, objectref)
    local var_0000, var_0001

    start_conversation()
    if eventid == 1 then
        switch_talk_to(36, 0)
        var_0000 = get_schedule() --- Guess: Checks game state or timer
        var_0001 = unknown_001CH(36) --- Guess: Gets object state
        add_answer({"bye", "job", "name"})
        if not get_flag(165) then
            add_dialogue("You see a lean, young fighter with a rather dashing flair.")
            set_flag(165, true)
        else
            add_dialogue("\"Hello again!\" Zella says.")
        end
        while true do
            var_0000 = get_answer()
            if var_0000 == "name" then
                add_dialogue("\"My name is Zella.\"")
                remove_answer("name")
            elseif var_0000 == "job" then
                add_dialogue("\"I am a trainer. I specialize in hand-to-hand combat. After all, a fighter never knows when he might encounter an adversary and suddenly realize he is unarmed. I call it 'boxing'. Boxing is not only a method of fighting -- it is an art.\"")
                add_answer({"train", "combat"})
            elseif var_0000 == "combat" then
                add_dialogue("\"The field of battle contains many arenas. Almost any situation could arise. Every fighter should be knowledgeable and adept at many forms of combat. I have mine own theory of fighting.\"")
                remove_answer("combat")
                add_answer({"theory", "arenas"})
            elseif var_0000 == "arenas" then
                add_dialogue("\"All the various arenas of combat, all the various styles one may learn in fighting with various weapons, are not fighting in its purest form. To truly be a great fighter one must go to the source of all fighting knowledge.\"")
                remove_answer("arenas")
            elseif var_0000 == "theory" then
                add_dialogue("\"Just as a castle is built from the foundation up, so must a fighter. One cannot simply begin by learning to fight with weapons. Weapons are merely an extension of a person's extremities. A true fighter learns by using those extremities first.\"")
                remove_answer("theory")
                add_answer({"extremities", "fighter"})
            elseif var_0000 == "fighter" then
                add_dialogue("\"Make no mistake. Fighters are made, not born. All the natural talent in the world will avail thee naught if one does not have the heart and the will to win. Part of that will is the courage to seek out thine own limitations and strive to better them.\"")
                remove_answer("fighter")
            elseif var_0000 == "extremities" then
                add_dialogue("\"Thine arms. Thy legs. Thy fists. This is what makes 'boxing'.\"")
                remove_answer("extremities")
            elseif var_0000 == "train" then
                if var_0001 == 29 then
                    add_dialogue("\"My price for training is 45 gold. Is this all right?\"")
                    if select_option() then
                        unknown_0950H(45, 4) --- Guess: Trains boxing skill
                    else
                        add_dialogue("\"Then mayest thou find more inexpensive training elsewhere.\"")
                    end
                else
                    add_dialogue("\"Be so kind as to return during normal training hours, wouldst thou?\"")
                    remove_answer("train")
                end
            elseif var_0000 == "bye" then
                break
            end
        end
        add_dialogue("\"Good day to thee.\"")
    elseif eventid == 0 then
        unknown_092EH(36) --- Guess: Triggers a game event
    end
end