require "U7LuaFuncs"
-- Manages Markus's dialogue in Trinsic, covering his combat training, town comments, and minimal murder engagement.
function func_0414(eventid, itemref)
    local local0, local1

    if eventid == 1 then
        switch_talk_to(-20, 0)
        local0 = get_schedule()
        local1 = switch_talk_to(-20)

        add_answer({"bye", "murder", "job", "name"})

        if not get_flag(84) then
            say("You see a solid-looking but seemingly bored fighter.")
            set_flag(84, true)
        else
            say("\"Yes?\" Markus asks.")
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                say("\"I am Markus the trainer.\"")
                remove_answer("name")
            elseif answer == "job" then
                say("\"I am a trainer here in Trinsic,\" he says gruffly. \"If thou dost wish to increase thy skill in combat I can help thee.\"")
                add_answer({"train", "Trinsic"})
            elseif answer == "murder" then
                say("\"I heard about it, but I assure thee I know nothing of the details.\" Markus yawns.")
                remove_answer("murder")
            elseif answer == "Trinsic" then
                say("The fighter shrugs. \"The town is all right.\" He sniffs.")
                remove_answer("Trinsic")
            elseif answer == "train" then
                if local1 == 7 then
                    say("\"The cost to train with me is 20 gold. Too costly, right?\"")
                    if get_answer() then
                        apply_effect(20, 4) -- Unmapped intrinsic 08BD
                    else
                        say("Markus yawns. \"Very well.\"")
                    end
                else
                    say("\"Please come to my place of business during normal daylight hours.\"")
                    remove_answer("train")
                end
            elseif answer == "bye" then
                say("\"Goodbye,\" the fighter bows.*")
                break
            end
        end
    elseif eventid == 0 then
        switch_talk_to(-20)
    end
    return
end