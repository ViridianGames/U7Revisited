--- Best guess: Handles dialogue with Nystul, the mage in Britain, discussing his faltering magic, Lord British, and spell/reagent sales, with signs of mental decline.
function func_0418(eventid, itemref)
    local var_0000, var_0001, var_0002

    start_conversation()
    if eventid == 0 then
        abort()
    end
    switch_talk_to(24, 0)
    add_answer({"bye", "job", "name"})
    if not get_flag(153) then
        add_dialogue("You see your old friend Nystul, now a decrepit old man in mage's robes. He seems lost in thought, far away.")
        set_flag(153, true)
    else
        if not get_flag(3) then
            add_dialogue("\"Do I know thee?\" Nystul asks.")
        else
            add_dialogue("\"Yes, Avatar?\" Nystul asks.")
        end
    end
    while true do
        var_0000 = get_answer()
        if var_0000 == "name" then
            if not get_flag(3) then
                add_dialogue("The mage looks confused a moment. \"My name is Nystul? Yes, that is it!\"")
            else
                add_dialogue("\"Why, 'tis Nystul!\"")
            end
            remove_answer("name")
        elseif var_0000 == "job" then
            if not get_flag(3) then
                add_dialogue("\"Well, I used to perform quite a bit of magic,\" he says apologetically. \"At least... I -think- I used to do so. There is a man named Lord British, I think. I work for him.\"")
            else
                add_dialogue("\"I am Lord British's personal mage!\"")
            end
            add_answer({"Lord British", "magic"})
        elseif var_0000 == "magic" then
            if not get_flag(3) then
                add_dialogue("\"Sometimes the magic works, sometimes it doth not.\" He waves his hand, and drops his wand. \"Oops!\" he cries, as he bends to pick it up.")
                var_0000 = unknown_08F7H(2) --- Guess: Checks player status
                if var_0000 then
                    switch_talk_to(2, 0)
                    add_dialogue("\"Art thou sure this man is not really the jester?\"")
                    hide_npc(2)
                    switch_talk_to(24, 0)
                    add_dialogue("\"Anyway, as I was saying, uhm, what was I saying? Oh yes. Magic. I can still sell thee some spells or reagents if thou wouldst like.\"")
                end
            else
                add_dialogue("\"The magic is much better now. My spells all work very nicely. I thank thee, Avatar, for clearing the ether. Interested in any spells or reagents?\"")
            end
            remove_answer("magic")
            add_answer({"reagents", "spells"})
        elseif var_0000 == "spells" then
            add_dialogue("\"Dost thou wish to buy some spells?\"")
            var_0001 = select_option()
            if var_0001 then
                unknown_08C5H() --- Guess: Processes spell purchases
            else
                add_dialogue("\"Oh. Never mind, then.\"")
            end
        elseif var_0000 == "reagents" then
            add_dialogue("\"Dost thou wish to buy some reagents?\"")
            var_0002 = select_option()
            if var_0002 then
                unknown_08C6H() --- Guess: Processes reagent purchases
            else
                add_dialogue("\"Oh. Never mind, then.\"")
            end
        elseif var_0000 == "Lord British" then
            if not get_flag(3) then
                add_dialogue("\"Lord who? Dost thou mean that old man who sometimes sits on the throne?\"")
            else
                add_dialogue("\"He is the greatest ruler this land has ever known and I am proud to serve him.\"")
            end
            remove_answer("Lord British")
        elseif var_0000 == "bye" then
            break
        end
    end
    if not get_flag(3) then
        add_dialogue("\"Are we going somewhere?\"")
    else
        add_dialogue("\"Goodbye, Avatar. Do come see us again soon.\"")
    end
end