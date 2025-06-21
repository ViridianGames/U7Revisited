--- Best guess: Handles dialogue with Penni, a spear-wielding trainer in Yew, discussing her combat training, love for hunting, friendship with Bradman, and concern for her husband Addom’s safety.
function func_0473(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007

    start_conversation()
    if eventid == 1 then
        switch_talk_to(115, 0)
        var_0000 = get_player_name()
        var_0001 = get_lord_or_lady()
        var_0002 = false
        var_0003 = false
        var_0004 = unknown_001CH(115) --- Guess: Gets object state
        add_answer({"bye", "job", "name"})
        if not get_flag(333) then
            add_dialogue("The woman you see in front of you has a concerned expression on her face, as if her thoughts were far away.")
            set_flag(333, true)
        else
            add_dialogue("\"Hail, " .. var_0000 .. ". Might I assist thee?\" asks Penni.")
        end
        if not get_flag(478) then
            add_answer("Addom")
        end
        while true do
            var_0005 = get_answer()
            if var_0005 == "name" then
                add_dialogue("\"My name is Penni, " .. var_0001 .. ".\"")
                remove_answer("name")
                if not get_flag(478) and not var_0003 then
                    add_answer("Addom")
                end
            elseif var_0005 == "job" then
                add_dialogue("\"I have no occupation, " .. var_0001 .. ". At least not one I would call work. I do, however, teach skills in close quarter combat.\"")
                add_dialogue("She thinks for a moment. \"I suppose a better way to answer thy question would have been to say `Yes, I do have a job.' I'm a trainer. But,\" she smiles, \"I enjoy it too much to call it work.\"")
                add_answer({"train", "enjoy"})
                if not get_flag(322) then
                    if not var_0002 then
                        add_answer("Bradman")
                        var_0002 = true
                    end
                end
            elseif var_0005 == "enjoy" then
                add_dialogue("\"I have loved close-quarter fighting since I was old enough to grasp my first spear. That's why I moved to Yew.\"")
                remove_answer("enjoy")
                add_answer({"Yew", "spear"})
            elseif var_0005 == "spear" then
                add_dialogue("\"It is my choice in arms. The spear combines the best of both range and power. It is the perfect hunting weapon.\"")
                remove_answer("spear")
            elseif var_0005 == "Yew" then
                add_dialogue("\"I moved here to hunt, of course. The forest is full of game. I would not think of living anywhere else!\"")
                remove_answer("Yew")
            elseif var_0005 == "train" then
                if var_0004 == 7 then
                    add_dialogue("\"Art thou interested in training? My price is 35 gold for each training session.\"")
                    if select_option() then
                        unknown_08C8H(35, {4, 0}) --- Guess: Trains player
                    else
                        add_dialogue("\"Perhaps next time.\"")
                    end
                else
                    add_dialogue("\"I am sorry, " .. var_0001 .. ", but I am not training at this moment. Perhaps if thou wert to return between 9 in the morning and 6 in the evening, I will be able to help thee.\"")
                end
            elseif var_0005 == "Bradman" then
                add_dialogue("\"Yes,\" she nods her head, grinning, \"I know Bradman. We go hunting together. Of course, he rarely catches anything with that toothpick shooter of his.\"")
                var_0005 = npc_id_in_party(1) --- Guess: Checks player status
                if var_0005 then
                    switch_talk_to(1, 0)
                    add_dialogue("\"I resent that, my friend. Bows and crossbows can be wielded with deadly effect.\"")
                    switch_talk_to(115, 0)
                    add_dialogue("She smiles, nodding to Iolo. \"Perhaps thou art correct, friend archer, but I prefer more physical challenges.\"")
                    hide_npc(1)
                else
                    add_dialogue("\"Although I consider him a true friend and an honorable companion, I wonder about his physical prowess.\"")
                end
                remove_answer("Bradman")
            elseif var_0005 == "Addom" then
                add_dialogue("\"Addom is mine husband. But how did...?\" She appears confused, but suddenly directs her gaze at you. \"Hast thou seen him?\"")
                var_0005 = select_option()
                if var_0005 then
                    add_dialogue("\"Is he in good health?\"")
                    var_0006 = select_option()
                    if var_0006 then
                        add_dialogue("\"Thank goodness!\" she sighs in relief.")
                    else
                        add_dialogue("\"I knew he should not have left this time! I hate it when he leaves!\" She chokes back her tears.")
                        abort()
                    end
                else
                    add_dialogue("\"I do hate it so when he travels so far away for such a long time. I can only hope he returns to mine arms quickly!\" She peers off in the distance, as if searching for Addom.")
                end
                remove_answer("Addom")
                var_0003 = true
            elseif var_0005 == "bye" then
                break
            end
        end
        add_dialogue("\"Good journeying, " .. var_0001 .. ".\"")
    elseif eventid == 0 then
        unknown_092EH(115) --- Guess: Triggers a game event
    end
end