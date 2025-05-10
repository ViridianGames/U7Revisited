--- Best guess: Manages Quaeven’s dialogue in Terfin, a Fellowship member running the Recreation Facility and Learning Center, recruiting Betra.
function func_04BA(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 1 then
        switch_talk_to(0, 186)
        var_0000 = unknown_003BH()
        var_0001 = false
        start_conversation()
        add_answer({"bye", "Fellowship", "job", "name"})
        if var_0000 == 7 then
            var_0002 = unknown_08FCH(185, 186)
            if var_0002 then
                add_dialogue("\"To have not the time to speak now. To talk after meeting.\"")
            else
                add_dialogue("\"To have not the time to speak now. To hurry to Fellowship meeting.\"")
            end
            return
        end
        if not get_flag(587) then
            add_dialogue("The gargoyle, a contented grin on his face, greets you with a handshake.")
            set_flag(587, true)
        else
            add_dialogue("\"To express happiness at your return,\" says Quaeven.")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"To be known as Quaeven, human.\"")
                remove_answer("name")
                add_answer("Quaeven")
            elseif answer == "Quaeven" then
                add_dialogue("\"To mean `problem finder.' To be an observant one.\"")
                remove_answer("Quaeven")
            elseif answer == "job" then
                add_dialogue("\"To be master of the Recreation Facility and Learning Center. To be in charge of much information valuable to the gargoyle race.\"")
                add_answer({"Learning Center", "Recreation Facility"})
            elseif answer == "Recreation Facility" then
                add_dialogue("\"To be a good place for gargoyles to go to exercise their muscles. To have many resources available, including stuffed bags to punch and practice fighting skills.\"")
                remove_answer("Recreation Facility")
            elseif answer == "Learning Center" then
                add_dialogue("\"To be located in the same building as the Recreation Center. To provide an excellent atmosphere for strengthening gargoyle minds. To have a large supply of books and educational material.\"")
                remove_answer("Learning Center")
            elseif answer == "Fellowship" then
                var_0003 = unknown_0067H()
                if var_0003 then
                    add_dialogue("\"To be a member, too.\" He holds up his medallion. To have needed The Fellowship to become happy.\"")
                    add_answer("needed The Fellowship")
                else
                    add_dialogue("\"To want to know about the organization or the tenets?\"")
                    add_answer("organization")
                    if var_0001 then
                        add_answer("tenets")
                    end
                end
                remove_answer("Fellowship")
            elseif answer == "organization" then
                add_dialogue("\"To be a group of spiritual seekers striving to reach the highest levels of gargoyle potential. To share with all gargoyles and humans.\"")
                add_answer("share")
                remove_answer("organization")
            elseif answer == "share" then
                add_dialogue("\"To share tenets and material well-being.\"")
                add_answer("material well-being")
                if var_0001 then
                    add_answer("tenets")
                end
                remove_answer("share")
            elseif answer == "material well-being" then
                add_dialogue("\"To support financially and personally a poorhouse in Paws. To organize feasts and festivals in Britannia to help morale. To be a much needed group by all gargoyles and men. To have needed The Fellowship myself!\"")
                add_answer("needed The Fellowship")
                remove_answer("material well-being")
            elseif answer == "tenets" then
                add_dialogue("\"To apply an optimistic order of thought through the Triad of Inner Strength.\"")
                add_answer("Triad")
                set_flag(574, true)
                remove_answer("tenets")
            elseif answer == "Triad" then
                add_dialogue("\"To be the three concepts of Strive for Unity, Trust your Brother, and Worthiness Precedes Reward.\"")
                remove_answer("Triad")
            elseif answer == "needed The Fellowship" then
                add_dialogue("\"To have had poor life before The Fellowship. To have been pained, ignored, and mistreated by many.\"")
                add_dialogue("\"To be happy now in my new life and, to hope to hear the voice soon.\" His eyes widen in excitement. \"To be bringing happiness to another's life soon.\"")
                add_answer({"another", "voice"})
                remove_answer("needed The Fellowship")
            elseif answer == "voice" then
                add_dialogue("\"To be a good voice that will help me make choices, and to help win on Buccaneer's Den.\"")
                remove_answer("voice")
            elseif answer == "another" then
                add_dialogue("He continues on, excitedly.")
                add_dialogue("\"To be working on my first convert. To know the joy and well-being I will bring. To feel content and happy.\"")
                add_answer({"convert", "working"})
                remove_answer("another")
            elseif answer == "working" then
                add_dialogue("\"To need a little more persuasion,\" he looks down, \"but to be almost ready to join!\"")
                remove_answer("working")
            elseif answer == "convert" then
                add_dialogue("\"To be Betra, the provisioner. To feel confident he will join soon.\"")
                remove_answer("convert")
            elseif answer == "bye" then
                add_dialogue("\"To hope for your well-being and happiness.\"")
                break
            end
        end
    elseif eventid == 0 then
        unknown_092FH(186)
    end
    return
end