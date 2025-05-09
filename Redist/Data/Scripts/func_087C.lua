--- Best guess: Handles an interaction with an Emp requesting honey, with dialogue and inventory checks, tying into a quest or environmental interaction.
function func_087C()
    local var_0000, var_0001

    start_conversation()
    switch_talk_to(0, 283) --- Guess: Switches to Emp
    if not get_flag(340) then
        add_dialogue("@The ape-like creature slowly and cautiously walks up to you. He, or she, sniffs for a moment, and then points to the honey you are carrying.@")
    end
    add_answer({"Go away!", "Want honey?"}) --- Guess: Adds dialogue options
    while true do
        var_0000 = get_answer() --- Guess: Gets conversation answer
        if var_0000 == "Want honey?" then
            add_dialogue("@\"Honey will be given by you to me?\"@")
            var_0000 = get_dialogue_choice() --- Guess: Gets player choice
            if var_0000 then
                var_0001 = remove_item_from_inventory(-359, -359, 772, 1) --- Guess: Removes honey from inventory
                add_dialogue("@\"You are thanked.\"@")
                if not get_flag(340) then
                    set_quest_property(10) --- Guess: Sets quest property
                    set_flag(340, true)
                end
            else
                if not get_flag(340) then
                    add_dialogue("@The Emp appears very disappointed.\"@")
                else
                    add_dialogue("@\"`Goodbye' is said to you.\"@")
                    abort() --- Guess: Aborts script
                end
            end
        elseif var_0000 == "Go away!" then
            add_dialogue("@It does.@")
            abort() --- Guess: Aborts script
        end
        remove_answer({"Go away!", "Want honey?"}) --- Guess: Removes dialogue options
        add_answer({"Go away!", "Want honey?"}) --- Guess: Re-adds dialogue options
    end
end