--- Best guess: Manages a dialogue with an ape-like creature requesting honey, offering a reward and setting a flag if honey is given, identical to func_08DF and func_08E0 except for NPC ID.
function func_08DE()
    start_conversation()
    local var_0000, var_0001

    switch_talk_to(101, 0)
    add_dialogue("The ape-like creature slowly and cautiously walks up to you. He, or she, sniffs for a moment, and then points to the honey you are carrying.")
    while true do
        add_answer({"Go away!", "Want honey?"})
        if not unknown_XXXXH() then
            if string.lower(unknown_XXXXH()) == "want honey?" then
                add_dialogue("\"Honey will be given by you to me?\"")
                var_0000 = ask_yes_no()
                if var_0000 then
                    var_0001 = unknown_002BH(true, 359, 359, 772, 1)
                    add_dialogue("\"You are thanked.\"")
                    unknown_0911H(10)
                    set_flag(340, true)
                else
                    add_dialogue("\"`Goodbye' is said to you.\"")
                    return
                end
                remove_answer({"Go away!", "Want honey?"})
            end
            if string.lower(unknown_XXXXH()) == "go away!" then
                add_dialogue("It does.")
                return
            end
        end
    end
    return
end