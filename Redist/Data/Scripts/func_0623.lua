-- Wakes the player after resting in a bed, delivering a wake-up message and updating party state, with special handling for bedrolls.
function func_0623(eventid, itemref)
    local local0, local1, local2, local3, local4, local5

    if eventid ~= 2 then
        return
    end

    local0 = get_player_name()
    if local0 ~= -356 then
        switch_talk_to(local0, 0)
        local1 = local0
        say("\"Arise, " .. local1 .. ". Time to continue the quest.\"")
        hide_npc(local0)
    end

    local2 = get_party_members()
    for local3 in ipairs(local2) do
        local4 = local3
        local5 = local4
        set_schedule(local5, 31)
    end

    set_flag(-356, 1, true)
    set_flag(-356, 1, false)

    if get_item_type(itemref) == 1011 and get_item_frame(itemref) == 17 then
        external_0624(itemref) -- Unmapped intrinsic
    end

    return
end