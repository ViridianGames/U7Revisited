--- Best guess: Handles dialogue with Gregor, head of the Minoc Fellowship and Britannian Mining Company, discussing Minoc’s trade, social changes, and the murders, with interruptions during Fellowship meetings or private moments with Elynor.
function func_0452(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    start_conversation()
    if eventid == 1 then
        switch_talk_to(82, 0)
        var_0000 = get_schedule() --- Guess: Checks game state or timer
        var_0001 = unknown_001CH(82) --- Guess: Gets object state
        if var_0000 == 7 then
            if var_0001 ~= 16 then
                add_dialogue("Gregor is busy concentrating on the Fellowship meeting and cannot talk now.")
                abort()
            end
        end
        var_0002 = unknown_08FCH(81, 82) --- Guess: Checks NPC time interaction
        if var_0002 then
            add_dialogue("\"No time for idle chatter! I must get to the Fellowship Meeting! I am late!\"")
            abort()
        end
        var_0003 = get_lord_or_lady()
        add_answer({"bye", "job", "name"})
        var_0004 = npc_id_in_party(81) --- Guess: Checks player status
        if var_0004 and var_0000 == 0 and var_0001 == 16 then
            add_answer("Elynor")
        end
        if not get_flag(269) then
            add_dialogue("You see an old man whose domineering disposition matches the hardened physique of his aged body.")
            set_flag(269, true)
        else
            add_dialogue("\"Art thou addressing me?\" Gregor scowls.")
        end
        while true do
            var_0005 = get_answer()
            if var_0005 == "name" then
                add_dialogue("\"My name is Gregor.\"")
                remove_answer("name")
            elseif var_0005 == "job" then
                if not get_flag(287) then
                    add_dialogue("\"I am in charge of the Minoc branch of the Britannian Mining Company.\"")
                    add_answer({"Britannian Mining Company", "Minoc"})
                else
                    add_dialogue("\"Art thou fevered, " .. var_0003 .. "? Dost thou not realize why we have gathered at this spot? 'Tis shameful, thine unaffected manner in the presence of such tragedy!\"")
                    set_flag(287, true)
                    add_answer("murders")
                end
            elseif var_0005 == "Minoc" then
                add_dialogue("\"Our town is a major center of trade in Britannia, and it is a place of social change.\"")
                remove_answer("Minoc")
                add_answer({"social change", "trade"})
            elseif var_0005 == "Britannian Mining Company" then
                add_dialogue("\"The Britannian Mining Company produces a wide variety of minerals that are essential to the continuation of progress in Britannia.\"")
                remove_answer("Britannian Mining Company")
            elseif var_0005 == "trade" then
                add_dialogue("\"Here in Minoc we have one of the largest mining operations in Britannia, a sawmill, an inn, the Artist's Guild, and a shipwright.\"")
                add_answer({"shipwright", "Artist's Guild", "inn", "sawmill"})
                remove_answer("trade")
            elseif var_0005 == "social change" then
                add_dialogue("\"Here in Minoc we are erecting a monument to our good shipwright Owen, a master craftsman whose name will soon be known throughout Britannia. We also have a very active Fellowship branch.\"")
                remove_answer("social change")
                add_answer({"Fellowship", "monument"})
            elseif var_0005 == "sawmill" then
                add_dialogue("\"A long-standing and profitable business. A shame it will become more renowned for the murders that were committed there than for any of the fine work it does.\"")
                remove_answer("sawmill")
            elseif var_0005 == "inn" then
                add_dialogue("\"The Checquered Cork is famous for its rustic character and atmosphere. It is a fine place. Do not be put off by its apparent uncleanliness.\"")
                remove_answer("inn")
            elseif var_0005 == "Artist's Guild" then
                add_dialogue("\"The Artist's Guild is a small collection of craftspeople who have huddled together to sell their little trinkets. They pride themselves on being the local dissenters of everything.\"")
                remove_answer("Artist's Guild")
            elseif var_0005 == "shipwright" then
                add_dialogue("\"I may have already mentioned Owen, the shipwright. He builds the finest ships that have ever set sail.\"")
                remove_answer("shipwright")
            elseif var_0005 == "monument" then
                add_dialogue("\"I helped to organize things with Mayor Burnside to get the monument built.\"")
                if not get_flag(247) then
                    add_dialogue("\"It will be huge and made of the finest ore from our mine.\"")
                end
                remove_answer("monument")
            elseif var_0005 == "Fellowship" then
                add_dialogue("\"They have done immeasurable good for Minoc, helping to counter the disunity that can plague a town such as ours where so many people are fixated upon monetary gain.\"")
                remove_answer("Fellowship")
            elseif var_0005 == "murders" then
                add_dialogue("\"It is terrible! The gypsies Frederico and Tania have been found murdered in William's sawmill!\"")
                remove_answer("murders")
            elseif var_0005 == "Elynor" then
                add_dialogue("\"Leave us in peace, damn thee! Elynor and I are in love and we wish to be alone together! Find thy cheap excitations elsewhere!\"")
                remove_answer("Elynor")
            elseif var_0005 == "bye" then
                break
            end
        end
        add_dialogue("\"Be on thy way then.\"")
    elseif eventid == 0 then
        unknown_092EH(82) --- Guess: Triggers a game event
    end
end