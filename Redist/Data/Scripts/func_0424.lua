-- Manages Zella's dialogue in Britain, covering boxing training, combat philosophy, and training services.
function func_0424(eventid, itemref)
    local local0, local1

    if eventid == 1 then
        switch_talk_to(-36, 0)
        local0 = switch_talk_to(-36)
        local1 = false

        add_answer({"bye", "job", "name"})

        if not get_flag(165) then
            say("You see a lean, young fighter with a rather dashing flair.")
            set_flag(165, true)
        else
            say("\"Hello again!\" Zella says.")
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                say("\"My name is Zella.\"")
                remove_answer("name")
            elseif answer == "job" then
                say("\"I am a trainer. I specialize in hand-to-hand combat. After all, a fighter never knows when he might encounter an adversary and suddenly realize he is unarmed. I call it 'boxing'. Boxing is not only a method of fighting -- it is an art.\"")
                add_answer({"train", "combat"})
            elseif answer == "combat" then
                say("\"The field of battle contains many arenas. Almost any situation could arise. Every fighter should be knowledgeable and adept at many forms of combat. I have mine own theory of fighting.\"")
                remove_answer("combat")
                add_answer({"theory", "arenas"})
            elseif answer == "arenas" then
                say("\"All the various arenas of combat, all the various styles one may learn in fighting with various weapons, are not fighting in its purest form. To truly be a great fighter one must go to the source of all fighting knowledge.\"")
                remove_answer("arenas")
            elseif answer == "theory" then
                say("\"Just as a castle is built from the foundation up, so must a fighter. One cannot simply begin by learning to fight with weapons. Weapons are merely an extension of a person's extremities. A true fighter learns by using those extremities first.\"")
                remove_answer("theory")
                add_answer({"extremities", "fighter"})
            elseif answer == "fighter" then
                say("\"Make no mistake. Fighters are made, not born. All the natural talent in the world will avail thee naught if one does not have the heart and the will to win. Part of that will is the courage to seek out thine own limitations and strive to better them.\"")
                remove_answer("fighter")
            elseif answer == "extremities" then
                say("\"Thine arms. Thy legs. Thy fists. This is what makes 'boxing'.\"")
                remove_answer("extremities")
            elseif answer == "train" then
                if local0 == 29 then
                    say("\"My price for training is 45 gold. Is this all right?\"")
                    if get_answer() then
                        apply_effect(45, {4, 1}) -- Unmapped intrinsic 0950
                    else
                        say("\"Then mayest thou find more inexpensive training elsewhere.\"")
                    end
                else
                    say("\"Be so kind as to return during normal training hours, wouldst thou?\"")
                    remove_answer("train")
                end
            elseif answer == "bye" then
                say("\"Good day to thee.\"*")
                break
            end
        end
    elseif eventid == 0 then
        switch_talk_to(-36)
    end
    return
end