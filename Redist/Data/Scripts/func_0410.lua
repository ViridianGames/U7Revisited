--- Best guess: Handles dialogue with Klog, the Trinsic Fellowship leader, discussing the Fellowship, a local murder, and suspicious activities revealed by the Cube, with investigative options.
function func_0410(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    start_conversation()
    if eventid == 1 then
        var_0000 = get_player_name()
        var_0001 = get_schedule() --- Guess: Checks game state or timer
        var_0002 = false
        var_0003 = check_inventory(359, 981, 1, 357)
        if var_0001 == 7 then
            unknown_08ABH() --- Guess: Checks Fellowship meeting status
        end
        add_answer({"bye", "murder", "job", "name"})
        if not get_flag(63) then
            add_answer({"test", "argument"})
            var_0002 = true
        end
        if not get_flag(67) then
            add_answer("Hook")
        end
        if not get_flag(62) then
            add_answer({"scroll", "medallion", "gold"})
        end
        if not get_flag(64) then
            add_answer("Crown Jewel")
        end
        switch_talk_to(16, 0)
        if not get_flag(79) then
            add_dialogue("This man exudes kindness and geniality. \"Ah, Avatar! I recognized thee at once! Word has moved through town quickly. I had heard thou wert here.\"")
            set_flag(79, true)
        else
            add_dialogue("\"Hello again, " .. var_0000 .. ",\" Klog asks. \"How may I help thee?\"")
        end
        while true do
            var_0001 = get_answer()
            if var_0001 == "name" then
                add_dialogue("\"My name is Klog.\"")
                remove_answer("name")
            elseif var_0001 == "job" then
                add_dialogue("\"I am the Trinsic branch leader for The Fellowship. I work here with my wife Ellen.\"")
                add_answer({"Ellen", "Fellowship"})
            elseif var_0001 == "murder" then
                if var_0003 then
                    add_dialogue("The Cube vibrates. \"Hook did a splendid job, did he not? Too bad I missed it. Had to keep up appearances and remain at home. Had to have an alibi.\"")
                else
                    add_dialogue("\"Well,\" the man says, reflecting, \"I was home all night, and my wife Ellen will certainly verify that. But, as we say in The Fellowship, 'Worthiness Precedes Reward'. Christopher must have done something bad. And the poor gargoyle Inamo! 'Tis a pity.\"")
                end
                remove_answer("murder")
                add_answer({"Inamo", "Christopher"})
            elseif var_0001 == "Fellowship" then
                if not get_flag(6) then
                    add_dialogue("\"The Fellowship meets here at the branch office in Trinsic every night at nine. Thou art welcome to attend.\"")
                    unknown_0919H() --- Guess: Explains Fellowship philosophy
                    add_answer("philosophy")
                else
                    add_dialogue("\"Why, thou shouldst know all about our little family by now!\"")
                end
                remove_answer("Fellowship")
            elseif var_0001 == "Ellen" then
                add_dialogue("\"She is my wife and bookkeeper for our branch.\"")
                remove_answer("Ellen")
            elseif var_0001 == "philosophy" then
                unknown_091AH() --- Guess: Provides detailed Fellowship information
                remove_answer("philosophy")
            elseif var_0001 == "Christopher" then
                add_dialogue("\"Christopher was a valued member of The Fellowship for some time. Unfortunately, we got into a petty argument last week.\"")
                remove_answer("Christopher")
                if not var_0002 then
                    add_answer("argument")
                end
            elseif var_0001 == "Inamo" then
                add_dialogue("\"I did not know the gargoyle. It sounds as if he was in the wrong place at the wrong time. 'Tis a pity.\"")
                remove_answer("Inamo")
            elseif var_0001 == "argument" then
                add_dialogue("\"Last week Christopher stated that he wanted to leave The Fellowship! Canst thou imagine? Well, we simply attempted to speak with him and alter his decision. The man verbally assaulted me and my companions with no provocation!\"")
                remove_answer("argument")
                add_answer("companions")
            elseif var_0001 == "test" then
                add_dialogue("\"Batlin in Britain will be happy to administer our test to thee. Thou shouldst certainly take it. Who knows? Thou mayest find something within thee that needs improving.\"")
                remove_answer("test")
            elseif var_0001 == "companions" then
                add_dialogue("\"They have gone to Fellowship Headquarters in Britain. They were here delivering Fellowship funds. Their names are Elizabeth and Abraham.\"")
                set_flag(65, true)
                remove_answer("companions")
            elseif var_0001 == "gold" then
                if var_0003 then
                    add_dialogue("The Cube vibrates. \"That was payment for delivery of the plans for the Black Gate pedestals.\"")
                    add_answer("Black Gate")
                else
                    add_dialogue("\"I do not know what thou art talking about.\"")
                end
                remove_answer("gold")
            elseif var_0001 == "Black Gate" then
                add_dialogue("\"All I know is that it is being built on the Isle of the Avatar.\"")
                remove_answer("Black Gate")
            elseif var_0001 == "medallion" then
                add_dialogue("\"Christopher had expressed interest in leaving The Fellowship. Perhaps he had stored it for safekeeping.\"")
                remove_answer("medallion")
            elseif var_0001 == "scroll" then
                if var_0003 then
                    add_dialogue("The Cube vibrates. \"Christopher received his reward prior to showing his worthiness. He reneged on delivery of the plans for the pedestal. It was merely a warning.\"")
                else
                    add_dialogue("\"I do not know anything about that.\"")
                end
                remove_answer("scroll")
            elseif var_0001 == "Crown Jewel" then
                if var_0003 then
                    add_dialogue("The Cube vibrates. \"That is Hook's ship.\"")
                else
                    add_dialogue("\"I do not know that ship.\"")
                end
                remove_answer("Crown Jewel")
            elseif var_0001 == "Hook" then
                if var_0003 then
                    add_dialogue("The Cube vibrates. \"He is the one who was assigned to kill Christopher. I do not know where he is now.\"")
                else
                    add_dialogue("\"I am afraid I do not know a man of that description.\"")
                end
                remove_answer("Hook")
            elseif var_0001 == "bye" then
                break
            end
        end
        add_dialogue("\"If there is anything else I may help thee with, " .. var_0000 .. ", let me know.\"")
    elseif eventid == 0 then
        unknown_092EH(16) --- Guess: Triggers a game event
    end
end