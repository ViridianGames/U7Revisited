require "U7LuaFuncs"
-- Manages bed interactions, allowing the player to rest for a specified number of hours, advancing game time and updating party state.
function func_0622(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12

    if eventid ~= 1 then
        return
    end

    local0 = get_party_members()
    local1 = get_player_name()
    local3 = local1
    local4 = #local0
    if local4 > 2 then
        local5 = "we"
    else
        local5 = "I"
    end

    switch_talk_to(local1, 0)
    say("\"In how many hours shall " .. local5 .. " wake thee up, " .. local3 .. "?\"")
    local2 = ask_number(8, 1, 12, 0)

    if local2 == 0 then
        say(local3 .. " gives you an exasperated look.* \"Never mind, then.\"")
        if not external_0801(itemref) then -- Unmapped intrinsic
            external_0624(itemref) -- Unmapped intrinsic
        end
        for local6 in ipairs(local0) do
            local7 = local6
            local8 = local7
            set_schedule(local8, 31)
        end
        hide_npc(local1)
        set_flag(-356, 1)
    else
        say("\"Pleasant dreams.\"")
        hide_npc(local1)
        if get_random(1, 4) == 1 then
            external_0940(1) -- Unmapped intrinsic
        end
        set_schedule(1, 1, 12)
        local9 = local2 * 1500
        sleep(itemref, local2) -- Unmapped intrinsic
        local0 = get_item_quality(-356)
        external_093CH() -- Unmapped intrinsic
        for local10 in ipairs(local0) do
            local11 = local10
            local12 = local11
            set_schedule(local12, 11)
        end
        local12 = add_item(-356, {35, 7719})
        local12 = add_item(itemref, {33, 1571, 8021, 1590, 17493, 7715})
        advance_time(local9) -- Unmapped intrinsic
    end
    return
end