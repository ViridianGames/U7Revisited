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
    add_answer({"bye", "job", "name"})

    if not get_flag(0x02CB) then
        add_dialogue("The wide-eyed expression of this youth seems indicative of his naivete.")
        set_flag(0x02CB, true)
    else
        add_dialogue("\"Why, hello there, ", local0, ",\" says Cosmo.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"I am Cosmo, ", local0, ", betrothed of Ophelia.\"")
            set_flag(0x02D7, true)
            remove_answer("name")
            add_answer({"Ophelia", "betrothed"})
        elseif answer == "job" then
            add_dialogue("\"I am, uh, searching for something, ", local0, ".\"")
            add_answer("searching")
        elseif answer == "betrothed" then
            add_dialogue("\"Aye, ", local0, ", we are to be wed as soon I return to her silky arms.\"")
            if local2 then
                add_dialogue("*")
                switch_talk_to(244, 0)
                add_dialogue("\"Oh, please!\" He rolls his eyes.*")
                _HideNPC(-244)
                switch_talk_to(253, 0)
            end
            remove_answer("betrothed")
        elseif answer == "searching" then
            add_dialogue("\"Well, ", local0, ", 'tis a bit of a personal matter.\"")
            if local2 then
                add_dialogue("*")
                switch_talk_to(244, 0)
                add_dialogue("\"What he is searching for, ", local0, ", is his virginity!\"*")
                switch_talk_to(253, 0)
                add_dialogue("\"That is not true!\" He blushes.~~\"I am looking for a way to -prove-... my virginity!\"*")
                _HideNPC(-244)
                add_answer("proof")
            end
            add_answer("personal")
            remove_answer("searching")
        elseif answer == "personal" then
            add_dialogue("\"I would... rather... not discuss it, ", local0, ",\" he stammers.")
            remove_answer("personal")
        elseif answer == "Ophelia" then
            add_dialogue("\"She is the most beautiful woman in all Britannia. I still find it hard to believe she has agreed to marry me, a lowly warrior. I will travel to the ends of the world for her, if that be necessary, to keep her heart!\"")
            remove_answer("Ophelia")
        elseif answer == "proof" then
            add_dialogue("He looks down at his feet. \"Milady Ophelia is concerned that I might not be... pure. I have waited mine entire life for someone like her. Can she not see that I held myself for marriage?\"")
            add_answer({"pure", "held"})
            remove_answer("proof")
        elseif answer == "held" then
            add_dialogue("\"Surely thou dost see the value in that, ", local0, ". No woman would want me if I had not refrained from... well... thou dost understand.\"")
            remove_answer("held")
        elseif answer == "pure" then
            add_dialogue("\"I must prove to the lovely Ophelia that I am still a virgin. To do this I need to demonstrate that a unicorn will allow me to touch it. My friends and I are here to find such a creature, for recent legend purports that one lives in this dungeon.\"")
            set_flag(0x02E0, true)
            if not get_flag(0x02D0) then
                add_answer("the unicorn said no")
            end
            remove_answer("pure")
        elseif answer == "the unicorn said no" then
            add_dialogue("\"Thou hast seen the unicorn?\" He frowns for a moment, but that quickly melts away.~~\"Nevertheless, I shall endeavor to seek it out. Nothing shall keep me from my beloved Ophelia.\"")
            remove_answer("the unicorn said no")
            set_flag(0x02D0, false)
        elseif answer == "bye" then
            add_dialogue("\"Good day, ", local0, ". If thou dost see the unicorn, tell it to wait for me.\"*")
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