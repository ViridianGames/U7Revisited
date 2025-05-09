--- Best guess: Handles evidence discussion in the murder investigation, setting flags for progress.
function func_0885(eventid, itemref)
    local var_0000, var_0001, var_0002

    start_conversation()
    if get_dialogue_choice() then --- Guess: Gets dialogue choice
        add_dialogue("@What didst thou find?@")
        clear_answers() --- Guess: Clears conversation answers
        var_0000 = {"a body", "a bucket", "nothing"}
        if not get_flag(60) then
            table.insert(var_0000, "a key")
        end
        var_0001 = show_dialogue_options(var_0000) --- Guess: Shows dialogue options
        if var_0001 == "a key" then
            add_dialogue("@Hmmm, a key. Perhaps if thou dost ask Christopher's son about it...@")
            set_flag(72, true)
        elseif var_0001 == "a body" then
            add_dialogue("@I know that! What -else- didst thou find?...@")
            set_flag(90, true)
            return
        elseif var_0001 == "a bucket" then
            add_dialogue("@Yes, obviously it is filled with poor Christopher's own blood...@")
            set_flag(90, true)
            return
        elseif var_0001 == "nothing" then
            add_dialogue("@Thou shouldst look again, 'Avatar'!@")
            set_flag(90, true)
            return
        end
    else
        add_dialogue("@Then I suggest that thou lookest inside and talkest to me again.@")
        set_flag(90, true)
        return
    end
end