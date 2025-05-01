-- Function 04FD: Cosmo's dialogue and virginity quest
function func_04FD(eventid, itemref)
    -- Local variables (3 as per .localc)
    local local0, local1, local2

    if eventid == 0 then
        call_0864H()
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(253, 0)
    local0 = call_0909H()
    local1 = call_08F7H(-252)
    local2 = call_08F7H(-244)
    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x02CB) then
        say("The wide-eyed expression of this youth seems indicative of his naivete.")
        set_flag(0x02CB, true)
    else
        say("\"Why, hello there, ", local0, ",\" says Cosmo.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"I am Cosmo, ", local0, ", betrothed of Ophelia.\"")
            set_flag(0x02D7, true)
            _RemoveAnswer("name")
            _AddAnswer({"Ophelia", "betrothed"})
        elseif answer == "job" then
            say("\"I am, uh, searching for something, ", local0, ".\"")
            _AddAnswer("searching")
        elseif answer == "betrothed" then
            say("\"Aye, ", local0, ", we are to be wed as soon I return to her silky arms.\"")
            if local2 then
                say("*")
                switch_talk_to(244, 0)
                say("\"Oh, please!\" He rolls his eyes.*")
                _HideNPC(-244)
                switch_talk_to(253, 0)
            end
            _RemoveAnswer("betrothed")
        elseif answer == "searching" then
            say("\"Well, ", local0, ", 'tis a bit of a personal matter.\"")
            if local2 then
                say("*")
                switch_talk_to(244, 0)
                say("\"What he is searching for, ", local0, ", is his virginity!\"*")
                switch_talk_to(253, 0)
                say("\"That is not true!\" He blushes.~~\"I am looking for a way to -prove-... my virginity!\"*")
                _HideNPC(-244)
                _AddAnswer("proof")
            end
            _AddAnswer("personal")
            _RemoveAnswer("searching")
        elseif answer == "personal" then
            say("\"I would... rather... not discuss it, ", local0, ",\" he stammers.")
            _RemoveAnswer("personal")
        elseif answer == "Ophelia" then
            say("\"She is the most beautiful woman in all Britannia. I still find it hard to believe she has agreed to marry me, a lowly warrior. I will travel to the ends of the world for her, if that be necessary, to keep her heart!\"")
            _RemoveAnswer("Ophelia")
        elseif answer == "proof" then
            say("He looks down at his feet. \"Milady Ophelia is concerned that I might not be... pure. I have waited mine entire life for someone like her. Can she not see that I held myself for marriage?\"")
            _AddAnswer({"pure", "held"})
            _RemoveAnswer("proof")
        elseif answer == "held" then
            say("\"Surely thou dost see the value in that, ", local0, ". No woman would want me if I had not refrained from... well... thou dost understand.\"")
            _RemoveAnswer("held")
        elseif answer == "pure" then
            say("\"I must prove to the lovely Ophelia that I am still a virgin. To do this I need to demonstrate that a unicorn will allow me to touch it. My friends and I are here to find such a creature, for recent legend purports that one lives in this dungeon.\"")
            set_flag(0x02E0, true)
            if not get_flag(0x02D0) then
                _AddAnswer("the unicorn said no")
            end
            _RemoveAnswer("pure")
        elseif answer == "the unicorn said no" then
            say("\"Thou hast seen the unicorn?\" He frowns for a moment, but that quickly melts away.~~\"Nevertheless, I shall endeavor to seek it out. Nothing shall keep me from my beloved Ophelia.\"")
            _RemoveAnswer("the unicorn said no")
            set_flag(0x02D0, false)
        elseif answer == "bye" then
            say("\"Good day, ", local0, ". If thou dost see the unicorn, tell it to wait for me.\"*")
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