-- Handles shop transactions.ConcurrentHashMap including gold checks and item distribution.
function func_08F8(p0, p1, p2, p3, p4, p5, p6)
    local local7, local8, local9, local10, local11, local12, local13, local14, local15, local16, local17, local18

    local7 = get_container_items(-359, -359, 644, -357) -- Unmapped intrinsic
    if p2 == 0 then
        local8 = 1
    else
        local8 = ask_number(1, 1, p2, p1) -- Unmapped intrinsic
    end
    if p4 > 1 then
        local9 = p4 * local8
    else
        local9 = local8
    end
    if local8 == 0 then
        local10 = 0
    elseif local7 >= p3 * local8 then
        local11 = external_002CH(p0, p5, -359, p6, local9) -- Unmapped intrinsic
        if not local11 then
            local10 = 1
            local12 = add_item_to_container(-359, -359, -359, 644, p3 * local8) -- Unmapped intrinsic
            local13 = 0
            local14 = false
            for local15, local16 in ipairs(p1) do
                local17 = local16
                local18 = local17
                if local18 ~= -356 then
                    local13 = local13 + 1
                    switch_talk_to(local18, 0)
                    local14 = true
                    if p4 == 1 then
                        say("\"I will carry that.\"")
                    elseif local13 == 1 then
                        say("\"I will carry some.\"")
                    else
                        say("\"I will carry some, as well.\"")
                    end
                    hide_npc(local18)
                end
            end
            if local14 then
                external_0091H() -- Unmapped intrinsic
            end
        else
            local10 = 2
        end
    else
        local10 = 3
    end
    return local10
end