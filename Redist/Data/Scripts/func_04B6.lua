-- Function 04B6: Inmanilem's healer dialogue
function func_04B6(eventid, itemref)
    -- Local variables (2 as per .localc)
    local local0, local1

    if eventid == 0 then
        call_092FH(-182)
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(182, 0)
    add_answer({"bye", "job", "name"})

    if not get_flag(0x0247) then
        add_dialogue("You are greeted by a friendly gargoyle.")
        set_flag(0x0247, true)
    else
        add_dialogue("\"To see you are doing well, human,\" says Inmanilem.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"To be called Inmanilem, human. To wish information about Terfin?\"")
            add_answer({"Inmanilem", "information"})
            remove_answer("name")
        elseif answer == "Inmanilem" then
            add_dialogue("\"To be Gargoyle for `make healed one.'\"")
            remove_answer("Inmanilem")
        elseif answer == "job" then
            add_dialogue("\"To be the healer.\"")
            add_answer("heal")
            if not get_flag(0x0244) then
                add_answer("conflicts")
            end
        elseif answer == "heal" then
            local1 = callis_003B()
            if local1 == 2 or local1 == 3 or local1 == 4 or local1 == 5 then
                call_089DH(430, 10, 25)
            else
                add_dialogue("\"To feel sorry, but to be busy with other things now. To ask you to come back when I have the time to heal you.\"")
            end
            remove_answer("heal")
        elseif answer == "information" then
            add_dialogue("\"To tell you to seek out Draxinusom, human, or Forbrak. To have much information about Terfin.\"")
            add_answer({"Terfin", "Forbrak", "Draxinusom"})
            remove_answer("information")
        elseif answer == "Forbrak" then
            add_dialogue("\"To be the tavernkeeper. To be very strong of body, and of mind.\"")
            remove_answer("Forbrak")
        elseif answer == "Terfin" then
            add_dialogue("\"To be the city of gargoyles. To be the one of two towns where many gargoyles live. To like it here,\" he adds, smiling.")
            add_answer("one?")
            remove_answer("Terfin")
        elseif answer == "one?" then
            add_dialogue("\"To tell you the other is called Vesper. To be in the desert in northeastern Britannia. To have also humans living there, unlike here.\"")
            remove_answer("one?")
        elseif answer == "Draxinusom" then
            add_dialogue("\"To be our leader. To live near the Hall of Knowledge.\"")
            add_answer("Hall")
            remove_answer("Draxinusom")
        elseif answer == "Hall" then
            add_dialogue("\"To be where the three altars of singularity are kept.\"")
            add_answer("altars")
            remove_answer("Hall")
        elseif answer == "altars" then
            add_dialogue("\"To be Passion, Control, and Diligence. To be the values that most gargoyles hold as the key of our existence.\"")
            add_answer({"key", "most gargoyles"})
            remove_answer("altars")
        elseif answer == "key" then
            add_dialogue("He nods his head emphatically. \"To be quite similar to the human concept of virtues.\"")
            remove_answer("key")
        elseif answer == "most gargoyles" then
            add_dialogue("\"There is a rival now -- The Fellowship. To know not if it is good or bad, but to know I do not follow it!\"")
            remove_answer("most gargoyles")
        elseif answer == "conflicts" then
            add_dialogue("\"To know only of one dissatisfied gargoyle. To have always been problem, but now acting hostile and aggressive. To be named Silamo, the gardener.~~\"To recommend you talk to Silamo.\"")
            set_flag(0x023D, true)
            remove_answer("conflicts")
        elseif answer == "bye" then
            add_dialogue("\"To wish you good health, human.\"*")
            break
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