--- Best guess: Manages Cosmo's dialogue, a naive warrior in a dungeon seeking a unicorn to prove his virginity to his betrothed, Ophelia, with companions mocking his quest.
function npc_cosmo_0253(eventid, objectref)
    local var_0000, var_0001, var_0002

    if eventid == 1 then
        switch_talk_to(0, 253)
        var_0000 = get_lord_or_lady()
        var_0001 = npc_id_in_party(252)
        var_0002 = npc_id_in_party(244)
        start_conversation()
        add_answer({"bye", "job", "name"})
        if not get_flag(715) then
            add_dialogue("The wide-eyed expression of this youth seems indicative of his naivete.")
            set_flag(715, true)
        else
            add_dialogue("\"Why, hello there, " .. var_0000 .. ",\" says Cosmo.")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"I am Cosmo, " .. var_0000 .. ", betrothed of Ophelia.\"")
                set_flag(727, true)
                remove_answer("name")
                add_answer({"Ophelia", "betrothed"})
            elseif answer == "job" then
                add_dialogue("\"I am, uh, searching for something, " .. var_0000 .. ".\"")
                add_answer("searching")
            elseif answer == "betrothed" then
                add_dialogue("\"Aye, " .. var_0000 .. ", we are to be wed as soon I return to her silky arms.\"")
                if var_0002 then
                    add_dialogue("*")
                    switch_talk_to(0, 244)
                    add_dialogue("\"Oh, please!\" He rolls his eyes.")
                    hide_npc(244)
                    switch_talk_to(0, 253)
                end
                remove_answer("betrothed")
            elseif answer == "searching" then
                add_dialogue("\"Well, " .. var_0000 .. ", 'tis a bit of a personal matter.\"")
                if var_0002 then
                    add_dialogue("*")
                    switch_talk_to(0, 244)
                    add_dialogue("\"What he is searching for, " .. var_0000 .. ", is his virginity!\"")
                    switch_talk_to(0, 253)
                    add_dialogue("\"That is not true!\" He blushes.")
                    add_dialogue("\"I am looking for a way to -prove-... my virginity!\"")
                    hide_npc(244)
                    add_answer("proof")
                end
                add_answer("personal")
                remove_answer("searching")
            elseif answer == "personal" then
                add_dialogue("\"I would... rather... not discuss it, " .. var_0000 .. ",\" he stammers.")
                remove_answer("personal")
            elseif answer == "Ophelia" then
                add_dialogue("\"She is the most beautiful woman in all Britannia. I still find it hard to believe she has agreed to marry me, a lowly warrior. I will travel to the ends of the world for her, if that be necessary, to keep her heart!\"")
                remove_answer("Ophelia")
            elseif answer == "proof" then
                add_dialogue("He looks down at his feet. \"Milady Ophelia is concerned that I might not be... pure. I have waited mine entire life for someone like her. Can she not see that I held myself for marriage?\"")
                add_answer({"pure", "held"})
                remove_answer("proof")
            elseif answer == "held" then
                add_dialogue("\"Surely thou dost see the value in that, " .. var_0000 .. ". No woman would want me if I had not refrained from... well... thou dost understand.\"")
                remove_answer("held")
            elseif answer == "pure" then
                add_dialogue("\"I must prove to the lovely Ophelia that I am still a virgin. To do this I need to demonstrate that a unicorn will allow me to touch it. My friends and I are here to find such a creature, for recent legend purports that one lives in this dungeon.\"")
                set_flag(736, true)
                if not get_flag(720) then
                    add_answer("the unicorn said no")
                end
                remove_answer("pure")
            elseif answer == "the unicorn said no" then
                add_dialogue("\"Thou hast seen the unicorn?\" He frowns for a moment, but that quickly melts away.")
                add_dialogue("\"Nevertheless, I shall endeavor to seek it out. Nothing shall keep me from my beloved Ophelia.\"")
                remove_answer("the unicorn said no")
                set_flag(720, false)
            elseif answer == "bye" then
                add_dialogue("\"Good day, " .. var_0000 .. ". If thou dost see the unicorn, tell it to wait for me.\"")
                break
            end
        end
    elseif eventid == 0 then
        utility_unknown_0868()
    end
    return
end