--- Best guess: Manages Horance’s post-quest dialogue in Skara Brae, prompting the player to continue their main quest and discussing the town’s future.
function func_08B2()
    start_conversation()
    local var_0000

    switch_talk_to(141, 1)
    var_0000 = get_player_name()
    add_dialogue("Horance looks at you curiously, \"Thy task is done here in Skara Brae. Thou hast my respect and lifelong gratitude.\"")
    if get_flag(380) then
        add_dialogue("But...,\" he hesitates here as if unsure how to proceed, \"...shouldst thou not return to the quest which brought thee here?\"")
        add_answer("quest")
    end
    add_answer({"bye", "Skara Brae"})
    while true do
        local response = unknown_XXXXH() -- Placeholder for answer selection
        if response == "quest" then
            if not get_flag(432) then
                add_dialogue("\"Why, yes. I sense that the spirit of Caine has not left the island yet. Is he not waiting for thy return?\"")
            else
                add_dialogue("\"Thou wert brought to Britannia for a reason, I surmise. If thou dost not know what it is, shouldst thou not seek it out?\"")
            end
            remove_answer("quest")
        elseif response == "Skara Brae" then
            add_dialogue("\"I intend to restore this town and furthermore, make it a place of beauty and renown. I enjoin thee to return in future times to see if my boast doth come to pass.\"")
            remove_answer("Skara Brae")
        elseif response == "bye" then
            add_dialogue("\"Goodbye, " .. var_0000 .. ". I hope that thou farest well in thy quest.\" He turns away.")
            return
        end
    end
    return
end