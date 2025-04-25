-- Function 08CE: Manages gargoyle Fellowship sermon dialogue
function func_08CE()
    -- Local variables (6 as per .localc)
    local local0, local1, local2, local3, local4, local5

    local0 = call_08F7H(-184)
    local1 = call_08F7H(-188)
    local2 = call_08F7H(-186)
    local3 = call_08F7H(-2)
    local4 = call_0908H()
    local5 = call_08F7H(-1)

    say("The winged gargoyle begins his sermon.")
    if not local0 then
        say("You see the gargoyle clerk taking notes in the corner.")
    end
    say("\"To talk tonight about why The Fellowship is important to your lives. To know that each of us sought The Fellowship to feel complete. To have had dreams and longings.\"")
    if not local2 then
        callis_0003(0, -186)
        say("\"To be very true.\"")
        callis_0004(-186)
        callis_0003(0, -185)
    end
    say("\"To know that others who are not members have given up their dreams. To see that they succumb to the mediocrity of their lives to find stability.\"")
    if not local3 then
        callis_0003(0, -2)
        say("\"This is truly boring. Let us get some food -- I am hungry!\"")
        callis_0004(-2)
        callis_0003(0, -185)
    end
    say("\"To see them begin to produce unreal ideas and become misaligned. To stray from the true path to what they seek. To lose contact with reality.\" He sighs. \"To find failure, not success in what they do.\"")
    if not local1 then
        callis_0003(0, -188)
        say("\"To be very sad.\"")
        callis_0004(-188)
        callis_0003(0, -185)
    end
    say("\"To know,\" he smiles, \"that each of the members present has faced such an awakening into the real world. To find in the order a clear path to reach what we seek!\"~~ The members present all stand and shout.")
    if not local5 then
        callis_0003(0, -1)
        say("\"'Tis time for us to depart, ", local4, ".\"")
        callis_0004(-1)
        abort()
    end

    return
end

-- Helper functions
function say(...)
    print(table.concat({...}))
end

function abort()
    -- Placeholder
end