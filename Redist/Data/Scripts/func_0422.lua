--- Best guess: Handles dialogue with Nanna, the Royal Nursery caretaker, discussing her role, the children, and social issues like taxes and class structure, with Fellowship ties.
function func_0422(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006

    start_conversation()
    if eventid == 1 then
        switch_talk_to(34, 0)
        var_0000 = unknown_003BH() --- Guess: Checks game state or timer
        var_0001 = unknown_001CH(34) --- Guess: Gets object state
        var_0002 = unknown_0067H() --- Guess: Checks Fellowship membership
        if var_0000 == 7 then
            var_0003 = unknown_08FCH(26, 34) --- Guess: Checks time for Fellowship meeting
            if var_0003 then
                add_dialogue("Nanna gives you a stern look for bothering her during The Fellowship meeting, much like the look of an elementary school teacher you once had.")
            else
                if get_flag(218) then
                    add_dialogue("\"I cannot imagine where Batlin may be. He has never missed a Fellowship meeting!\"")
                else
                    add_dialogue("\"Oh! Hello! I must not stop to speak now. I am on my way to The Fellowship meeting!\"")
                end
            end
            abort()
        end
        add_answer({"bye", "job", "name"})
        if not get_flag(163) then
            add_dialogue("You see a working-class elderly woman who exudes sweetness.")
            set_flag(163, true)
        else
            add_dialogue("\"Yes, may I help thee?\" Nanna asks.")
        end
        while true do
            var_0004 = get_answer()
            if var_0004 == "name" then
                add_dialogue("\"Oh, everyone simply calls me 'Nanna'.\"")
                remove_answer("name")
            elseif var_0004 == "job" then
                add_dialogue("\"I watch over the Royal Nursery. I am the nanny of these wonderful children.\"")
                add_answer({"children", "nanny", "Royal Nursery"})
            elseif var_0004 == "Royal Nursery" then
                add_dialogue("\"There have been a great number of babies born in Britannia in recent years, so Lord British established this nursery. It is nice that the noblemen and noblewomen have this luxury so that they may attend to their daily duties.\"")
                remove_answer("Royal Nursery")
                add_answer("luxury")
                if var_0001 == 7 then
                    if var_0004 then
                        switch_talk_to(2, 0)
                        add_dialogue("\"Whew! Dost thou smell what I smell, Avatar?\"")
                        hide_npc(2)
                    end
                    var_0005 = unknown_08F7H(1) --- Guess: Checks player status
                    if var_0005 then
                        switch_talk_to(1, 0)
                        add_dialogue("\"I believe that is the smell of diapers, boy. When thou art a father one day, thou wilt come to know that smell quite well.\"")
                        hide_npc(1)
                    end
                    switch_talk_to(34, 0)
                end
                remove_answer("Royal Nursery")
            elseif var_0004 == "nanny" then
                add_dialogue("\"Well, I feed them and change their diapers and read aloud all the books thou dost see lying around. Luckily, I have Sherry to help me.\"")
                remove_answer("nanny")
                add_answer({"Sherry", "books"})
            elseif var_0004 == "books" then
                add_dialogue("\"Lord British brought them from his homeland. They are very foreign to us here in Britannia, but the children enjoy them just the same.\"")
                remove_answer("books")
            elseif var_0004 == "Sherry" then
                add_dialogue("\"Sherry is a special mouse who has lived here in the castle for many, many years. She recites stories for the children.\"")
                remove_answer("Sherry")
            elseif var_0004 == "children" then
                add_dialogue("\"They are lovely, are they not? Every day they seem to learn more and more. Most of the time they are a joy.\" Nanna whispers to you conspiratorially, \"And other times I could happily throw them out with the bathwater!\"")
                var_0006 = unknown_001CH(32) --- Guess: Gets object state
                if var_0006 == 25 then
                    add_dialogue("\"The children must be outside playing with Sherry now.\"")
                    add_answer("Sherry")
                end
                remove_answer("children")
            elseif var_0004 == "luxury" then
                add_dialogue("\"Yes, I suppose it really is a luxury. The poorer people in Britannia certainly do not have such a service for caring for their children. The rich do have an advantage.\" You detect a hint of bitterness in her voice.")
                remove_answer("luxury")
                add_answer("advantage")
            elseif var_0004 == "advantage" then
                add_dialogue("\"I do not mean to complain by any means. I adore my work. But contrary to the thinking of many of the noblemen and women, a class structure exists in Britannia more than ever before. Taxes are unbearable. The rich get richer, and the poor get poorer, as the saying goes.\"")
                remove_answer("advantage")
                add_answer({"taxes", "class structure"})
            elseif var_0004 == "taxes" then
                add_dialogue("\"The Britannian Tax Council drains us all dry. Especially the lower and middle classes.\"")
                remove_answer("taxes")
            elseif var_0004 == "class structure" then
                add_dialogue("\"Well, look around! There are rich men who live in opulent castles. And right outside are poor people who live in hovels. Thou dost know how there are winged gargoyles and wingless gargoyles? Well, it seems the human race is getting to be just as divided. There is no unity in the land anymore. It is why I have joined The Fellowship.\"")
                remove_answer("class structure")
                add_answer({"philosophy", "Fellowship"})
                set_flag(130, true)
            elseif var_0004 == "Fellowship" then
                unknown_0919H() --- Guess: Explains Fellowship philosophy
                remove_answer("Fellowship")
            elseif var_0004 == "philosophy" then
                if var_0002 then
                    add_dialogue("She notices your medallion. \"But thou dost know all that already!\"")
                else
                    add_dialogue("\"Thou shouldst really come to a meeting. Thou wouldst learn a lot!\"")
                    unknown_091AH() --- Guess: Provides detailed Fellowship information
                end
                remove_answer("philosophy")
            elseif var_0004 == "bye" then
                break
            end
        end
        add_dialogue("\"Good day! Do come back and visit again soon!\"")
    elseif eventid == 0 then
        unknown_092EH(34) --- Guess: Triggers a game event
    end
end