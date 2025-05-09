--- Best guess: Manages Jeanette’s dialogue, handling her role as a tavern wench at the Blue Boar, her romantic interests, and interactions with Dupre, with flag-based progression and corrections about Charles’s social status.
function func_042F(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid ~= 1 then
        if eventid == 0 then
            unknown_092EH(47)
        end
        add_dialogue("\"Farewell!\"")
        return
    end

    start_conversation()
    switch_talk_to(0, 47)
    var_0000 = unknown_003BH()
    var_0001 = unknown_001CH(unknown_001BH(47))
    add_answer({"bye", "job", "name"})
    if not get_flag(123) then
        add_answer("Charles")
    end
    if not get_flag(176) then
        add_dialogue("This young, lovely tavern wench is sexy and sweet.")
        set_flag(176, true)
    else
        add_dialogue("\"Hello again!\" bubbly Jeanette says.")
    end
    while true do
        if cmps("name") then
            add_dialogue("\"Jeanette, at thy service!\"")
            remove_answer("name")
        elseif cmps("job") then
            add_dialogue("\"I work for Lucy at the Blue Boar. I serve food and drinks.\"")
            if var_0001 == 23 then
                add_dialogue("\"If there is anything thou wouldst like, please say so! And, er, I shall give thee a discount if thou dost buy from me!\"")
                var_0002 = unknown_08F7H(-4)
                if var_0002 then
                    add_dialogue("\"Why, Sir Dupre! How good to see thee again!\"")
                    switch_talk_to(0, -4)
                    add_dialogue("\"Hello milady! I thought I might re-sample The Blue Boar's fine beverages!\"")
                    switch_talk_to(0, 47)
                    add_dialogue("\"Any time, milord! Any time!\"")
                    hide_npc4)
                    switch_talk_to(0, 47)
                end
                add_answer({"buy", "drink", "food"})
            else
                add_dialogue("\"I work during the day and evening hours. Thou shouldst come by the pub then and we shall talk more!\"")
            end
        elseif cmps("food") then
            add_dialogue("\"Lucy is a good cook. I recommend everything. Especially Silverleaf.\"")
            add_answer("Silverleaf")
            remove_answer("food")
        elseif cmps("Silverleaf") then
            add_dialogue("\"Wonderful dish. Try it!\"")
            remove_answer("Silverleaf")
        elseif cmps("drink") then
            add_dialogue("\"Thou dost look like thou dost need a good drink!\"")
            remove_answer("drink")
        elseif cmps("buy") then
            unknown_08A0H()
        elseif cmps("Charles") then
            add_dialogue("\"He spoke of me, did he? Well, he may think again! I cannot bring myself to socialize with the upper class. Those bourgeoisie rich men are obnoxious and egotistical. Besides, I am in love with another.\"")
            set_flag(125, true)
            remove_answer("Charles")
            add_answer({"another", "upper class"})
        elseif cmps("upper class") then
            add_dialogue("\"They are all alike. They work in castles and have piles of gold and can have any woman they want! On the other hand, a humble merchant is the perfect man.\"")
            remove_answer("upper class")
        elseif cmps("another") then
            add_dialogue("\"'Tis Willy the Baker! But he does not know it yet!\" she giggles.")
            set_flag(133, true)
            var_0003 = unknown_08F7H(-37)
            if var_0003 then
                switch_talk_to(0, -37)
                add_dialogue("\"A moment, Jeanette! Thou hast it all wrong! Charles is a -servant-! Thou art an ignoramus! Charles is not 'upper class'! He is as working class as thee! 'Tis Willy who is the rich merchant! If thou dost ask me, 'tis Willy who is obnoxious and egotistical. Charles is a dream!\"")
                hide_npc37)
                switch_talk_to(0, 47)
            else
                add_dialogue("You point out to Jeanette that Charles is a servant.")
            end
            add_dialogue("Jeanette thinks about what was said. \"Thou art right! I cannot believe I have been so blind! Oh, Charles! I can actually consider Charles! And he is... so handsome!\" Jeanette squeals with delight. \"I shall have to flirt with him in earnest next time he is in the pub!\"")
            set_flag(126, true)
            unknown_0911H(20)
            remove_answer("another")
        elseif cmps("bye") then
            break
        end
    end
    return
end