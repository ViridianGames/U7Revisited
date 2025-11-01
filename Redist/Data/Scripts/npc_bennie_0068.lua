--- Best guess: Handles dialogue with Bennie, Head Servant at Lord British's castle, serving meals and discussing his family's service, with comments on his absent-mindedness.
function npc_bennie_0068(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0009, var_000A

    start_conversation()
    if eventid == 1 then
        switch_talk_to(68, 0)
        var_0000 = get_player_name()
        add_answer({"bye", "job", "name"})
        if not get_flag(113) then
            add_answer("absent-minded")
        end
        var_0001 = get_schedule() --- Guess: Checks game state or timer
        var_0002 = get_party_members()
        if not get_flag(197) then
            add_dialogue("You see an elderly man with good humor and a warm smile.")
            set_flag(197, true)
        else
            add_dialogue("\"Yes, Avatar?\" Bennie asks with authority.")
        end
        while true do
            var_0003 = get_answer()
            if var_0003 == "name" then
                add_dialogue("\"All my friends call me Bennie.\"")
                remove_answer("name")
            elseif var_0003 == "job" then
                add_dialogue("\"I am the Head Servant at the castle. My job consists of keeping the other servants in line and serving the meals.\"")
                add_answer({"meals", "Head Servant"})
            elseif var_0003 == "Head Servant" then
                add_dialogue("\"Yes, I have been Head Servant for many years. Mine entire family works for Lord British. My son is the king's gentleman's gentleman. My daughter is the Royal Chambermaid. My wife is Head Cook. We are pleased to work for Lord British.\"")
                remove_answer("Head Servant")
            elseif var_0003 == "meals" then
                add_dialogue("\"My wife, Boots, is the head cook. Her specialty is roast beef. She makes wonderful pastries, too. Enough of those will give thee a very un-Avatar-like figure!\"")
                if var_0001 == 3 or var_0001 == 6 then
                    add_dialogue("\"Wouldst thou like to order a meal?\"")
                    var_0003 = select_option()
                    if var_0003 then
                        if not get_flag(216) then
                            var_0004 = get_timer(1) --- Guess: Checks daily meal limit
                        else
                            set_flag(216, true)
                            var_0004 = 25
                        end
                        if var_0004 >= 24 then
                            add_dialogue("\"For thee, it is free!\"")
                            add_dialogue("Bennie serves you and your party a delicious meal of beef and pastry.")
                            var_0002 = get_party_members()
                            var_0005 = 0
                            for _ = 1, var_0002 do
                                var_0005 = var_0005 + 1
                            end
                            var_0009 = add_party_items(true, 9, 359, 377, var_0005) --- Guess: Checks inventory space
                            var_000A = add_party_items(true, 6, 359, 377, var_0005) --- Guess: Checks inventory space
                            if var_0009 or var_000A then
                                set_timer(1) --- Guess: Resets daily meal limit
                                add_dialogue("\"Return tomorrow and thou canst have another free meal.\"")
                            else
                                add_dialogue("\"Thou art carrying too much to take the beef and pastry!\"")
                            end
                        else
                            add_dialogue("\"I am sorry, " .. var_0000 .. ", but I am allowed to serve thee only once per day. Return tomorrow for a meal.\"")
                        end
                    else
                        add_dialogue("\"Oh. Well, thou must return when thou art hungry.\"")
                    end
                else
                    add_dialogue("\"Come to the dining room during breakfast or dinner and I will be most honored to serve thee!\"")
                end
                remove_answer("meals")
            elseif var_0003 == "absent-minded" then
                add_dialogue("\"Yes, I suppose I am. I am also becoming a little hard-of-hearing. When thou hast seen as many years as I have, one's faculties are no longer perfect.\"")
                remove_answer("absent-minded")
            elseif var_0003 == "bye" then
                break
            end
        end
        add_dialogue("\"Safe journeys, " .. var_0000 .. ".\"")
    elseif eventid == 0 then
        utility_unknown_1070(68) --- Guess: Triggers a game event
    end
end