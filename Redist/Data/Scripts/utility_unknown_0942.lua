--- Best guess: Handles Horance's response to the player's decision regarding the Well of Souls quest, setting flags based on acceptance or refusal.
function utility_unknown_0942(var_0000)
    start_conversation()
    local var_0001

    var_0001 = ask_yes_no()
    if not var_0001 then
        add_dialogue("\"" .. var_0000 .. ", I am sure that some brave soul will eventually come this way. After all, most of the spirits can wait for all eternity if need be, even if they are in excruciating pain.\" He looks a little disappointed as he says his goodbye. However, gratitude is still apparent in his eyes.")
        set_flag(465, true)
    else
        add_dialogue("Horance looks as if he expected your response. \"I knew that one so virtuous as thou wouldst never turn aside while others suffer. Thy generosity seems to have no bounds.\"")
        set_flag(428, true)
        set_flag(465, false)
    end
    return
end