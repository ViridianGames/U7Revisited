require "U7LuaFuncs"
-- Manages password-protected access, requiring "Blackbird" to pass, with multiple NPC interactions and flag checks.
function func_0631(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7

    if eventid ~= 7 then
        if eventid == 2 then
            external_083FH(itemref, true) -- Unmapped intrinsic
        end
        return
    end

    local0 = get_item_quality(itemref)
    local1 = add_item(itemref, 0, 15, 870)
    local2 = add_item(itemref, 0, 15, 515)
    for local3 in ipairs(local2) do
        local4 = local3
        local5 = local4
        if get_item_quality(local5) == local0 then
            table.insert(local1, local5)
        end
    end
    if external_080EH(local1) then -- Unmapped intrinsic
        local6 = add_item(itemref, {4, -1, 17419, 8014, 1, 7750})
        local6 = add_item(-356, {2, -2, 17419, 17505, 17516, 7937, 6, 7769})
    end
    if not get_flag(61) then
        if switch_talk_to(-14) and not get_flag(87) then
            local7 = add_item(-14, 1, "@What's the password?@", {17490, 7715})
            local6 = add_item(-359, 5, "@Blackbird@", {17490, 7715}, get_answer())
            local6 = add_item(-14, 11, "@Pass.@", {17490, 7715})
        end
        local6 = add_item(itemref, 10, 1585, {17493, 7715})
    end
    if switch_talk_to(-27) and not get_flag(87) then
        local7 = add_item(-27, 1, "@What's the password?@", {17490, 7715})
        local6 = add_item(-359, 5, "@Blackbird@", {17490, 7715}, get_answer())
        local6 = add_item(-27, 11, "@Pass.@", {17490, 7715})
        local6 = add_item(itemref, 10, 1585, {17493, 7715})
    end
    if external_0326H(-1, 806, -356) and not get_flag(87) then -- Unmapped intrinsic
        local6 = add_item(-356, 20, 806, itemref)
        if switch_talk_to(local6) then
            local7 = add_item(local6, 1, "@What's the password?@", {17490, 7715})
            local6 = add_item(-359, 5, "@Blackbird@", {17490, 7715}, get_answer())
            local6 = add_item(local6, 11, "@Pass.@", {17490, 7715})
            local6 = add_item(itemref, 10, 1585, {17493, 7715})
        end
    end
    external_083FH(itemref, true) -- Unmapped intrinsic
    return
end