--- Best guess: Manages a dialogue with Chuckles, providing a scroll (item 797) if conditions are met.
function func_0862(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007

    start_conversation()
    var_0000 = check_npc_presence(1) --- Guess: Checks NPC presence
    var_0001 = false
    var_0002 = false
    var_0003 = false
    var_0004 = false
    add_dialogue("@Then prove it. Talk to me.@")
    clear_answers() --- Guess: Clears conversation answers
    var_0005 = show_dialogue_options({"Hi, Chuck", "Hi, Chuckles", "Hello, Fool", "Hello, Chuckles"}) --- Guess: Shows dialogue options
    if var_0005 == "Hi, Chuck" then
        add_dialogue("@Hi there! What is on thy mind?@")
        var_0001 = true
        clear_answers() --- Guess: Clears conversation answers
    else
        calle_0861H() --- External call to rule warning
    end
    if var_0001 then
        var_0005 = show_dialogue_options({"I need answers", "many problems", "too much", "trouble"}) --- Guess: Shows dialogue options
        if var_0005 == "too much" then
            add_dialogue("@Ah, I do know what thou dost mean! Thou dost need help, yes?@")
            var_0002 = true
            clear_answers() --- Guess: Clears conversation answers
        else
            calle_0861H() --- External call to rule warning
        end
    end
    if var_0002 then
        var_0005 = show_dialogue_options({"Most assuredly", "Canst thou help?", "Absolutely", "Yes, I do"}) --- Guess: Shows dialogue options
        if var_0005 == "Yes, I do" or var_0005 == "Canst thou help?" then
            add_dialogue("@Hmmm. I might could give thee a clue.@")
            if var_0000 then
                switch_talk_to(0, 1) --- Guess: Initiates dialogue
                add_dialogue("@I would like to give Chuckles a black eye!@")
                hide_npc(1) --- Guess: Hides NPC
                switch_talk_to(0, 25) --- Guess: Initiates dialogue
            end
            var_0003 = true
            clear_answers() --- Guess: Clears conversation answers
        else
            calle_0861H() --- External call to rule warning
        end
    end
    if var_0003 then
        var_0005 = show_dialogue_options({"I wish thou wouldst", "That would be worthwhile", "I need it immediately", "That would be big of thee"}) --- Guess: Shows dialogue options
        if var_0005 == "That would be big of thee" or var_0005 == "I wish thou wouldst" then
            add_dialogue("@What wilt thou give me for a clue?@")
            var_0004 = true
            clear_answers() --- Guess: Clears conversation answers
        else
            calle_0861H() --- External call to rule warning
        end
    end
    if var_0004 then
        var_0005 = show_dialogue_options({"nothing", "a smile", "my friendship", "gold", "I shan't murder thee"}) --- Guess: Shows dialogue options
        if var_0005 == "gold" then
            add_dialogue("@Chuckles holds his hand up. 'Tis not right...@")
            var_0006 = add_item_to_inventory(359, 797, 1, 1) --- Guess: Adds item to inventory
            if var_0006 then
                set_flag(111, true)
                start_quest(50) --- Guess: Starts quest
                clear_answers() --- Guess: Clears conversation answers
                add_dialogue("@So long, my friend! Do not forg...@")
            else
                add_dialogue("@Oh! Thou dost not have room for the scroll!...@")
            end
        elseif var_0005 == "a smile" then
            add_dialogue("@How nice! All right! I shall give thee a clue...@")
            var_0006 = add_item_to_inventory(359, 797, 1, 1) --- Guess: Adds item to inventory
            if var_0006 then
                set_flag(111, true)
                start_quest(50) --- Guess: Starts quest
                clear_answers() --- Guess: Clears conversation answers
                add_dialogue("@So long, my friend! Do not forg...@")
            else
                add_dialogue("@Oh! Thou dost not have room for the scroll!...@")
            end
        elseif var_0005 == "I shan't murder thee" or var_0005 == "my friendship" or var_0005 == "nothing" then
            calle_0861H() --- External call to rule warning
        end
    end
end