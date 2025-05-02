-- Implements an anti-cheat mechanism, detecting cheating, delivering a guilty verdict, and applying severe penalties (e.g., death).
function func_063E(eventid, itemref)
    local local0, local1, local2, local3, local4, local5

    if eventid == 3 then
        local0 = external_0025H(-23) -- Unmapped intrinsic
        if not local0 then
            local1 = get_item_data(-356)
            local0 = set_item_data({local1[1], local1[2] - 4, local1[3] - 2})
            set_object_frame(-23, 16)
        end
        local0 = add_item(-356, 1, 1598, {17493, 7715})
        local0 = set_npc_property(-356, 2, 0)
        local0 = set_npc_property(-356, 1, 0)
        local0 = set_npc_property(-356, 15, 0)
        local0 = set_npc_property(-356, 3, 15)
        local0 = set_npc_property(-356, 4, 0)
        local0 = set_npc_property(-356, 5, 0)
        local0 = set_npc_property(-356, 6, 0)
        local0 = set_npc_property(-356, 7, 0)
        local0 = set_npc_property(-356, 8, 0)
    elseif eventid == 2 then
        switch_talk_to(23, 0)
        add_dialogue("Busted, you thieving scoundrel bastard! Perhaps the only thing more ridiculous than your pathetic attempt to destroy the black gate without paying proper dues is your inevitably embarrassing explanation to the friend to whom you are, no doubt, showing this!")
        add_dialogue("For the atrocious crime of cheating against the virtues of Britannia, I find you guilty.*")
        apply_effect(15) -- Unmapped intrinsic
        add_dialogue("Judgement rendered.* Sentence selected:* Death.*")
        local0 = add_item(-356, 21, {14422})
        local2 = get_party_members()
        for local3 in ipairs(local2) do
            local4 = local3
            local5 = local4
            set_flag(local5, 7, true)
        end
        external_0045H(2) -- Unmapped intrinsic
        external_005BH() -- Unmapped intrinsic
        set_flag(30, true)
        set_item_quality(-23, 2)
        external_004BH(-23, 0) -- Unmapped intrinsic
        set_schedule(23, 0)
        set_flag(itemref, 25, true)
    end
    return
end