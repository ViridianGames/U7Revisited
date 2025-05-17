--- Best guess: Handles dialogue with Markus, the Trinsic trainer, discussing his combat training services and the local murder, with training options during business hours.
function func_0414(eventid, objectref)
    local var_0000, var_0001

    start_conversation()
    if eventid == 1 then
        switch_talk_to(20, 0)
        var_0000 = get_schedule() --- Guess: Checks game state or timer
        var_0001 = unknown_001CH(20) --- Guess: Gets object state
        add_answer({"bye", "murder", "job", "name"})
        if not get_flag(84) then
            add_dialogue("You see a solid-looking but seemingly bored fighter.")
            set_flag(84, true)
        else
            add_dialogue("\"Yes?\" Markus asks.")
        end
        while true do
            var_0000 = get_answer()
            if var_0000 == "name" then
                add_dialogue("\"I am Markus the trainer.\"")
                remove_answer("name")
            elseif var_0000 == "job" then
                add_dialogue("\"I am a trainer here in Trinsic,\" he says gruffly. \"If thou dost wish to increase thy skill in combat I can help thee.\"")
                add_answer({"train", "Trinsic"})
            elseif var_0000 == "murder" then
                add_dialogue("\"I heard about it, but I assure thee I know nothing of the details.\" Markus yawns.")
                remove_answer("murder")
            elseif var_0000 == "Trinsic" then
                add_dialogue("The fighter shrugs. \"The town is all right.\" He sniffs.")
                remove_answer("Trinsic")
            elseif var_0000 == "train" then
                if var_0001 == 7 then
                    add_dialogue("\"The cost to train with me is 20 gold. Too costly, right?\"")
                    if not select_option() then
                        unknown_08BDH(20, 4) --- Guess: Trains combat skill
                    else
                        add_dialogue("Markus yawns. \"Very well.\"")
                    end
                else
                    add_dialogue("\"Please come to my place of business during normal daylight hours.\"")
                    remove_answer("train")
                end
            elseif var_0000 == "bye" then
                break
            end
        end
        add_dialogue("\"Goodbye,\" the fighter bows.")
    elseif eventid == 0 then
        unknown_092EH(20) --- Guess: Triggers a game event
    end
end