--- Best guess: Manages a training session with Chad, checking player stats and gold, providing combat training if conditions are met.
function utility_unknown_0863(P0, P1)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F

    var_0002 = get_player_name()
    var_0003 = get_lord_or_lady()
    var_0004 = "the Avatar"
    if not get_flag(497) then
        var_0005 = var_0002
    elseif not get_flag(499) then
        var_0005 = var_0004
    elseif not get_flag(498) then
        var_0005 = var_0003
    end
    var_0006 = utility_unknown_1056()
    var_0007 = get_player_name(var_0006)
    if var_0006 == 0 then
        return
    end
    var_0008 = 3
    var_0009 = utility_unknown_1058(var_0008, var_0006, P0, P1)
    if var_0009 == 0 then
        add_dialogue("\"It seems that thou dost need a little more time to hone thy reflexes. If thou dost wish to return later, when thou hast more experience, I would be most happy to train thee.\"")
    elseif var_0009 == 1 then
        var_000A = count_objects()
        add_dialogue("You gather your gold and count it, finding that you have " .. var_000A .. " gold altogether.")
        if var_000A < P0 then
            add_dialogue("\"Thou hast not enough gold to pay me. I am sorry but I cannot train thee now.\"")
            return
        end
    elseif var_0009 == 2 then
        add_dialogue("\"Zounds! Thou art quick. Too quick, in fact, for me to be able to help thee become faster. I am sorry, " .. var_0005 .. ".\"")
        return
    end
    var_000B = remove_party_items(true, -359, -359, 644, P0)
    add_dialogue("You pay " .. P0 .. " gold, and the training session begins.")
    var_000C = var_0006 == -356 and "You" or var_0007
    var_000D = var_0006 == -356 and "you" or var_0007
    add_dialogue(var_000C .. " and Chad spar for a few minutes. He teaches " .. var_000D .. " several expert maneuvers that better utilize speed and agility in combat.")
    var_000E = utility_unknown_1040(1, var_0006)
    if var_000E < 30 then
        utility_unknown_1047(1, var_0006)
    end
    var_000F = utility_unknown_1040(4, var_0006)
    if var_000F < 30 then
        utility_unknown_1045(2, var_0006)
    end
end