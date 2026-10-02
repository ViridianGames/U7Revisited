--- Best guess: Manages a dialogue with an ape-like creature requesting honey, offering a reward and setting a flag if honey is given, identical to func_08DF and func_08E0 except for NPC ID.
function npc_ape_honey_request_0990()
    start_conversation()
    local var_0000, var_0001

    switch_talk_to(101)
    add_dialogue("The ape-like creature slowly and cautiously walks up to you. He, or she, sniffs for a moment, and then points to the honey you are carrying.")
    while true do
        add_answer({"Go away!", "Want honey?"})
        local answer = get_answer()
        if type(answer) ~= "string" then
            answer = get_answer()
        end
        if type(answer) ~= "string" then
            break
        end
        local lower = string.lower(answer)
        if lower == "want honey?" then
            add_dialogue("\"Honey will be given by you to me?\"")
            var_0000 = ask_yes_no()
            if var_0000 then
                var_0001 = remove_party_items(true, 359, 359, 772, 1)
                add_dialogue("\"You are thanked.\"")
                utility_set_party_quest_prop8_1041(10)
                set_flag(340, true)
            else
                add_dialogue("\"`Goodbye' is said to you.\"")
                return
            end
            remove_answer({"Go away!", "Want honey?"})
        elseif lower == "go away!" then
            add_dialogue("It does.")
            return
        end
    end
    return
end