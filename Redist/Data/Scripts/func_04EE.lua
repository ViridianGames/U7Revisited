--- Best guess: Manages Perrin’s dialogue in Empath Abbey, a scholar offering training in knowledge and magic, studying undertakers like Tiery, and discussing local landmarks.
function func_04EE(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 1 then
        switch_talk_to(0, 238)
        var_0000 = unknown_0908H()
        var_0001 = get_lord_or_lady()
        start_conversation()
        add_answer({"bye", "job", "name"})
        if not get_flag(325) then
            add_dialogue("The man before you stretches and inhales deeply.")
        else
            add_dialogue("\"Glorious day, " .. var_0000 .. ".\" Perrin grins.")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"Please, " .. var_0001 .. ", call me Perrin. I reside here in Empath Abbey.\"")
                remove_answer("name")
                add_answer("Empath Abbey")
            elseif answer == "job" then
                add_dialogue("\"I am a scholar, " .. var_0001 .. ". Dost thou want training in the realm of books?\"")
                var_0002 = ask_yes_no()
                if var_0002 then
                    add_dialogue("\"My price is 45 gold for each training session, but I will also teach thee what little I know about magic. Is this acceptable?\"")
                    var_0003 = ask_yes_no()
                    if var_0003 then
                        unknown_08CAH(45, {6, 2})
                    else
                        add_dialogue("\"Very well, " .. var_0001 .. ".\"")
                    end
                else
                    add_dialogue("\"Forgive me, I am a bit overzealous in my search for students. I hope thou wilt return in the future.\"")
                end
            elseif answer == "Empath Abbey" then
                add_dialogue("\"This is a pleasant location. I like the privacy, which gives me a chance to study when I need to. The Brotherhood is across the road, and I am near a healer. Also, I have begun a study on the effects of dealing with death for undertakers. I am using Tiery as a case study.\"")
                add_answer({"Tiery", "healer", "Brotherhood"})
                remove_answer("Empath Abbey")
            elseif answer == "Brotherhood" then
                add_dialogue("\"That is the abbey. The monks who reside there are famous for their ability to produce exquisite wine. Nearby is the Highcourt and a prison.\"")
                remove_answer("Brotherhood")
                add_answer({"prison", "highcourt", "wine"})
            elseif answer == "wine" then
                add_dialogue("\"Thou shouldst try some. The monks have been making it for more than three hundred years!\"")
                remove_answer("wine")
            elseif answer == "highcourt" then
                add_dialogue("\"The official there is named Sir Jeff. From what I hear, he runs his ship very tight. I do not envy the jailer that works with him. It must be extremely difficult to be near such a strict disciplinarian all day long.\"")
                remove_answer("highcourt")
            elseif answer == "prison" then
                add_dialogue("\"It is located just behind the court. And,\" he grins, \"I am proud to say that is at least one thing about which I know nothing.\"")
                remove_answer("prison")
            elseif answer == "Tiery" then
                add_dialogue("\"He is the undertaker who lives just north of the Brotherhood.\"")
                remove_answer("Tiery")
            elseif answer == "healer" then
                add_dialogue("\"I have yet to meet her, but I know she loves animals. I have seen her playing with the deer and squirrels that inhabit this region.\"")
                remove_answer("healer")
                set_flag(315, true)
            elseif answer == "bye" then
                add_dialogue("\"Goodbye, " .. var_0000 .. ". Best of luck in thy journeys.\"")
                break
            end
        end
    elseif eventid == 0 then
        unknown_092EH(238)
    end
    return
end