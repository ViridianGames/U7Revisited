--- Best guess: Manages a dialogue with Trent and Rowena after their reunion in Skara Brae, handling refusal of sacrifice and Rowena's absence, with topic selection.
function npc_trent_rowena_reunion_1008()
    start_conversation()
    local var_0000, var_0001

    var_0000 = get_lord_or_lady()
    var_0001 = npc_id_in_party(144)
    if not var_0001 then
        add_dialogue("\"Why, I must again find my darling Rowena! Where could she have gone to?\"")
        return
    end
    add_dialogue("The couple haven't released their embrace since they were first reunited as far as you can tell, and they show no sign of doing so any time in the near future.")
    add_answer("bye")
    while true do
        local answer = get_answer()
        if type(answer) ~= "string" then
            answer = get_answer()
        end
        if type(answer) ~= "string" then
            break
        end
        local lower = string.lower(answer)
        if lower == "sacrifice" then
            if not get_flag(414) then
                switch_talk_to(144, 1)
                add_dialogue("\"No, " .. var_0000 .. ". Wouldst thou take my beloved from me so shortly after our reunion? Another will have to perform this terrible task.\" Rowena holds on tightly to her husband.")
                set_flag(414, true)
                hide_npc(144)
                switch_talk_to(142, 1)
            else
                add_dialogue("\"I cannot leave my lady like this. Surely thou dost understand, " .. var_0000 .. ".\"")
            end
            remove_answer("sacrifice")
        elseif lower == "bye" then
            add_dialogue("The couple continue staring into one another's eyes as if to make up for all of the years they lost.")
            return
        end
    end
    return
end