-- Manages combat training, boosting strength and combat skills.
function func_094F(p0, p1)
    local local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12

    local2 = external_0920H() -- Unmapped intrinsic
    local3 = get_player_name(local2) -- Unmapped intrinsic
    if local2 == 0 then
        return
    end
    local4 = 3
    local5 = external_0922H(local4, local2, p0, p1) -- Unmapped intrinsic
    if local5 == 0 then
        add_dialogue("After a very quick run, he turns and says, \"Thou dost not yet have the stamina. If thou so wishest, I could train thee at a later date.\"")
    elseif local5 == 1 then
        local6 = get_container_items(-359, -359, 644, -357) -- Unmapped intrinsic
        add_dialogue("You gather your gold and count it, finding that you have " .. local6 .. " gold altogether.")
        if local6 < p0 then
            add_dialogue("\"It seems thou dost not have enough gold to train at this time.\"")
        end
    elseif local5 == 2 then
        add_dialogue("After a short run, he turns and says, \"Thou art already as strong as I! I am afraid that there is nothing further I can show thee.\"")
    else
        local7 = add_item_to_container(-359, -359, -359, 644, p0) -- Unmapped intrinsic
        add_dialogue("You pay " .. p0 .. " gold, and the training session begins.")
        local8 = local2 == -356 and "you feel " or local3 .. " feels "
        local9 = local2 == -356 and "you have " or (is_player_female() and "she " or "he ") .. "has " -- Unmapped intrinsic
        add_dialogue("After sparring for half an hour, " .. local8 .. " as though " .. local9 .. "learned how to better apply force when fighting.")
        local10 = external_0910H(0, local2) -- Unmapped intrinsic
        if local10 < 30 then
            external_0914H(1, local2) -- Unmapped intrinsic
        end
        local11 = external_0910H(4, local2) -- Unmapped intrinsic
        if local11 < 30 then
            external_0917H(2, local2) -- Unmapped intrinsic
        end
    end
    return
end