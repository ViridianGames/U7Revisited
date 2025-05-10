--- Best guess: Manages archery training with Bradman, checking gold and skill levels, and improving hand-eye coordination.
function func_0856(arg_0000, arg_0001)
    local var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B

    start_conversation()
    var_0002 = get_training_target() --- Guess: Gets training target
    var_0003 = get_player_name(var_0002) --- Guess: Gets player name
    if var_0002 == -356 then
        var_0003 = "you"
    end
    if var_0002 == 0 then
        return
    end
    if var_0002 == -1 or var_0002 == -10 then
        var_0000 = arg_0000 / 2 --- Guess: Discounts cost for specific targets
        add_dialogue("@\"I cannot charge a master such as thyself full price.\"@")
    end
    var_0004 = 2 --- Guess: Skill ID for archery
    var_0005 = check_training_eligibility(var_0004, var_0002, var_0000, arg_0001) --- Guess: Checks training eligibility
    if var_0005 == 0 then
        add_dialogue("@After a bit of target practice, he says, \"I am sorry to say this, but thou dost need more practice before I will be able to train thee. Perhaps at a later time thou wilt be in a better position to receive mine instruction.\"@")
        return
    elseif var_0005 == 1 then
        var_0006 = check_object_ownership(-359, -359, 644, -357) --- Guess: Checks gold
        add_dialogue("@You gather your gold and count it, finding that you have " .. var_0006 .. " gold altogether.@")
        if var_0006 < var_0000 then
            add_dialogue("@\"Thou hast not the gold to train.\"@")
            return
        end
    elseif var_0005 == 2 then
        add_dialogue("@After a few target shots, he exclaims, \"Thou art already as proficient as I! I can do nothing to improve thy coordination of hand and eye!\"@")
        return
    end
    var_0007 = remove_object_from_inventory(-359, -359, 644, var_0000) --- Guess: Removes gold
    add_dialogue("@You pay " .. var_0000 .. " gold, and the training session begins.@")
    if var_0002 == -356 then
        var_0008 = "You"
    else
        var_0008 = var_0003
    end
    if var_0002 == -356 then
        var_0009 = "you"
    else
        var_0009 = var_0003
    end
    if var_0002 == -356 then
        var_000A = ""
    else
        var_000A = "s"
    end
    add_dialogue("@" .. var_0008 .. " and Bradman spend some time taking target practice with the bow. Shortly, " .. var_0009 .. " notice" .. var_000A .. " a significant increase in hand-eye coordination.@")
    var_000B = get_training_level(1, var_0002) --- Guess: Gets current skill level
    if var_000B < 30 then
        improve_skill(2, var_0002) --- Guess: Improves archery skill
    end
end