--- Best guess: Manages a combat training session with Jakher, checking player intelligence and gold, enhancing tactical skills if conditions are met.
function func_089F(P0, P1)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A

    var_0002 = unknown_0920H()
    var_0003 = get_player_name(var_0002)
    var_0004 = get_player_name()
    if var_0003 == var_0004 then
        var_0003 = "you"
    end
    if var_0002 == 0 then
        return
    end
    var_0005 = 2
    var_0006 = unknown_0922H(var_0005, var_0002, P0, P1)
    if var_0006 == 0 then
        add_dialogue("Jakher looks into your eyes, sizing you up intellectually. \"Thou dost need to learn more on the field of battle. If we spoke now I would be wasting my breath. Thou wouldst not understand a word I said.\"")
    elseif var_0006 == 1 then
        var_0007 = unknown_0028H(-359, -359, 644, -357)
        add_dialogue("You gather your gold and count it, finding that you have " .. var_0007 .. " gold altogether.")
        if var_0007 < P0 then
            add_dialogue("\"Thou dost not seem to have as much gold as I require to train here. Mayhaps at another time, when thy fortunes are more prosperous...\"")
            return
        end
    elseif var_0006 == 2 then
        add_dialogue("\"Thou art already well-versed in the tactics of the battlefield. I am afraid that I am unable to train thee further in this.\"")
        return
    end
    var_0008 = unknown_002BH(true, -359, -359, 644, P0)
    add_dialogue("You pay " .. P0 .. " gold, and the training session begins.")
    add_dialogue("Jakher's eyes glow bright as he begins to explain some of the strategies used by great military leaders in awesome battles fought in ages past. He whispers to " .. var_0003 .. " conspiratorially as he draws maps in the dirt. After some time, " .. var_0003 .. " can practically feel some of his shrewdness starting to be absorbed.")
    var_0009 = unknown_0910H(2, var_0002)
    var_000A = unknown_0910H(0, var_0002)
    if var_0009 < 30 then
        unknown_0916H(1, var_0002)
    end
    if var_000A < 30 then
        unknown_0914H(1, var_0002)
    end
    add_dialogue("\"I look forward to thy return.\"")
end