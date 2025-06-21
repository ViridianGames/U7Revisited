--- Best guess: Manages Cairbre’s dialogue in a cavern, a sell-sword accompanying Cosmo on a quest to find a unicorn, skeptical of Cosmo’s motives and Ophelia’s intentions.
function func_04F4(eventid, objectref)
    local var_0000, var_0001, var_0002

    if eventid == 1 then
        switch_talk_to(0, 244)
        var_0000 = npc_id_in_party(253)
        var_0001 = npc_id_in_party(252)
        var_0002 = get_lord_or_lady()
        start_conversation()
        add_answer({"bye", "job", "name"})
        if not get_flag(712) then
            add_dialogue("The warrior carries himself with confidence.")
            set_flag(712, true)
        else
            add_dialogue("\"Hail, " .. var_0002 .. ",\" says Cairbre.")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"Thou mayest call me Cairbre, " .. var_0002 .. ".\"")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"I am a sell-sword. But at the moment, I am trying to help my friend regain his senses.\"")
                remove_answer("job")
                add_answer({"senses", "friend"})
            elseif answer == "friend" then
                add_dialogue("\"I was not about to let Cosmo venture down here by himself. So, I offered to accompany him, as did Kallibrus.\"")
                if var_0001 then
                    add_dialogue("He points to the gargoyle.")
                else
                    add_answer("Kallibrus")
                end
                remove_answer("friend")
            elseif answer == "Kallibrus" then
                add_dialogue("\"He is a comrade in arms of mine, and also a friend of Cosmo's. I have yet to meet a more trustworthy companion, for he more than disproves all the rumors about gargoyles.\"")
                remove_answer("Kallibrus")
            elseif answer == "senses" then
                add_dialogue("\"'Tis a long story. Cosmo is looking for the unicorn that supposedly inhabits this cavern.\" He looks you in the eye and shrugs.")
                add_dialogue("\"He is a fool.\"")
                if var_0000 then
                    add_dialogue("*")
                    switch_talk_to(0, 253)
                    add_dialogue("\"I heard that, Cairbre!\"")
                    hide_npc(253)
                    switch_talk_to(0, 244)
                end
                set_flag(736, true)
                remove_answer("senses")
                add_answer({"fool", "unicorn"})
            elseif answer == "unicorn" then
                add_dialogue("\"The unicorn is traditionally a way to prove the purity of a young maiden. However, less commonly known is that it will also reveal a young man's, uh, lack of, um, wild oats.\"")
                remove_answer("unicorn")
            elseif answer == "fool" then
                add_dialogue("\"Ophelia does not love him! She simply sent him on this quest to be rid of him. I doubt she expects him to find the unicorn, let alone return to her.\"")
                remove_answer("fool")
                add_answer({"rid", "Ophelia"})
            elseif answer == "Ophelia" then
                add_dialogue("\"He met her in Jhelom. She was serving in the Bunk and Stool. Apparently it was `love at first sight,' as he calls it.\"")
                remove_answer("Ophelia")
            elseif answer == "rid" then
                add_dialogue("\"The nature of her request is quite ironic, for I would expect that the unicorn would have shunned her quite some time ago. He is not to her tastes, I would imagine, and, were he to truly know her, she would not be to his. But, alas, love is blind, as they say.\"")
                add_answer("they")
                remove_answer("rid")
            elseif answer == "they" then
                add_dialogue("\"I do not know who `they' are, but that is what they say, is it not?\"")
                remove_answer("they")
            elseif answer == "bye" then
                add_dialogue("\"'Til next time, " .. var_0002 .. ".\"")
                break
            end
        end
    elseif eventid == 0 then
        unknown_085BH()
    end
    return
end