--- Best guess: Manages an NPC (likely a beggar or thief, ID 44) requesting a gold donation, hiding after receiving it or if conditions aren't met.
function object_puppetshow_0503(eventid, objectref)
    local var_0000

    if eventid == 1 then
        -- callis 0079, 1 (unmapped)
        if not in_usecode(objectref) then
            return
        end
        if not npc_id_in_party(44) then
            switch_talk_to(44)
            start_conversation()
            add_dialogue("\"Now is the time for the young and the old to dig in their pockets and give up the gold. * Dost thou wish to donate a gold piece?\"")
            -- call [0000] (090AH, unmapped)
            if ask_yes_no() then
                var_0000 = give_object_to_party(359, 359, 644, 1, 357)
                var_0000 = execute_usecode_array({0, 8006, 31, -1, 17419, 8014, 0, 17478, 7715}, objectref)
                var_0000 = execute_usecode_array({85, 8024, 2, 7975, 83, 8024, 3, 7975, 83, 8024, 85, 8024, 1, 7975, 84, 8024, 83, 8024, 85, 8024, 11, 17447, 7715}, objectref)
            end
            hide_npc(44)
        end
    end
    return
end