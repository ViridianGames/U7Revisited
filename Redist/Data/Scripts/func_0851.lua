--- Best guess: Initiates a quest to deliver a sealed package to Elynor in Minoc, checking inventory and setting quest flags.
function func_0851()
    local var_0000, var_0001, var_0002, var_0003

    start_conversation()
    if not get_flag(214) then
        add_dialogue("@\"I need thee to deliver this sealed package unopened to Elynor, the leader of our Fellowship branch in Minoc. Elynor will reward thee upon receiving it, thou dost have my word. May I trust thee to do it?\"@")
    else
        add_dialogue("@\"Hast thou reconsidered thy task? Wilt thou deliver the package to Elynor in Minoc?\"@")
    end
    var_0000 = get_dialogue_choice() --- Guess: Gets player choice
    if not var_0000 then
        var_0001 = check_inventory_space(-359, -359, 798, -26) --- Guess: Checks inventory space
        var_0002 = moveobject_(var_0001) --- Guess: Moves package
        var_0003 = removeobject_(-356) --- Guess: Removes temporary item
        if not var_0003 then
            add_dialogue("@\"Excellent! Here it is. Thou must now be on thy way!\"@")
            set_flag(143, true) --- Guess: Marks quest accepted
            set_quest_property(200) --- Guess: Sets quest property
            abort() --- Guess: Aborts script
        else
            var_0003 = removeobject_(-26) --- Guess: Removes alternative item
            add_dialogue("@\"Zounds! Thine hands are too full to take the box. Please divest thyself of some of thy belongings.\"@")
            set_flag(215, true) --- Guess: Marks inventory full
            abort() --- Guess: Aborts script
        end
    else
        add_dialogue("@\"Avatar, I know that thou hast gone on many quests. The quest for the spiritual is often the most fearsome and elusive one of all, as we both know. Do not be afraid of thyself, Avatar, for that is what prevents us from doing that which we must do. We shall speak of this again once thou hast reconsidered. Ask me about the package again tomorrow.\"@")
        set_flag(214, true) --- Guess: Marks quest declined
        abort() --- Guess: Aborts script
    end
end