--- Best guess: Manages a gargoyle-led magic training session, checking player intelligence and gold, enhancing mental capabilities if conditions are met.
function func_089A(P0, P1)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A

    var_0002 = unknown_0920H()
    var_0003 = _GetPlayerName(var_0002)
    if var_0002 == 0 then
        return
    end
    var_0004 = 3
    var_0005 = unknown_0922H(var_0004, var_0002, P0, P1)
    if var_0005 == 0 then
        add_dialogue("\"To see you need more experience to train at this time.\"")
    elseif var_0005 == 1 then
        var_0006 = unknown_0028H(-359, -359, 644, -357)
        add_dialogue("You gather your gold and count it, finding that you have " .. var_0006 .. " gold altogether.")
        if var_0006 < P0 then
            add_dialogue("\"To have not enough gold to train here.\"")
            return
        end
    elseif var_0005 == 2 then
        add_dialogue("After asking a few questions, he exclaims, \"To be already as well-educated as I. To apologize for my inability to increase your knowledge, but there is nothing I can do.\"")
        return
    end
    var_0007 = unknown_002BH(true, -359, -359, 644, P0)
    add_dialogue("You pay " .. P0 .. " gold, and the training session begins.")
    var_0008 = var_0002 == -356 and "you begin" or var_0003 .. " begins"
    add_dialogue("The gargoyle begins with some intense memorization exercises which eventually lead to concepts of spell theory. At the end, " .. var_0008 .. " to notice a change in mental capabilities and thought reaction speed.")
    var_0009 = unknown_0910H(2, var_0002)
    if var_0009 < 30 then
        unknown_0916H(2, var_0002)
    end
    var_000A = unknown_0910H(6, var_0002)
    if var_000A < 30 then
        unknown_0918H(1, var_0002)
    end
end