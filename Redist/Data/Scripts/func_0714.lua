require "U7LuaFuncs"
-- Function 0714: Golem revival ritual
function func_0714(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14, local15, local16, local17, local18, local19

    local0 = check_position(8, 40, 1015, itemref)
    local1 = false
    local2 = false
    while local3 do
        local5 = local3
        if _GetContainerItems(4, 243, 797, local5) then
            local1 = local5
            local6 = local1
        end
        if _GetContainerItems(4, 244, 797, local5) then
            local2 = local5
            local6 = local2
        end
        local3 = get_next_item() -- sloop
    end
    if eventid == 2 then
        local7 = false
        local8 = call_0814H()
        while local9 do
            local11 = local9
            local7 = _GetContainerItems(10, -359, 203, local11)
            if local7 then
                break
            end
            local9 = get_next_item() -- sloop
        end
        if not local7 then
            local12 = get_item_position(-356)
            local12 = table.insert(local12, table.insert(local12, 10))
            local0 = check_position(0, 30, 203, local12)
            if not call_0931H(local0, 10, -359, 203, 1, -357) then
                say(itemref, "@The heart must be placed in the body.@")
                return
            end
            say(itemref, "@According to the tome, a `heart' will be necessary to perform this ritual.@")
            if not get_flag(796) then
                _SwitchTalkTo(0, -289)
                say(itemref, '"I will give him mine!"')
                _HideNPC(-289)
                local13 = call_0001H(500, {7719}, -356)
                local0 = check_position(0, 80, 414, itemref)
                while local14 do
                    local16 = local14
                    if _GetContainerItems(4, 243, 797, local16) then
                        _SwitchTalkTo(0, -289)
                        say(itemref, "You watch in stunned horror as Bollux pierces his chest open with his fingers.")
                        _HideNPC(-289)
                        local17 = call_0087H(local16, local2)
                        _SwitchTalkTo(0, -289)
                        say(itemref, "He pulls forth a heart-shape stone and, with a final flurry of action, drops the stone upon Adjhar's chest as he falls dead to the ground.")
                        _HideNPC(-289)
                        local18 = call_0001H(1808, {8021, 1, 17447, 8046, 2, 17447, 8047, 2, 17447, 8045, 2, 8487, local17, 7769}, local2)
                    end
                    local14 = get_next_item() -- sloop
                end
            end
        else
            call_0904H({"@Vas Flam Uus...@", "@Kal Por...@", "@In Mani...@", "@In Grav...@", "@In Ylem...@"}, -356)
            local19 = call_092DH(local7)
            local18 = call_0001H({8033, 1, 17447, 8044, 1, 17447, 8039, 2, 17447, 8047, 1, -24, 7947, 2, 17447, 8033, 3, 17447, 8047, 3, 17447, 8033, 3, 17447, 8045, 2, 17447, 8033, 3, 17447, 8048, 3, 17447, 8033, 3, 17447, 8045, 1, 8487, local19, 7769}, -356)
            local18 = call_0002H(76, 1580, {7938}, local7)
        end
    end
end