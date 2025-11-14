--- Best guess: Manages an NPC (ID -1) advertising Iolo's crossbow bolts, hiding after dialogue, likely a promotional easter egg.
function object_bolt_0723(eventid, objectref)
    local var_0000

    if eventid == 1 then
        -- call [0000] (0908H, unmapped)
        var_0000 = get_player_name()
        if not npc_id_in_party(1) then
            switch_talk_to(1)
            start_conversation()
            add_dialogue("\"" .. var_0000 .. " dost thou notice the unique Iolo trademark on these bolts? They are designed for maximum performance with genuine IOLO crossbows, available at a location near Yew.\"")
            hide_npc(1)
        end
    end
    return
end