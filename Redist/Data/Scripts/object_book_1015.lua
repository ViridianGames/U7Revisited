--- Best guess: Manages a golem's dialogue in Moonglow, seeking a book or aiding a fallen golem, part of a quest.
function object_book_1015(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid == 1 then
        if not get_container_objects(4, 243, 797, objectref) then
            switch_talk_to(288)
            if not get_flag(808) then
                -- call [0000] (0893H, unmapped)
                utility_unknown_0915()
            end
            if not get_flag(796) then
                -- call [0001] (0892H, unmapped)
                utility_unknown_0914()
            end
            if not get_flag(799) then
                var_0000 = utility_unknown_1073(359, 144, 642, 1, 357)
                if not var_0000 then
                    start_conversation()
                    add_dialogue("\"Hast thou in thy possession the book on the Stone of Castambre?\"")
                    if ask_yes_no() then
                        add_dialogue("His eyes reveal his hope. As he takes the book from you, it almost appears as if he is smiling.")
                        -- call [0004] (0891H, unmapped)
                        utility_shop_0913()
                    else
                        add_dialogue("\"That is, indeed, a pity,\" he says, shaking his head in sadness.")
                    end
                end
            end
            if not get_flag(788) then
                start_conversation()
                add_dialogue("\"Greetings to thee, honorable one. I can but assume that my presence here was thy doing.\" It becomes quickly apparent that this creature possesses a greater capability for speech than his fallen companion.")
                if not get_flag(796) then
                    var_0001 = check_flag_location(0, 40, 414, 356)
                    while true do
                        var_0002 = var_0001
                        var_0003 = var_0002
                        var_0004 = var_0003
                        var_0005 = get_object_frame(var_0004)
                        if var_0005 == 4 or var_0005 == 5 then
                            add_dialogue("The recently raised golem stares down at the prone, lifeless body of Bollux. Quickly he looks up at you. \"Wh-what has happened?\"")
                            -- call [0005] (0890H, unmapped)
                            utility_unknown_0912()
                        end
                        if not var_0004 then
                            break
                        end
                    end
                else
                    add_dialogue("\"Now thou must excuse me, for I am off to find my fellow sentry.\"")
                    set_flag(788, true)
                    return
                end
            elseif get_flag(798) then
                start_conversation()
                add_dialogue("\"Hail, friend. I hope that I may assist thee in some way.\"")
                -- call [0005] (0890H, unmapped)
                utility_unknown_0912()
            else
                start_conversation()
                add_dialogue("\"Art thou here to aid me in healing my brother?\"")
                if ask_yes_no() then
                    add_dialogue("\"Very good. I am pleased to call thee friend.\"")
                    set_flag(798, true)
                    -- call [0005] (0890H, unmapped)
                    utility_unknown_0912()
                else
                    add_dialogue("\"Then begone, for I have work to do!\"")
                    return
                end
            end
        elseif get_container_objects(4, 244, 797, objectref) or check_flag_location(176, 1, 797, objectref) == 244 then
            -- call [0006] (0894H, unmapped)
            utility_shop_0916(objectref)
        end
    end
    return
end