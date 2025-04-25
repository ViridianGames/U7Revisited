-- Manages Klog's dialogue in Trinsic, covering his Fellowship leadership, murder involvement (with Cube), and Christopher's argument.
function func_0410(eventid, itemref)
    local local0, local1, local2, local3

    if eventid == 1 then
        local0 = get_player_name()
        local1 = get_schedule()
        local2 = false
        local3 = has_item(-359, -359, 981, 1, -357)

        if local1 == 7 then
            apply_effect() -- Unmapped intrinsic 08AB
        end

        switch_talk_to(-16, 0)
        add_answer({"bye", "murder", "job", "name"})
        if not get_flag(63) then
            add_answer({"test", "argument"})
            local2 = true
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

        if not get_flag(79) then
            say("\"Ah, Avatar! I recognized thee at once! Word has moved through town quickly. I had heard thou wert here.\"")
            set_flag(79, true)
        else
            say("\"Hello again, " .. local0 .. ",\" Klog asks. \"How may I help thee?\"")
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                say("\"My name is Klog.\"")
                remove_answer("name")
            elseif answer == "job" then
                say("\"I am the Trinsic branch leader for The Fellowship. I work here with my wife Ellen.\"")
                add_answer({"Ellen", "Fellowship"})
            elseif answer == "murder" then
                if local3 then
                    say("The Cube vibrates. \"Hook did a splendid job, did he not? Too bad I missed it. Had to keep up appearances and remain at home. Had to have an alibi.\"")
                else
                    say("\"Well,\" the man says, reflecting, \"I was home all night, and my wife Ellen will certainly verify that. But, as we say in The Fellowship, 'Worthiness Precedes Reward'. Christopher must have done something bad. And the poor gargoyle Inamo! 'Tis a pity.\"")
                end
                remove_answer("murder")
                add_answer({"Inamo", "Christopher"})
            elseif answer == "Fellowship" then
                if not get_flag(6) then
                    say("\"The Fellowship meets here at the branch office in Trinsic every night at nine. Thou art welcome to attend.\"")
                    apply_effect() -- Unmapped intrinsic 0919
                    add_answer("philosophy")
                else
                    say("\"Why, thou shouldst know all about our little family by now!\"")
                end
                remove_answer("Fellowship")
            elseif answer == "Ellen" then
                say("\"She is my wife and bookkeeper for our branch.\"")
                remove_answer("Ellen")
            elseif answer == "philosophy" then
                apply_effect() -- Unmapped intrinsic 091A
                remove_answer("philosophy")
            elseif answer == "Christopher" then
                say("\"Christopher was a valued member of The Fellowship for some time. Unfortunately, we got into a petty argument last week.\"")
                remove_answer("Christopher")
                if not local2 then
                    add_answer("argument")
                end
            elseif answer == "Inamo" then
                say("\"I did not know the gargoyle. It sounds as if he was in the wrong place at the wrong time. 'Tis a pity.\"")
                remove_answer("Inamo")
            elseif answer == "argument" then
                say("\"Last week Christopher stated that he wanted to leave The Fellowship! Canst thou imagine? Well, we simply attempted to speak with him and alter his decision. The man verbally assaulted me and my companions with no provocation!\"")
                remove_answer("argument")
                add_answer("companions")
            elseif answer == "test" then
                say("\"Batlin in Britain will be happy to administer our test to thee. Thou shouldst certainly take it. Who knows? Thou mayest find something within thee that needs improving.\"")
                remove_answer("test")
            elseif answer == "companions" then
                say("\"They have gone to Fellowship Headquarters in Britain. They were here delivering Fellowship funds. Their names are Elizabeth and Abraham.\"")
                set_flag(65, true)
                remove_answer("companions")
            elseif answer == "gold" then
                if local3 then
                    say("The Cube vibrates. \"That was payment for delivery of the plans for the Black Gate pedestals.\"")
                    add_answer("Black Gate")
                else
                    say("\"I do not know what thou art talking about.\"")
                end
                remove_answer("gold")
            elseif answer == "Black Gate" then
                say("\"All I know is that it is being built on the Isle of the Avatar.\"")
                remove_answer("Black Gate")
            elseif answer == "medallion" then
                say("\"Christopher had expressed interest in leaving The Fellowship. Perhaps he had stored it for safekeeping.\"")
                remove_answer("medallion")
            elseif answer == "scroll" then
                if local3 then
                    say("The Cube vibrates. \"Christopher received his reward prior to showing his worthiness. He reneged on delivery of the plans for the pedestal. It was merely a warning.\"")
                else
                    say("\"I do not know anything about that.\"")
                end
                remove_answer("scroll")
            elseif answer == "Crown Jewel" then
                if local3 then
                    say("The Cube vibrates. \"That is Hook's ship.\"")
                else
                    say("\"I do not know that ship.\"")
                end
                remove_answer("Crown Jewel")
            elseif answer == "Hook" then
                if local3 then
                    say("The Cube vibrates. \"He is the one who was assigned to kill Christopher. I do not know where he is now.\"")
                else
                    say("\"I am afraid I do not know a man of that description.\"")
                end
                remove_answer("Hook")
            elseif answer == "bye" then
                say("\"If there is anything else I may help thee with, " .. local0 .. ", let me know.\"*")
                break
            end
        end
    elseif eventid == 0 then
        switch_talk_to(-16)
    end
    return
end