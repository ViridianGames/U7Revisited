--- Best guess: Manages a sage conversation, offering a notebook key if dialogue choices are correct.
function utility_unknown_0832(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    save_answers() --- Guess: Saves dialogue answers
    var_0000 = show_dialogue_options({"I don't know", "Have Faith", "Strive for Unity", "No Answers", "Be Good"}) --- Guess: Shows dialogue options
    if var_0000 == "No Answers" then
        add_dialogue("The sage smiles. \"Thou hast begun thy journey on the road to enlightenment. As thou hast heard, all is not what one has been taught by one's teachers. 'Tis a pity. Now I suppose thou dost want to borrow the notebook?\"")
        var_0001 = get_dialogue_choice() --- Guess: Gets dialogue choice
        if var_0001 then
            add_dialogue("\"Very well. Dost thou promise to return my notebook?\"")
            var_0002 = get_dialogue_choice() --- Guess: Gets dialogue choice
            if var_0002 then
                if check_object_ownership(359, 254, 641, 357) then
                    add_dialogue("\"Then go find it! Thou hast the key!\"")
                elseif add_object_to_inventory(359, 254, 641, 1) then
                    add_dialogue("\"Very well. I am counting on thee to return it to me personally. No telling what misfortune may befall thee if thou dost fail to do so. And as further incentive, I just might give thee something else which will help thee in thy quest if thou dost return it to me safely.~~\"Here is the key to my storeroom, the first building to the south of here.\" He grins slyly. \"Thou must determine how to find the notebook thyself!\"")
                else
                    add_dialogue("\"Thou hast not enough room to take my key! Unload thy belongings and we shall try all of this again!\"")
                end
            else
                add_dialogue("\"Then I cannot let thee borrow the notebook!\"")
            end
        else
            add_dialogue("\"Oh. Very well, then.\"")
        end
    else
        add_dialogue("The sage frowns. \"That is not correct. Go and seek the true answer.\"")
    end
    restore_answers() --- Guess: Restores dialogue answers
end