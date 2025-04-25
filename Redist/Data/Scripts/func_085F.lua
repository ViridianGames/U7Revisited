-- Manages combat training, checking gold and dexterity.
function func_085F(p0, p1)
    local local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14, local15

    local2 = external_0908H() -- Unmapped intrinsic
    local3 = external_0909H() -- Unmapped intrinsic
    local4 = "the Avatar"
    if not get_flag(497) then
        local5 = local2
    elseif not get_flag(499) then
        local5 = local4
    elseif not get_flag(498) then
        local5 = local3
    end
    local6 = external_0920H() -- Unmapped intrinsic
    local7 = get_player_name(local6) -- Unmapped intrinsic
    if local6 == 0 then
        return
    end
    local8 = 3
    local9 = external_0922H(local8, local6, p0, p1) -- Unmapped intrinsic
    if local9 == 0 then
        say("\"It seems that thou dost need a little more time to hone thy reflexes. If thou dost wish to return later, when thou hast more experience, I would be most happy to train thee.\"")
    elseif local9 == 1 then
        local10 = get_container_items(-359, -359, 644, -357) -- Unmapped intrinsic
        say("You gather your gold and count it, finding that you have " .. local10 .. " gold altogether.")
        if local10 < p0 then
            say("\"Thou hast not enough gold to pay me. I am sorry but I cannot train thee now.\"")
        end
    elseif local9 == 2 then
        say("\"Zounds! Thou art quick. Too quick, in fact, for me to be able to help thee become faster. I am sorry, " .. local5 .. ".\"")
    else
        local11 = add_item_to_container(-359, -359, -359, 644, p0) -- Unmapped intrinsic
        say("You pay " .. p0 .. " gold, and the training session begins.")
        local12 = local6 == -356 and "You" or local7
        local13 = local6 == -356 and "you" or local7
        say(local12 .. " and Chad spar for a few minutes. He teaches " .. local13 .. " several expert maneuvers that better utilize speed and agility in combat.")
        local14 = external_0910H(1, local6) -- Unmapped intrinsic
        if local14 < 30 then
            external_0917H(1, local6) -- Unmapped intrinsic
        end
        local15 = external_0910H(4, local6) -- Unmapped intrinsic
        if local15 < 30 then
            external_0915H(2, local6) -- Unmapped intrinsic
        end
    end
    return
end