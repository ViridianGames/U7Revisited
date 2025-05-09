--- Best guess: Manages a scripted Fellowship sermon by a winged gargoyle, promoting their philosophy, with NPC interactions and party member reactions.
function func_08CE()
    start_conversation()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    var_0000 = unknown_08F7H(-184)
    var_0001 = unknown_08F7H(-188)
    var_0002 = unknown_08F7H(-186)
    var_0003 = unknown_08F7H(-2)
    var_0004 = unknown_0908H()
    add_dialogue("The winged gargoyle begins his sermon.")
    if not var_0000 then
        add_dialogue("You see the gargoyle clerk taking notes in the corner.")
    end
    add_dialogue("\"To talk tonight about why The Fellowship is important to your lives. To know that each of us sought The Fellowship to feel complete. To have had dreams and longings.\"")
    if not var_0002 then
        unknown_0003H(0, -186)
        add_dialogue("\"To be very true.\"")
        unknown_0004H(-186)
        unknown_0003H(0, -185)
    end
    add_dialogue("\"To know that others who are not members have given up their dreams. To see that they succumb to the mediocrity of their lives to find stability.\"")
    if not var_0003 then
        unknown_0003H(0, -2)
        add_dialogue("\"This is truly boring. Let us get some food -- I am hungry!\"")
        unknown_0004H(-2)
        unknown_0003H(0, -185)
    end
    add_dialogue("\"To see them begin to produce unreal ideas and become misaligned. To stray from the true path to what they seek. To lose contact with reality.\" He sighs. \"To find failure, not success in what they do.\"")
    if not var_0001 then
        unknown_0003H(0, -188)
        add_dialogue("\"To be very sad.\"")
        unknown_0004H(-188)
        unknown_0003H(0, -185)
    end
    add_dialogue("\"To know,\" he smiles, \"that each of the members present has faced such an awakening into the real world. To find in the order a clear path to reach what we seek!\"~~ The members present all stand and shout.")
    var_0005 = unknown_08F7H(-1)
    if not var_0005 then
        unknown_0003H(0, -1)
        add_dialogue("\"'Tis time for us to depart, " .. var_0004 .. ".\"")
        unknown_0004H(-1)
    end
    return
end