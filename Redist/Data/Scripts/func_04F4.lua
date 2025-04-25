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

    _SwitchTalkTo(0, -244)
    local0 = call_08F7H(-253)
    local1 = call_08F7H(-252)
    local2 = call_0909H()
    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x02C8) then
        say("The warrior carries himself with confidence.")
        set_flag(0x02C8, true)
    else
        say("\"Hail, ", local2, ",\" says Cairbre.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"Thou mayest call me Cairbre, ", local2, ".\"")
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("\"I am a sell-sword. But at the moment, I am trying to help my friend regain his senses.\"")
            _RemoveAnswer("job")
            _AddAnswer({"senses", "friend"})
        elseif answer == "friend" then
            say("\"I was not about to let Cosmo venture down here by himself. So, I offered to accompany him, as did Kallibrus.\"")
            if local1 then
                say("He points to the gargoyle.")
                _AddAnswer("Kallibrus")
            end
            _RemoveAnswer("friend")
        elseif answer == "Kallibrus" then
            say("\"He is a comrade in arms of mine, and also a friend of Cosmo's. I have yet to meet a more trustworthy companion, for he more than disproves all the rumors about gargoyles.\"")
            _RemoveAnswer("Kallibrus")
        elseif answer == "senses" then
            say("\"'Tis a long story. Cosmo is looking for the unicorn that supposedly inhabits this cavern.\" He looks you in the eye and shrugs.~~\"He is a fool.\"")
            if local0 then
                say("*")
                _SwitchTalkTo(0, -253)
                say("\"I heard that, Cairbre!\"*")
                _HideNPC(-253)
                _SwitchTalkTo(0, -244)
            end
            set_flag(0x02E0, true)
            _RemoveAnswer("senses")
            _AddAnswer({"fool", "unicorn"})
        elseif answer == "unicorn" then
            say("\"The unicorn is traditionally a way to prove the purity of a young maiden. However, less commonly known is that it will also reveal a young man's, uh, lack of, um, wild oats.\"")
            _RemoveAnswer("unicorn")
        elseif answer == "fool" then
            say("\"Ophelia does not love him! She simply sent him on this quest to be rid of him. I doubt she expects him to find the unicorn, let alone return to her.\"")
            _RemoveAnswer("fool")
            _AddAnswer({"rid", "Ophelia"})
        elseif answer == "Ophelia" then
            say("\"He met her in Jhelom. She was serving in the Bunk and Stool. Apparently it was 'love at first sight,' as he calls it.\"")
            _RemoveAnswer("Ophelia")
        elseif answer == "rid" then
            say("\"The nature of her request is quite ironic, for I would expect that the unicorn would have shunned her quite some time ago. He is not to her tastes, I would imagine, and, were he to truly know her, she would not be to his. But, alas, love is blind, as they say.\"")
            _AddAnswer("they")
            _RemoveAnswer("rid")
        elseif answer == "they" then
            say("\"I do not know who 'they' are, but that is what they say, is it not?\"")
            _RemoveAnswer("they")
        elseif answer == "bye" then
            say("\"'Til next time, ", local2, ".\"*")
            return
        end
    end

    return
end

-- Helper functions
function say(...)
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