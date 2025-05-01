-- Function 0947: Bread exchange
function func_0947(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14

    _SaveAnswers()
    add_dialogue(itemref, "\"Excellent! Dost thou have some loaves for me?\"")
    local0 = get_answer()
    if local0 then
        add_dialogue(itemref, "\"Very good! Let me see how many thou dost have...\"")
        local1 = check_condition(0, 25, 377, -356)
        local2 = _GetPartyMembers()
        while local2 do
            local5 = local2
            local1 = _GetContainerItems(0, -359, 377, local5)
            local2 = get_next_party_member() -- sloop
        end
        local6 = 0
        local7 = {}
        while local1 do
            local10 = local1
            if _GetItemFrame(local10) == 0 and check_item_state(11, local10) then
                if get_item_quantity(-52, local10) <= 25 then
                    local6 = local6 + 1
                    table.insert(local7, local10)
                end
            end
            local1 = get_next_item() -- sloop
        end
        local11 = math.floor(local6 / 5) * 5
        if local11 == 0 then
            add_dialogue(itemref, "\"Thou have not made enough bread to be worthy of any payment at all.\"")
            return
        end
        add_dialogue(itemref, "\"Scrumptious! " .. local6 .. " loaves! That means I owe thee " .. local11 .. " gold. Here thou art! I shall take the loaves from thee now!\"")
        local12 = give_gold(true, -359, -359, 644, local11)
        if local12 then
            while local7 do
                local10 = local7[1]
                if not call_006EH(local10) then
                    call_0925H(local10)
                else
                    set_item_flag(11, local10)
                end
                table.remove(local7, 1) -- sloop
            end
            add_dialogue(itemref, "\"Come back and work for me at any time!\"")
            return
        end
        add_dialogue(itemref, "\"If thou dost travel in a lighter fashion, thou wouldst have hands to take my gold!\"")
    else
        add_dialogue(itemref, "\"No? What hast thou been doing? -Loaf-ing around? Ha ha ha!\"")
    end
    _RestoreAnswers()
    return
end