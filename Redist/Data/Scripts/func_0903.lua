-- Function 0903: Pig NPC dialogue
function func_0903(eventid, itemref)
    local local0, local1, local2, local3

    if npc_in_party(itemref) then
        if itemref == -356 then
            local2 = is_player_female()
        else
            local2 = 0
        end
        switch_talk_to(itemref, local2)
        if not check_item_state(25, itemref) then
            add_dialogue(itemref, "\"Oink\"")
        else
            while local0 do
                local1 = local0
                add_dialogue(itemref, local1 .. "")
                local0 = get_next_string() -- sloop
            end
        end
        _HideNPC(itemref)
    end
    return
end