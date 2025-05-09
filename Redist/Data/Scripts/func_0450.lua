--- Best guess: Handles dialogue with De Maria, a bard in Cove, who sings tales about the townsfolk, particularly Nastassia and his love Zinaida, offering to perform a song or tale about Cove’s people.
function func_0450(eventid, itemref)
    local var_0000, var_0001, var_0002

    start_conversation()
    if eventid == 1 then
        switch_talk_to(80, 0)
        add_answer({"bye", "job", "name"})
        if not get_flag(227) then
            add_answer("Nastassia")
        end
        if not get_flag(228) and not get_flag(242) then
            add_answer("Zinaida")
        end
        if not get_flag(237) then
            add_dialogue("This flamboyant bard exudes a festive aura.")
            add_dialogue("\"I have sung about thee in many a song! And here thou art in the flesh! I recognized thee immediately.\" The man bows. \"Welcome, Avatar!\"")
            set_flag(237, true)
        else
            add_dialogue("\"Greetings again, Avatar!\" De Maria bows.")
        end
        while true do
            var_0000 = get_answer()
            if var_0000 == "name" then
                add_dialogue("\"I am De Maria, the Bard.\"")
                remove_answer("name")
                if not get_flag(228) then
                    add_answer("Zinaida")
                end
                set_flag(242, true)
            elseif var_0000 == "job" then
                add_dialogue("\"I spin tales and sing songs!\"")
                if not get_flag(227) then
                    add_dialogue("\"I also know a good deal about the folks in Cove.\"")
                    add_answer({"folks", "song", "tale"})
                end
            elseif var_0000 == "folks" or var_0000 == "song" or var_0000 == "tale" then
                add_dialogue("\"What if I combine all three? Shall I sing a song which is a tale about the people of Cove?\"")
                var_0001 = select_option()
                if var_0001 then
                    add_dialogue("\"Very well, then!\"")
                    save_answers()
                    unknown_0877H() --- Guess: Performs a song or tale
                    restore_answers()
                else
                    add_dialogue("\"'Tis thy choice... and thy mistake!\"")
                end
                remove_answer({"folks", "song", "tale"})
            elseif var_0000 == "Nastassia" then
                add_dialogue("\"Ah, dear Nastassia. Wouldst thou like to hear her tale?\"")
                var_0001 = select_option()
                if var_0001 then
                    add_dialogue("\"Very well, then!\"")
                    save_answers()
                    unknown_0877H() --- Guess: Performs a song or tale
                    restore_answers()
                    remove_answer("Nastassia")
                else
                    add_dialogue("\"Oh. I thought thou wert curious. Never mind then.\"")
                    remove_answer("Nastassia")
                end
            elseif var_0000 == "Zinaida" then
                add_dialogue("\"My love! My flower! Mine angel! The provider of the sweetest nectar my mouth has ever known! She is the light of my day! The notes of my songs! The flesh of my...\"")
                var_0002 = unknown_08F7H(79) --- Guess: Checks player status
                if var_0002 then
                    switch_talk_to(79, 0)
                    add_dialogue("\"Enough, my love. I think the Avatar dost know thy meaning!\"")
                    hide_npc(79)
                    switch_talk_to(80, 0)
                end
                add_dialogue("De Maria stops his reverie, sighs, and smiles at you. \"Thou dost apprehend my meaning...\"")
                remove_answer("Zinaida")
            elseif var_0000 == "bye" then
                break
            end
        end
        add_dialogue("\"Do take care of thyself!\"")
    elseif eventid == 0 then
        unknown_092EH(80) --- Guess: Triggers a game event
    end
end