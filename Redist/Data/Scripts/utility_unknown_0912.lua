--- Best guess: Handles dialogue with Adjhar, progressing a quest involving Bollux's sacrifice and the book "The Stone of Castambre".
function utility_unknown_0912(eventid, objectref)
    local var_0000, var_0001

    start_conversation()
    switch_talk_to(288) --- Guess: Initiates dialogue
    if not get_flag(788) then
        add_answer({"bye", "sacrificed", "Don't know"}) --- Guess: Adds dialogue options
        set_flag(788, true)
    else
        add_answer({"bye", "job", "name"}) --- Guess: Adds dialogue options
    end
    if not get_flag(798) then
        add_answer("what next") --- Guess: Adds dialogue option
    end
    while true do
        if compare_answer("Don't know", 1) then
            add_dialogue("@He kneels over the body and inspects the other golem...@")
            remove_answer({"sacrificed", "Don't know"}) --- Guess: Removes dialogue options
            add_dialogue("@I must help him, as he helped me! Wilt thou assist?@")
            if get_dialogue_choice() then --- Guess: Gets dialogue choice
                add_dialogue("@Very good,' he says, noticeably relieved. 'I thank thee in advance.@")
                set_flag(798, true)
                add_answer({"fool", "job", "name"}) --- Guess: Adds dialogue options
            else
                add_dialogue("@Then I must go this one myself,' he says angrily...@")
                add_dialogue("@He looks at you carefully. His stoney features...@")
                return
            end
        elseif compare_answer("sacrificed", 1) then
            add_dialogue("@You quickly relate the details of Bollux's death...@")
            remove_answer({"sacrificed", "Don't know"}) --- Guess: Removes dialogue options
            add_dialogue("@I must help him, as he helped me! Wilt thou assist?@")
            if get_dialogue_choice() then --- Guess: Gets dialogue choice
                add_dialogue("@Very good,' he says, notably relieved. 'I thank thee in advance.@")
                set_flag(798, true)
                add_answer({"fool", "job", "name"}) --- Guess: Adds dialogue options
            else
                add_dialogue("@Then I must go this one myself,' he says angrily...@")
                add_dialogue("@He looks at you carefully. His stoney features...@")
                return
            end
        elseif compare_answer("name", 1) then
            remove_answer("name") --- Guess: Removes dialogue option
            add_dialogue("@I am the golem called Adjhar, at thy service.@")
        elseif compare_answer("job", 1) then
            add_dialogue("@I am one of the guardians of the Shrines of the Principles...@")
            add_answer({"wall", "Shrines", "Bollux"}) --- Guess: Adds dialogue options
        elseif compare_answer("Shrines", 1) then
            remove_answer("Shrines") --- Guess: Removes dialogue option
            add_dialogue("@Surely thou hast heard of the Shrines of the Three Principles...@")
        elseif compare_answer("wall", 1) then
            remove_answer("wall") --- Guess: Removes dialogue option
            add_dialogue("@I do not remember the incident clearly...@")
            if get_dialogue_choice() then --- Guess: Gets dialogue choice
                add_dialogue("@Then it is imperative that we find a way to bring him back!...@")
            else
                add_dialogue("@Strange,' he says, puzzled. 'I am at a loss then to explain my arrival here...@")
            end
        elseif compare_answer("Bollux", 1) then
            add_dialogue("@Hast thou not already met him? He is my older brother, and my friend.@")
            remove_answer("Bollux") --- Guess: Removes dialogue option
            add_answer("older") --- Guess: Adds dialogue option
        elseif compare_answer("older", 1) then
            add_dialogue("@Master Astelleron -- we actually called him our father...@")
            remove_answer("older") --- Guess: Removes dialogue option
        elseif compare_answer("what next", 1) then
            remove_answer("what next") --- Guess: Removes dialogue option
            add_dialogue("@Dost thou have the book entitled, 'The Stone of Castambre?'@")
            if get_dialogue_choice() then --- Guess: Gets dialogue choice
                var_0000 = check_object_inventory(359, 144, 642, 1, 357) --- Guess: Checks inventory
                if var_0000 then
                    add_dialogue("@His eyes reveal his hope. As he takes the book from you...@")
                    utility_shop_0913() --- External call to quest progression
                else
                    add_dialogue("@I must see the book the book to use it...@")
                    set_flag(799, true)
                end
            else
                add_dialogue("@Please go and recover it then. I believe it contains information...@")
                set_flag(799, true)
            end
        elseif compare_answer("fool", 1) then
            remove_answer("fool") --- Guess: Removes dialogue option
            add_dialogue("@Poor Bollux did not know of the Stone of Castambre...@")
            if get_dialogue_choice() then --- Guess: Gets dialogue choice
                add_dialogue("@Dost thou have it with thee?@")
                if get_dialogue_choice() then --- Guess: Gets dialogue choice
                    var_0000 = check_object_inventory(359, 144, 642, 1, 357) --- Guess: Checks inventory
                    if var_0000 then
                        add_dialogue("@His eyes reveal his hope. As he takes the book from you...@")
                        utility_shop_0913() --- External call to quest progression
                    else
                        add_dialogue("@I must see the book the book to use it...@")
                        set_flag(799, true)
                    end
                else
                    add_dialogue("@Please go and recover it then. I believe it contains information...@")
                    set_flag(799, true)
                end
            else
                add_dialogue("@Then I recommend thou dost search within my master's chambers for it...@")
            end
        elseif compare_answer("bye", 1) then
            add_dialogue("@I can offer nothing more for thine assistance than my deepest appreciation...@")
            return
        end
    end
end