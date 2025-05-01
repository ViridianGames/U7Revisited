-- Function 0710: Golem ritual validation
function func_0710(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14, local15, local16, local17, local18, local19, local20, local21

    if eventid == 1 then
        call_007EH()
        local0 = check_position(8, 40, 1015, itemref)
        local1 = false
        local2 = false
        while local3 do
            local5 = local3
            if _GetContainerItems(4, 243, 797, local5) then
                local1 = local5
            end
            if _GetContainerItems(4, 244, 797, local5) then
                local2 = local5
            end
            local3 = get_next_item() -- sloop
        end
        if get_flag(795) and not get_flag(796) then
            call_08FEH("@All the golems are alive now.@")
            add_dialogue(itemref, "*")
            return
        end
        local6 = false
        local7 = call_0814H()
        if not local7 then
            call_08FEH({"@The golem must be centered", "in the pentacle of stones.@"})
        else
            local0 = check_position(0, 10, 331, {2487, 1736, 0})
            local8 = 0
            while local9 do
                local11 = local9
                local12 = _GetItemFrame(local11)
                if local12 >= 0 and local12 <= 10 and check_position(176, 2, 912, local11) then
                    local8 = local8 + 1
                end
                local9 = get_next_item() -- sloop
            end
            if local8 >= 5 then
                local6 = true
            end
            if not local6 then
                if local8 > 0 and local8 < 5 then
                    local13 = " rock is"
                    if local8 > 1 then
                        local13 = " rocks are"
                    end
                    local14 = "@Only " .. local8 .. local13 .. " covered.@"
                    call_08FEH(local14)
                else
                    call_08FEH("@Blood must cover the rocks.@")
                end
            end
        end
        call_0086H(itemref, 14)
        call_0055H(itemref)
        add_dialogue(itemref, "     Vas Flam Uus~~")
        add_dialogue(itemref, "This scroll will permit thee to perform the ritual necessary to either create, or reconstruct, stone creatures and instill within them the power of thought. First, gather the materials discussed in the previous chapters. After thou hast performed said task, thou shouldst refer back to this scroll and begin...")
        if local6 and local7 then
            local15 = call_0001H(7938, 1812, {17493, 7715}, -356)
        end
    elseif eventid == 2 then
        set_flag(796, true)
        local16 = get_item_position(itemref)
        call_08E6H(itemref)
        local17 = call_0024H(414)
        _SetItemFrame(5, local17)
        local18 = call_0026H(local16)
        local19 = call_0024H(797)
        _SetItemQuality(244, local19)
        _SetItemFrame(4, local19)
        local20 = call_0036H(local17)
        local21 = call_0024H(203)
        _SetItemFrame(10, local21)
        local16[1] = local16[1] + 4
        local16[2] = local16[2] - 1
        local16[3] = local16[3] + 2
        local22 = call_0026H(local16)
        add_dialogue(itemref, "@He gave up his heart... so that Adjhar may live!* Well, not to be morbid, but I suppose the incantation should work now.@")
        set_item_glow(-356)
    end
end