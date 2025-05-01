-- Function 04D3: Lap-Lem's gargoyle miner dialogue and Blorn conflict
function func_04D3(eventid, itemref)
    -- Local variables (3 as per .localc)
    local local0, local1, local2

    if eventid == 0 then
        call_092FH(-211)
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(211, 0)
    _AddAnswer({"bye", "job", "name"})

    local0 = call_0931H(3, -359, 955, 1, -357)

    if not get_flag(0x0290) then
        say("You are greeted with a smile from this gargoyle.")
        set_flag(0x0290, true)
    else
        say("\"To be pleased to again see you, human.\" Lap-Lem smiles.")
    end

    if (get_flag(0x0281) or local0) and not get_flag(0x02DF) then
        _AddAnswer("give amulet")
    end
    if get_flag(0x0280) and not get_flag(0x02DF) then
        _AddAnswer("Blorn")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"To be known to you as Lap-Lem.\"")
            _AddAnswer("Lap-Lem")
            _RemoveAnswer("name")
            if get_flag(0x0280) and not get_flag(0x02DF) then
                _AddAnswer("Blorn")
            end
        elseif answer == "Lap-Lem" then
            say("\"To mean `rock one.'\"")
            _RemoveAnswer("Lap-Lem")
        elseif answer == "job" then
            say("\"To be a miner. To be now the only miner of my race in this town.\"")
            _AddAnswer({"town", "race", "only miner"})
        elseif answer == "race" then
            say("\"To know of many gargoyles who work in the other mines, but to see the Vesper mine has only humans now.\"")
            _RemoveAnswer("race")
        elseif answer == "town" then
            say("\"To be called Vesper. To be the only place, other than parts of Britain, where gargoyles live with humans. To tell you that here are more conflicts.\" He sighs.~~\"To wonder if Terfin would be a better choice to maintain a home.\"")
            _RemoveAnswer("town")
            _AddAnswer({"Terfin", "conflicts"})
        elseif answer == "conflicts" then
            say("\"To see the humans grow in hostility to us. Sadly, to also see many gargoyles begin to show mutual feelings. To hope the situation never becomes violent.\"")
            _RemoveAnswer("conflicts")
        elseif answer == "Terfin" then
            say("\"To be the gargoyle home city. To have been constructed two hundred years ago when the codex was placed in the void and the gargoyles were without places to live. Though not prohibited, no humans reside there.\"")
            _RemoveAnswer("Terfin")
        elseif answer == "only miner" then
            say("\"To tell you that there was another -- Anmanivas. To have left because of racial hatred. To sit now in tavern all day with brother, Foranamo. To feel bad for Anmanivas and brother, but to need job.\" He shrugs.~~ \"To put up with hatred.\"")
            _RemoveAnswer("only miner")
        elseif answer == "Blorn" then
            say("\"To know of incident?\"")
            local1 = call_090AH()
            if not local1 then
                say("\"To be very sorry for attack, but was in defense of possession.\" He lowers his head as if ashamed.")
            else
                say("\"To be ashamed. To want nothing more than return of my possession from human.\"")
            end
            _AddAnswer("possession")
            _RemoveAnswer("Blorn")
        elseif answer == "possession" then
            say("\"To have had an amulet with sentimental value. To have been stolen by the human.\" He looks down at his feet. \"To want it back.\"")
            _RemoveAnswer("possession")
            set_flag(0x0282, true)
        elseif answer == "give amulet" then
            say("\"To have returned with amulet?\"")
            local2 = callis_002B(false, 3, -359, 955, 1)
            if local2 then
                call_0911H(50)
                say("He grins widely as you return the jewelry to him.~~ \"To thank you, human! To be an example for your race!\"")
                set_flag(0x02DF, true)
            else
                say("\"Oh. To not have amulet with you.\" He perks up and smiles. \"To return later with amulet!\"")
            end
            _RemoveAnswer("give amulet")
        elseif answer == "bye" then
            say("\"To hope to see you again soon.\"*")
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