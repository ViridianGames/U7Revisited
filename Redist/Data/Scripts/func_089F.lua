-- Manages combat training with Jakher, checking gold and stats.
function func_089F(p0, p1)
    local local2, local3, local4, local5, local6, local7, local8, local9, local10

    local2 = external_0920H() -- Unmapped intrinsic
    local3 = external_090FH(local2) -- Unmapped intrinsic
    local4 = external_0908H() -- Unmapped intrinsic
    if local3 == local4 then
        local3 = "you"
    end
    if local2 == 0 then
        return
    end
    local5 = 2
    local6 = external_0922H(local5, local2, p0, p1) -- Unmapped intrinsic
    if local6 == 0 then
        add_dialogue("Jakher looks into your eyes, sizing you up intellectually. \"Thou dost need to learn more on the field of battle. If we spoke now I would be wasting my breath. Thou wouldst not understand a word I said.\"")
    elseif local6 == 1 then
        local7 = get_container_items(-359, -359, 644, -357) -- Unmapped intrinsic
        add_dialogue("You gather your gold and count it, finding that you have " .. local7 .. " gold altogether.")
        if local7 < p0 then
            add_dialogue("\"Thou dost not seem to have as much gold as I require to train here. Mayhaps at another time, when thy fortunes are more prosperous...\"")
        end
    elseif local6 == 2 then
        add_dialogue("\"Thou art already well-versed in the tactics of the battlefield. I am afraid that I am unable to train thee further in this.\"")
    else
        local8 = add_item_to_container(-359, -359, -359, 644, p0) -- Unmapped intrinsic
        add_dialogue("You pay " .. p0 .. " gold, and the training session begins.")
        add_dialogue("Jakher's eyes glow bright as he begins to explain some of the strategies used by great military leaders in awesome battles fought in ages past. He whispers to " .. local3 .. " conspiratorially as he draws maps in the dirt. After some time, " .. local3 .. " can practically feel some of his shrewdness starting to be absorbed.")
        local9 = external_0910H(2, local2) -- Unmapped intrinsic
        local10 = external_0910H(0, local2) -- Unmapped intrinsic
        if local9 < 30 then
            external_0916H(1, local2) -- Unmapped intrinsic
        end
        if local10 < 30 then
            external_0914H(1, local2) -- Unmapped intrinsic
        end
    end
    add_dialogue("\"I look forward to thy return.\"")
    return
end