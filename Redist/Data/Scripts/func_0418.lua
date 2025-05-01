-- Manages Nystul's dialogue in Britain, covering his senility, magic issues, and spell/reagent sales.
function func_0418(eventid, itemref)
    local local0, local1, local2

    if eventid == 0 then
        return
    end

    switch_talk_to(24, 0)
    add_answer({"bye", "job", "name"})

    if not get_flag(153) then
        add_dialogue("You see your old friend Nystul, now a decrepit old man in mage's robes. He seems lost in thought, far away.")
        set_flag(153, true)
        add_dialogue("\"Do I know thee?\" Nystul asks.")
    else
        if not get_flag(3) then
            add_dialogue("\"Do I know thee?\" Nystul asks.")
        else
            add_dialogue("\"Yes, Avatar?\" Nystul asks.")
        end
    end

    while true do
        local answer = get_answer()
        if answer == "name" then
            if not get_flag(3) then
                add_dialogue("The mage looks confused a moment. \"My name is Nystul? Yes, that is it!\"")
            else
                add_dialogue("\"Why, 'tis Nystul!\"")
            end
            remove_answer("name")
        elseif answer == "job" then
            if not get_flag(3) then
                add_dialogue("\"Well, I used to perform quite a bit of magic,\" he says apologetically. \"At least... I -think- I used to do so. There is a man named Lord British, I think. I work for him.\"")
            else
                add_dialogue("\"I am Lord British's personal mage!\"")
            end
            add_answer({"Lord British", "magic"})
        elseif answer == "magic" then
            if not get_flag(3) then
                add_dialogue("\"Sometimes the magic works, sometimes it doth not.\" He waves his hand, and drops his wand. \"Oops!\" he cries, as he bends to pick it up.")
                local0 = get_item_type(-2)
                if local0 then
                    switch_talk_to(2, 0)
                    add_dialogue("\"Art thou sure this man is not really the jester?\"")
                    hide_npc(2)
                    switch_talk_to(24, 0)
                end
                add_dialogue("\"Anyway, as I was saying, uhm, what was I saying? Oh yes. Magic. I can still sell thee some spells or reagents if thou wouldst like.\"")
            else
                add_dialogue("\"The magic is much better now. My spells all work very nicely. I thank thee, Avatar, for clearing the ether. Interested in any spells or reagents?\"")
            end
            remove_answer("magic")
            add_answer({"reagents", "spells"})
        elseif answer == "spells" then
            add_dialogue("\"Dost thou wish to buy some spells?\"")
            local1 = get_answer()
            if local1 then
                buy_spells() -- Unmapped intrinsic 08C5
            else
                add_dialogue("\"Oh. Never mind, then.\"")
            end
        elseif answer == "reagents" then
            add_dialogue("\"Dost thou wish to buy some reagents?\"")
            local2 = get_answer()
            if local2 then
                buy_reagents() -- Unmapped intrinsic 08C6
            else
                add_dialogue("\"Oh. Never mind, then.\"")
            end
        elseif answer == "Lord British" then
            if not get_flag(3) then
                add_dialogue("\"Lord who? Dost thou mean that old man who sometimes sits on the throne?\"")
            else
                add_dialogue("\"He is the greatest ruler this land has ever known and I am proud to serve him.\"")
            end
            remove_answer("Lord British")
        elseif answer == "bye" then
            if not get_flag(3) then
                add_dialogue("\"Are we going somewhere?\"*")
            else
                add_dialogue("\"Goodbye, Avatar. Do come see us again soon.\"*")
            end
            break
        end
    end
    return
end