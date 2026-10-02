--- Best guess: Manages a dialogue with Trent and Rowena after their reunion, where they refuse a sacrifice and focus on their love, with an option to end the conversation.
function npc_trent_rowena_no_sacrifice_0982()
    start_conversation()
    local var_0000, var_0001

    var_0000 = get_lord_or_lady()
    var_0001 = npc_id_in_party(142)
    if not var_0001 then
        add_dialogue("\"Where, oh where has my dear husband gone. I cannot stand to be away from him!\"")
        return
    end
    add_dialogue("As far as you can tell, the couple haven't released their embrace since they were first reunited, and they show no sign of doing so at any time in the near future.")
    while true do
        add_answer("bye")
        add_answer("sacrifice")
        local answer = get_answer()
        if type(answer) ~= "string" then
            answer = get_answer()
        end
        if type(answer) ~= "string" then
            break
        end
        local lower = string.lower(answer)
        if lower == "sacrifice" then
            remove_answer("sacrifice")
            if not get_flag(413) then
                switch_talk_to(142, 1)
                add_dialogue("\"No, " .. var_0000 .. ". She is my life. If thou takest her, thou takest mine heart.\" Trent holds on tightly to his wife.")
                set_flag(413, true)
                hide_npc(142)
                switch_talk_to(144, 1)
            else
                add_dialogue("\"I cannot leave my lord like this. Surely thou canst understand, " .. var_0000 .. ".\"")
            end
        elseif lower == "bye" then
            add_dialogue("The couple continue staring into one another's eyes as if to make up for all of the years they lost.")
            return
        end
    end
    return
end