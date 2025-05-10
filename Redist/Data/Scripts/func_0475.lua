--- Best guess: Handles dialogue with Goth, the untrustworthy jailer at Yew’s Empath Abbey prison, offering information about prisoners (D’Rel and a troll) and selling cell keys for gold, with a sneering demeanor.
function func_0475(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C

    start_conversation()
    if eventid == 1 then
        switch_talk_to(117, 0)
        var_0000 = get_lord_or_lady()
        add_answer({"bye", "job", "name"})
        if not get_flag(335) then
            add_dialogue("The beady-eyed man sneers at you.")
            set_flag(335, true)
        else
            add_dialogue("\"What dost thou want now?\" Goth spits.")
        end
        if not get_flag(300) then
            add_answer("buy keys")
        end
        while true do
            var_0001 = get_answer()
            if var_0001 == "name" then
                add_dialogue("\"Goth. Not that it is any of thy business!\"")
                remove_answer("name")
            elseif var_0001 == "job" then
                add_dialogue("\"What does it look like I do?\" he says, holding up a ring of keys. \"Gardening?\"")
                add_answer({"gardening", "keys"})
            elseif var_0001 == "gardening" then
                add_dialogue("\"What? Art thou daft?\" He shakes his head. \"Well, at least thou art in the right area for gardening.\"")
                add_answer("area")
                remove_answer("gardening")
            elseif var_0001 == "area" then
                add_dialogue("\"Empath Abbey, dolt!\"")
                add_answer("Empath Abbey")
                remove_answer("area")
            elseif var_0001 == "Empath Abbey" then
                add_dialogue("\"As a matter of fact, I know quite a bit about the people who live here. And I just might even tell thee. What is it worth to thee in gold?\"")
                save_answers()
                add_answer({"5", "4", "3", "2", "nothing"})
                remove_answer("Empath Abbey")
            elseif var_0001 == "nothing" then
                restore_answers()
                add_dialogue("\"Fine by me!\"")
            elseif var_0001 == "4" or var_0001 == "3" or var_0001 == "2" then
                add_dialogue("He glowers at you. \"Thou must do better than that, fool!\"")
            elseif var_0001 == "5" then
                restore_answers()
                var_0002 = unknown_0028H(359, 359, 644, 357) --- Guess: Counts items
                if var_0002 > 4 then
                    var_0003 = unknown_002BH(true, 359, 359, 644, 5) --- Guess: Deducts item and adds item
                    add_dialogue("\"I will tell thee what I know: Sir Jeff is in charge of the High Court. 'E's a real mean bastard, so I would stay away from 'im. The monks nearby make excellent wine, and Aimi doth warm a man's... heart. And whatever thou dost, do not waste time talking to the undertaker -- 'e's daft in the head.\"")
                else
                    add_dialogue("\"Thou dost not have enough gold, toad.\"")
                end
                remove_answer({"5", "4", "3", "2"})
            elseif var_0001 == "keys" then
                add_dialogue("\"These? They are for the prisoner's cells, witless knave!\"")
                add_answer({"buy keys", "prisoners"})
                remove_answer("keys")
            elseif var_0001 == "prisoners" then
                add_dialogue("\"I will tell thee for 5 gold. Interested?\"")
                var_0004 = select_option()
                if var_0004 then
                    var_0005 = unknown_0028H(359, 359, 644, 357) --- Guess: Counts items
                    if var_0005 > 4 then
                        var_0006 = unknown_002BH(true, 359, 359, 644, 5) --- Guess: Deducts item and adds item
                        add_dialogue("\"One of them is named D'Rel. E's a pirate, from Buccaneer's Den.\"")
                        add_answer("another prisoner")
                    else
                        add_dialogue("\"Thou dost not have enough money, stonehead.\"")
                    end
                else
                    add_dialogue("\"Pinchpenny!\"")
                    abort()
                end
                remove_answer("prisoners")
            elseif var_0001 == "another prisoner" then
                add_dialogue("\"Another, eh. Hast thou 5 more gold for me?\"")
                var_0007 = select_option()
                if var_0007 then
                    var_0008 = unknown_0028H(359, 359, 644, 357) --- Guess: Counts items
                    if var_0008 > 4 then
                        add_dialogue("\"The other one is a troll. 'E don't talk much, but 'e's the first troll prisoner I have ever seen.\"")
                        var_0009 = unknown_002BH(true, 359, 359, 644, 5) --- Guess: Deducts item and adds item
                        remove_answer("another prisoner")
                    else
                        add_dialogue("\"Thou canst not fool me, brainless dolt. Thou dost not have enough gold!\"")
                    end
                else
                    add_dialogue("\"Fine, slug!\"")
                    abort()
                end
                remove_answer("another prisoner")
            elseif var_0001 == "buy keys" then
                add_dialogue("\"Thou dost want these, eh?\" he asks, holding up keys. \"'Twill cost thee... 20 gold. Still want them?\"")
                var_000A = select_option()
                if var_000A then
                    var_000B = unknown_0028H(359, 359, 644, 357) --- Guess: Counts items
                    if var_000B > 19 then
                        add_dialogue("\"Done!\"")
                        var_000C = unknown_002BH(false, 359, 359, 644, 20) --- Guess: Deducts item and adds item
                        var_000C = unknown_002CH(false, 359, 248, 641, 1) --- Guess: Checks inventory space
                        remove_answer("buy keys")
                    else
                        add_dialogue("He smiles cruelly. \"I am afraid thou dost not have enough gold.\"")
                    end
                else
                    add_dialogue("\"Fine. Rot for all I care!\"")
                    abort()
                end
                remove_answer("buy keys")
            elseif var_0001 == "bye" then
                break
            end
        end
        add_dialogue("\"Indeed, knave. Get thee gone!\"")
    elseif eventid == 0 then
        abort()
    end
end