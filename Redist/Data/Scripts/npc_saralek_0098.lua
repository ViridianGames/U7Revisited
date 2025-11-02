--- Best guess: Handles dialogue with Saralek, an Emp female in the Silverleaf tree, discussing her family, Trellek's desire to join the party, and the need for Salamon's permission. Includes a wisps whistle suggestion.
function npc_saralek_0098(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    start_conversation()
    if eventid == 1 then
        var_0000 = utility_unknown_1073(359, 359, 772, 1, 357) --- Guess: Checks inventory items
        switch_talk_to(98)
        if not get_flag(340) then
            if not var_0000 then
                add_dialogue("The creature ignores you.")
                abort()
            end
            utility_unknown_0992() --- Guess: Checks Emp interaction
        end
        if not get_flag(317) then
            if not get_flag(316) then
                add_dialogue("The ape-like female appears nervous.")
                set_flag(316, true)
                set_flag(317, true)
            else
                add_dialogue("The female Emp appears nervous.")
                set_flag(317, true)
            end
        else
            var_0001 = false
            add_dialogue("Saralek greets you. \"Hello is said to you, human.\"")
            if not get_flag(306) then
                add_answer("Trellek")
            end
        end
        if get_flag(305) and not get_flag(344) then
            add_answer("Salamon's permission")
        end
        add_answer({"bye", "job", "name"})
        while true do
            var_0002 = get_answer()
            if var_0002 == "name" then
                add_dialogue("She shies away for a moment, and then cautiously steps forward. \"I am called Saralek.\"")
                remove_answer("name")
                if get_flag(306) and not var_0001 then
                    add_answer("Trellek")
                end
            elseif var_0002 == "job" then
                add_dialogue("\"`Job' is not understood. Family is what you mean?\"")
                add_answer("family")
            elseif var_0002 == "family" then
                add_dialogue("\"Yes, I am part of a family. The Silverleaf tree is my home. I am bonded with Trellek.\"")
                remove_answer("family")
                add_answer({"Trellek", "Silverleaf tree"})
            elseif var_0002 == "Trellek" then
                add_dialogue("\"Trellek is my husband.\"")
                var_0001 = true
                if not get_flag(304) then
                    add_dialogue("\"Trellek has been met by you?\" She smiles proudly, and takes another step forward. \"What was said by him?\"")
                    add_answer("join party")
                end
                remove_answer("Trellek")
            elseif var_0002 == "Silverleaf tree" then
                add_dialogue("\"There are fewer and fewer Silverleaf trees. Many are cut down often. Soon, no Silverleaf trees will be around for our homes.\"")
                add_answer("cut down")
                remove_answer("Silverleaf tree")
            elseif var_0002 == "cut down" then
                add_dialogue("\"The trees are cut by a human with a shiny, sharp item.\"")
                remove_answer("cut down")
            elseif var_0002 == "join party" then
                add_dialogue("\"To join you is his desire?\"")
                var_0003 = select_option()
                if var_0003 then
                    add_dialogue("She thinks for a moment. \"His going away is not desired by me.\" She turns to look directly at you. \"But, joining you may be wise action.\" She sighs.")
                    add_dialogue("\"Permission from Salamon must be gained first. Then permission from me will be granted. Your return to me is necessary for that.\"")
                    set_flag(304, true)
                    add_answer("Salamon")
                else
                    add_dialogue("\"That is good!\" She seems very happy and relieved.")
                end
                remove_answer("join party")
            elseif var_0002 == "Salamon" then
                add_dialogue("\"She is a very wise Emp. Many humans have been met by her. Knowledge and experience are her talents.\"")
                remove_answer("Salamon")
            elseif var_0002 == "Salamon's permission" then
                add_dialogue("Her eyes begin to mist over.")
                add_dialogue("\"I am sorry. A lie was told by me. Trellek's leaving is not desired by me. Permission will not be given.\"")
                add_dialogue("\"What is the reason you asked him?\"")
                add_answer({"never mind", "adventure"})
                if not get_flag(312) then
                    add_answer("wisps")
                end
                set_flag(344, true)
                remove_answer("Salamon's permission")
            elseif var_0002 == "adventure" then
                add_dialogue("\"Adventure is not Trellek's desire.\"")
                remove_answer("adventure")
            elseif var_0002 == "never mind" then
                add_dialogue("She shrugs.")
                remove_answer("never mind")
            elseif var_0002 == "wisps" then
                add_dialogue("She smiles excitedly.")
                add_dialogue("\"Your wish is to meet wisps?\"")
                var_0003 = select_option()
                if var_0003 then
                    add_dialogue("\"An idea how you can be helped by Trellek is had by me. Wisps are contacted by Trellek's whistling. A whistle for you can be made by him, perhaps. Talking with him again should be your next action.\"")
                    set_flag(341, true)
                else
                    add_dialogue("\"Oh.\" She appears depressed again.")
                end
                remove_answer({"wisps", "never mind", "adventure"})
            elseif var_0002 == "bye" then
                break
            end
        end
        add_dialogue("\"Goodbye is said to you, human.\"")
    elseif eventid == 0 then
        abort()
    end
end