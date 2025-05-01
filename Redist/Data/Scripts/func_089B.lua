-- Manages combat training, checking gold and stats.
function func_089B(p0, p1)
    local local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12

    local2 = external_0920H() -- Unmapped intrinsic
    local3 = get_player_name(local2) -- Unmapped intrinsic
    local4 = local2 == -356 and "your" or "their"
    if local2 == 0 then
        return
    end
    local5 = 3
    local6 = external_0922H(local5, local2, p0, p1) -- Unmapped intrinsic
    if local6 == 0 then
        add_dialogue("\"To be without the practical experience required to train at this time.\"")
    elseif local6 == 1 then
        local7 = get_container_items(-359, -359, 644, -357) -- Unmapped intrinsic
        add_dialogue("You gather your gold and count it, finding that you have " .. local7 .. " gold altogether.")
        if local7 < p0 then
            add_dialogue("\"To need more gold than you have. To need 50 gold.\"")
        end
    elseif local6 == 2 then
        add_dialogue("After examining " .. local4 .. " muscles, he says, \"To be stronger than I. To need no further training in combat.\"")
    else
        local8 = add_item_to_container(-359, -359, -359, 644, p0) -- Unmapped intrinsic
        add_dialogue("You pay " .. p0 .. " gold, and the training session begins.")
        local9 = local2 == -356 and "you begin" or local3 .. " begins"
        add_dialogue("The gargoyle begins with some intense weight-lifting which eventually leads to target practice with throwing axes. At the end, " .. local9 .. " to notice a change in physical prowess and hand-eye coordination.")
        local10 = external_0910H(0, local2) -- Unmapped intrinsic
        if local10 < 30 then
            external_0914H(1, local2) -- Unmapped intrinsic
        end
        local11 = external_0910H(1, local2) -- Unmapped intrinsic
        if local11 < 30 then
            external_0915H(1, local2) -- Unmapped intrinsic
        end
        local12 = external_0910H(4, local2) -- Unmapped intrinsic
        if local12 < 30 then
            external_0917H(1, local2) -- Unmapped intrinsic
        end
    end
    return
end