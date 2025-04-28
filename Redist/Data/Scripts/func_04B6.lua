require "U7LuaFuncs"
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

    _SwitchTalkTo(0, -182)
    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x0247) then
        say("You are greeted by a friendly gargoyle.")
        set_flag(0x0247, true)
    else
        say("\"To see you are doing well, human,\" says Inmanilem.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"To be called Inmanilem, human. To wish information about Terfin?\"")
            _AddAnswer({"Inmanilem", "information"})
            _RemoveAnswer("name")
        elseif answer == "Inmanilem" then
            say("\"To be Gargoyle for `make healed one.'\"")
            _RemoveAnswer("Inmanilem")
        elseif answer == "job" then
            say("\"To be the healer.\"")
            _AddAnswer("heal")
            if not get_flag(0x0244) then
                _AddAnswer("conflicts")
            end
        elseif answer == "heal" then
            local1 = callis_003B()
            if local1 == 2 or local1 == 3 or local1 == 4 or local1 == 5 then
                call_089DH(430, 10, 25)
            else
                say("\"To feel sorry, but to be busy with other things now. To ask you to come back when I have the time to heal you.\"")
            end
            _RemoveAnswer("heal")
        elseif answer == "information" then
            say("\"To tell you to seek out Draxinusom, human, or Forbrak. To have much information about Terfin.\"")
            _AddAnswer({"Terfin", "Forbrak", "Draxinusom"})
            _RemoveAnswer("information")
        elseif answer == "Forbrak" then
            say("\"To be the tavernkeeper. To be very strong of body, and of mind.\"")
            _RemoveAnswer("Forbrak")
        elseif answer == "Terfin" then
            say("\"To be the city of gargoyles. To be the one of two towns where many gargoyles live. To like it here,\" he adds, smiling.")
            _AddAnswer("one?")
            _RemoveAnswer("Terfin")
        elseif answer == "one?" then
            say("\"To tell you the other is called Vesper. To be in the desert in northeastern Britannia. To have also humans living there, unlike here.\"")
            _RemoveAnswer("one?")
        elseif answer == "Draxinusom" then
            say("\"To be our leader. To live near the Hall of Knowledge.\"")
            _AddAnswer("Hall")
            _RemoveAnswer("Draxinusom")
        elseif answer == "Hall" then
            say("\"To be where the three altars of singularity are kept.\"")
            _AddAnswer("altars")
            _RemoveAnswer("Hall")
        elseif answer == "altars" then
            say("\"To be Passion, Control, and Diligence. To be the values that most gargoyles hold as the key of our existence.\"")
            _AddAnswer({"key", "most gargoyles"})
            _RemoveAnswer("altars")
        elseif answer == "key" then
            say("He nods his head emphatically. \"To be quite similar to the human concept of virtues.\"")
            _RemoveAnswer("key")
        elseif answer == "most gargoyles" then
            say("\"There is a rival now -- The Fellowship. To know not if it is good or bad, but to know I do not follow it!\"")
            _RemoveAnswer("most gargoyles")
        elseif answer == "conflicts" then
            say("\"To know only of one dissatisfied gargoyle. To have always been problem, but now acting hostile and aggressive. To be named Silamo, the gardener.~~\"To recommend you talk to Silamo.\"")
            set_flag(0x023D, true)
            _RemoveAnswer("conflicts")
        elseif answer == "bye" then
            say("\"To wish you good health, human.\"*")
            break
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