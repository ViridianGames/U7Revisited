--- Best guess: Handles dialogue with Zelda, the Lycaeum advisor in Moonglow, discussing her role, the library, and her feelings for Brion and Nelson, including a romance quest.
function npc_zelda_0152(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    start_conversation()
    if eventid == 1 then
        switch_talk_to(152)
        var_0000 = get_player_name() --- Guess: Gets player info
        var_0001 = get_lord_or_lady()
        var_0002 = false
        var_0003 = is_player_female()
        add_answer({"bye", "job", "name"})
        if not get_flag(506) then
            add_dialogue("You see a woman who meets your gaze with an icy stare.")
            set_flag(506, true)
        else
            add_dialogue("\"What dost thou need now?\"")
            if not get_flag(475) then
                add_answer("Brion's feelings")
            end
            if not get_flag(476) then
                add_answer("Nelson's feelings")
            end
        end
        while true do
            var_0004 = get_answer()
            if var_0004 == "name" then
                add_dialogue("\"I am Zelda.\"")
                remove_answer("name")
                if not get_flag(475) then
                    add_answer("Brion's feelings")
                end
                if not get_flag(476) then
                    add_answer("Nelson's feelings")
                end
            elseif var_0004 == "job" then
                add_dialogue("\"I am the advisor at the Lycaeum.\"")
                add_answer({"advisor", "Lycaeum"})
                if not get_flag(502) then
                    add_answer("North East sea")
                end
            elseif var_0004 == "Lycaeum" then
                add_dialogue("She rolls her eyes. \"The Lycaeum is the building in which thou dost stand. It is a great library designed to house a wealth of knowledge. Though the structure has changed a bit over the past two hundred years, the essence of learning has not.\"")
                remove_answer("Lycaeum")
            elseif var_0004 == "advisor" then
                add_dialogue("\"Yes,\" she says. \"My job is to manage and regulate the events in the Lycaeum. And,\" she adds, \"provide assistance to the people here in Moonglow -- when they need it!\"")
                remove_answer("advisor")
                add_answer({"townspeople", "events"})
            elseif var_0004 == "events" then
                add_dialogue("\"I am in charge of maintaining the reading areas and bringing in new books. In addition, I help organize special group sessions for Jillian's tutorials and set up educational entertainment programs.\"")
                remove_answer("events")
                if not var_0002 then
                    add_answer("Jillian")
                end
            elseif var_0004 == "North East sea" then
                add_dialogue("\"I have not the time for these petty geography questions. Check an atlas!\"")
                remove_answer("North East sea")
            elseif var_0004 == "townspeople" then
                add_dialogue("\"I have little time for this,\" she sighs. \"I know only the Lycaeum head and his twin, Brion, at all well. The trainer also studies here in the Lycaeum.\" She looks up at the ceiling, as if reading from an invisible, overhead list.")
                add_dialogue("\"Thou dost already know about Penumbra. Mariah is here. If thou wishest to know about a member of The Fellowship, ask the clerk there. Otherwise,\" she eyes you coldly, \"let me return to my duties.\" As an afterthought, she adds, \"And keep thy voice down. People are trying to read.\"")
                add_answer({"Penumbra", "Brion", "Lycaeum head", "Mariah"})
                if not var_0002 then
                    add_answer("trainer")
                end
                remove_answer("townspeople")
            elseif var_0004 == "Mariah" then
                add_dialogue("\"Well, they say she used to be an adept mage, but all I see is a woman who wanders around complimenting the furniture. Thou mayest speak to her if thou wishest, but I doubt she will make sense to thee. And do not disorganize the shelves while looking for her!\"")
                remove_answer("Mariah")
            elseif var_0004 == {"trainer", "Jillian"} then
                add_dialogue("\"Jillian? She is very well-behaved. Also quiet and tidy. I believe she is an excellent scholar. If thou art going to seek her out, try not to overturn any shelves. Some new books have just arrived and I have not finished placing all of them.\"")
                remove_answer({"trainer", "Jillian"})
                var_0002 = true
                add_answer("new books")
            elseif var_0004 == "new books" then
                add_dialogue("\"Yes, they arrived not long ago, including the recently rediscovered copy of DeMaria and Spector's work,`The Avatar Adventures.' If thou canst avoid creating too much of a disturbance, I recommend it to thee.\"")
                remove_answer("new books")
                add_answer("Avatar Adventures")
            elseif var_0004 == "Avatar Adventures" then
                add_dialogue("\"If I tell thee this last thing, wilt thou depart so I may return to my job?\"")
                if var_0003 then
                    var_0005 = "her"
                else
                    var_0005 = "his"
                end
                var_0006 = select_option()
                if var_0006 then
                    add_dialogue("\"We discovered the tome in the lower depths of the basement. We have no way to account for the accuracy of the contents, but have noticed many parallels between the events in the work and the events in Britannia's recent history.\"")
                    add_dialogue("\"The book is a copy of the Avatar's diary, written about two hundred years ago during " .. var_0005 .. " most recent visit to Britannia. Of course,\" she smiles sardonically, \"it has been annotated by others.\"")
                    add_dialogue("\"It was recently published to give the general public more courage and confidence.\"")
                    add_dialogue("\"And now, goodbye.\"")
                    abort()
                else
                    add_dialogue("\"Fine.\"")
                    abort()
                end
            elseif var_0004 == "Penumbra" then
                if var_0003 then
                    var_0007 = "she"
                else
                    var_0007 = "he"
                end
                add_dialogue("She shakes her head, muttering, \"Why doth " .. var_0007 .. " waste my time in this manner?\" Looking back up at you, she says, \"Penumbra is the sage who put herself to sleep two centuries ago. Rumor has it that only the Avatar can awaken her.\"")
                remove_answer("Penumbra")
            elseif var_0004 == "Lycaeum head" then
                add_dialogue("\"Nelson is very competent, although a little eccentric. I do wish he would refrain from showing off his collection of trinkets to everyone who enters the building. It always makes such a commotion.\"")
                remove_answer("Lycaeum head")
            elseif var_0004 == "Brion" then
                add_dialogue("Her chilly expression melts away. \"Brion,\" she says, smiling, \"is very open-minded and idealistic. He knows the heavens quite well.\" She looks up to emphasize `heavens.' \"I find him very attractive. But, I do not know how to convey mine intentions.\" She turns away, shyly.")
                add_dialogue("\"Unless, perchance, " .. var_0001 .. " wilt aid me?\" she asks, hopefully. \"Wilt thou agree to tell him for me, " .. var_0001 .. "?\"")
                var_0008 = select_option()
                if var_0008 then
                    add_dialogue("\"Thank thee, " .. var_0001 .. ". Thank thee.\" She blushes.")
                    var_0009 = add_party_items(0, 6, 359, 340, 1) --- Guess: Deducts item and checks inventory
                    if var_0009 then
                        add_dialogue("\"For thy kindness, I will give thee this white potion I found once while straightening the basement.\"")
                    end
                    set_flag(474, true)
                    remove_answer("Brion")
                else
                    add_dialogue("Her cold glare returns. \"Very well.\"")
                    abort()
                end
            elseif var_0004 == "Brion's feelings" then
                add_dialogue("She looks down for a moment. \"I thought as much.\" As she raises her head, tears are visible in her eyes. \"I thank thee for trying.\"")
                abort()
            elseif var_0004 == "Nelson's feelings" then
                add_dialogue("\"Nelson? I never really thought about him.\" She shrugs. \"Hmm, I suppose he is not a bad second best. I will try,\" she says, smiling.")
                set_flag(483, true)
                utility_unknown_1041(20) --- Guess: Triggers quest event
                remove_answer("Nelson's feelings")
                if not get_flag(474) then
                    add_answer("second best?")
                end
            elseif var_0004 == "second best?" then
                add_dialogue("\"Well, his brother, Brion, is quite attractive, I think.\"")
                remove_answer("second best?")
            elseif var_0004 == "bye" then
                break
            end
        end
        add_dialogue("\"Good day.\"")
    elseif eventid == 0 then
        abort()
    end
end