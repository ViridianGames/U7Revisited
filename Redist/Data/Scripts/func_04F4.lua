-- Function 04F4: Cairbre's sell-sword dialogue and unicorn quest
function func_04F4(eventid, itemref)
    -- Local variables (3 as per .localc)
    local local0, local1, local2

    if eventid == 0 then
        call_085BH()
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(244, 0)
    local0 = call_08F7H(-253)
    local1 = call_08F7H(-252)
    local2 = call_0909H()
    add_answer({"bye", "job", "name"})

    if not get_flag(0x02C8) then
        add_dialogue("The warrior carries himself with confidence.")
        set_flag(0x02C8, true)
    else
        add_dialogue("\"Hail, ", local2, ",\" says Cairbre.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"Thou mayest call me Cairbre, ", local2, ".\"")
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("\"I am a sell-sword. But at the moment, I am trying to help my friend regain his senses.\"")
            remove_answer("job")
            add_answer({"senses", "friend"})
        elseif answer == "friend" then
            add_dialogue("\"I was not about to let Cosmo venture down here by himself. So, I offered to accompany him, as did Kallibrus.\"")
            if local1 then
                add_dialogue("He points to the gargoyle.")
                add_answer("Kallibrus")
            end
            remove_answer("friend")
        elseif answer == "Kallibrus" then
            add_dialogue("\"He is a comrade in arms of mine, and also a friend of Cosmo's. I have yet to meet a more trustworthy companion, for he more than disproves all the rumors about gargoyles.\"")
            remove_answer("Kallibrus")
        elseif answer == "senses" then
            add_dialogue("\"'Tis a long story. Cosmo is looking for the unicorn that supposedly inhabits this cavern.\" He looks you in the eye and shrugs.~~\"He is a fool.\"")
            if local0 then
                add_dialogue("*")
                switch_talk_to(253, 0)
                add_dialogue("\"I heard that, Cairbre!\"*")
                _HideNPC(-253)
                switch_talk_to(244, 0)
            end
            set_flag(0x02E0, true)
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
            add_dialogue("\"He met her in Jhelom. She was serving in the Bunk and Stool. Apparently it was 'love at first sight,' as he calls it.\"")
            remove_answer("Ophelia")
        elseif answer == "rid" then
            add_dialogue("\"The nature of her request is quite ironic, for I would expect that the unicorn would have shunned her quite some time ago. He is not to her tastes, I would imagine, and, were he to truly know her, she would not be to his. But, alas, love is blind, as they say.\"")
            add_answer("they")
            remove_answer("rid")
        elseif answer == "they" then
            add_dialogue("\"I do not know who 'they' are, but that is what they say, is it not?\"")
            remove_answer("they")
        elseif answer == "bye" then
            add_dialogue("\"'Til next time, ", local2, ".\"*")
            return
        end
    end

    return
end

-- Helper functions
function add_dialogue(...)
    print(table.concat({...}))
end

function wait_for_answer()
    return "bye" -- Placeholder
end

function get_flag(flag)
    return false -- Placeholder
end

function set_flag(flag, value)
    -- Placeholder
end