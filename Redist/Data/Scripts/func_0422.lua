-- Manages Nanna's dialogue in Britain, covering Royal Nursery duties, class structure views, and Fellowship membership.
function func_0422(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6

    if eventid == 1 then
        switch_talk_to(-34, 0)
        local0 = get_schedule()
        local1 = switch_talk_to(-34)
        local2 = get_item_type()

        if local0 == 7 then
            local3 = apply_effect(-26, -34) -- Unmapped intrinsic 08FC
            if local3 then
                say("Nanna gives you a stern look for bothering her during The Fellowship meeting, much like the look of an elementary school teacher you once had.*")
            else
                if get_flag(218) then
                    say("\"I cannot imagine where Batlin may be. He has never missed a Fellowship meeting!\"")
                else
                    say("\"Oh! Hello! I must not stop to speak now. I am on my way to The Fellowship meeting!\"*")
                end
            end
            return
        end

        add_answer({"bye", "job", "name"})

        if not get_flag(163) then
            say("You see a working-class elderly woman who exudes sweetness.")
            set_flag(163, true)
        else
            say("\"Yes, may I help thee?\" Nanna asks.")
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                say("\"Oh, everyone simply calls me 'Nanna'.\"")
                remove_answer("name")
            elseif answer == "job" then
                say("\"I watch over the Royal Nursery. I am the nanny of these wonderful children.\"")
                add_answer({"children", "nanny", "Royal Nursery"})
            elseif answer == "Royal Nursery" then
                say("\"There have been a great number of babies born in Britannia in recent years, so Lord British established this nursery. It is nice that the noblemen and noblewomen have this luxury so that they may attend to their daily duties.\"")
                remove_answer("Royal Nursery")
                add_answer("luxury")
                if local1 == 7 then
                    local4 = get_item_type(-2)
                    if local4 then
                        switch_talk_to(-2, 0)
                        say("\"Whew! Dost thou smell what I smell, Avatar?\"*")
                        hide_npc(-2)
                    end
                    local5 = get_item_type(-1)
                    if local5 then
                        switch_talk_to(-1, 0)
                        say("\"I believe that is the smell of diapers, boy. When thou art a father one day, thou wilt come to know that smell quite well.\"*")
                        hide_npc(-1)
                    end
                    switch_talk_to(-34, 0)
                end
                remove_answer("Royal Nursery")
            elseif answer == "nanny" then
                say("\"Well, I feed them and change their diapers and read aloud all the books thou dost see lying around. Luckily, I have Sherry to help me.\"")
                remove_answer("nanny")
                add_answer({"Sherry", "books"})
            elseif answer == "books" then
                say("\"Lord British brought them from his homeland. They are very foreign to us here in Britannia, but the children enjoy them just the same.\"")
                remove_answer("books")
            elseif answer == "Sherry" then
                say("\"Sherry is a special mouse who has lived here in the castle for many, many years. She recites stories for the children.\"")
                remove_answer("Sherry")
            elseif answer == "children" then
                say("\"They are lovely, are they not? Every day they seem to learn more and more. Most of the time they are a joy.\" Nanna whispers to you conspiratorially, \"And other times I could happily throw them out with the bathwater!\"")
                local6 = check_item_state(-32)
                if local6 == 25 then
                    say("\"The children must be outside playing with Sherry now.\"")
                    add_answer("Sherry")
                end
                remove_answer("children")
            elseif answer == "luxury" then
                say("\"Yes, I suppose it really is a luxury. The poorer people in Britannia certainly do not have such a service for caring for their children. The rich do have an advantage.\" You detect a hint of bitterness in her voice.")
                remove_answer("luxury")
                add_answer("advantage")
            elseif answer == "advantage" then
                say("\"I do not mean to complain by any means. I adore my work. But contrary to the thinking of many of the noblemen and women, a class structure exists in Britannia more than ever before. Taxes are unbearable. The rich get richer, and the poor get poorer, as the saying goes.\"")
                remove_answer("advantage")
                add_answer({"taxes", "class structure"})
            elseif answer == "taxes" then
                say("\"The Britannian Tax Council drains us all dry. Especially the lower and middle classes.\"")
                remove_answer("taxes")
            elseif answer == "class structure" then
                say("\"Well, look around! There are rich men who live in opulent castles. And right outside are poor people who live in hovels. Thou dost know how there are winged gargoyles and wingless gargoyles? Well, it seems the human race is getting to be just as divided. There is no unity in the land anymore. It is why I have joined The Fellowship.\"")
                remove_answer("class structure")
                add_answer({"philosophy", "Fellowship"})
                set_flag(130, true)
            elseif answer == "Fellowship" then
                apply_effect() -- Unmapped intrinsic 0919
                remove_answer("Fellowship")
            elseif answer == "philosophy" then
                if local2 then
                    say("She notices your medallion. \"But thou dost know all that already!\"")
                else
                    say("\"Thou shouldst really come to a meeting. Thou wouldst learn a lot!\"")
                    apply_effect() -- Unmapped intrinsic 091A
                end
                remove_answer("philosophy")
            elseif answer == "bye" then
                say("\"Good day! Do come back and visit again soon!\"*")
                break
            end
        end
    elseif eventid == 0 then
        switch_talk_to(-34)
    end
    return
end