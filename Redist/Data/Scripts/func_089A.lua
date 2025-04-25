-- Manages intelligence training, checking gold and stats.
function func_089A(p0, p1)
    local local2, local3, local4, local5, local6, local7, local8, local9, local10

    local2 = external_0920H() -- Unmapped intrinsic
    local3 = get_player_name(local2) -- Unmapped intrinsic
    if local2 == 0 then
        return
    end
    local4 = 3
    local5 = external_0922H(local4, local2, p0, p1) -- Unmapped intrinsic
    if local5 == 0 then
        say("\"To see you need more experience to train at this time.\"")
    elseif local5 == 1 then
        local6 = get_container_items(-359, -359, 644, -357) -- Unmapped intrinsic
        say("You gather your gold and count it, finding that you have " .. local6 .. " gold altogether.")
        if local6 < p0 then
            say("\"To have not enough gold to train here.\"")
        end
    elseif local5 == 2 then
        say("After asking a few questions, he exclaims, \"To be already as well-educated as I. To apologize for my inability to increase your knowledge, but there is nothing I can do.\"")
    else
        local7 = add_item_to_container(-359, -359, -359, 644, p0) -- Unmapped intrinsic
        say("You pay " .. p0 .. " gold, and the training session begins.")
        local8 = local2 == -356 and "you begin" or local3 .. " begins"
        say("The gargoyle begins with some intense memorization exercises which eventually lead to concepts of spell theory. At the end, " .. local8 .. " to notice a change in mental capabilities and thought reaction speed.")
        local9 = external_0910H(2, local2) -- Unmapped intrinsic
        if local9 < 30 then
            external_0916H(2, local2) -- Unmapped intrinsic
        end
        local10 = external_0910H(6, local2) -- Unmapped intrinsic
        if local10 < 30 then
            external_0918H(1, local2) -- Unmapped intrinsic
        end
    end
    return
end