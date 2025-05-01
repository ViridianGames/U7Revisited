-- Function 04C0: Menion's trainer dialogue and sword forging
function func_04C0(eventid, itemref)
    -- Local variables (5 as per .localc)
    local local0, local1, local2, local3, local4

    if eventid == 0 then
        call_092EH(-192)
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(192, 0)
    local0 = call_0909H()
    local1 = callis_001C(callis_001B(-192))
    local2 = callis_003B()
    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x0269) then
        say("The large, muscle-bound man smiles pleasantly at you.")
        set_flag(0x0269, true)
    else
        say("\"Greetings, ", local0, ",\" says Menion.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"I am Menion, ", local0, ".\" He shakes your hand.")
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("\"I am a trainer. I help warriors become bigger and stronger and better fighters. I also forge swords to match the strength in my students' arms.\"")
            _AddAnswer({"students", "forge", "train"})
        elseif answer == "students" then
            say("\"I have taught many a warrior how to use his -- or her -- force against an opponent.\"")
            _AddAnswer("force")
            _RemoveAnswer("students")
        elseif answer == "force" then
            say("\"Yes, ", local0, ". The key to effective fighting is striking hard and accurately at one's foe.\"")
            _AddAnswer({"accurately", "hard"})
            _RemoveAnswer("force")
        elseif answer == "hard" then
            say("\"Physical strength permits the attacker a better chance of penetrating the other fighter's armour. Obviously, in a lethal combat, that is an important objective.\"")
            _RemoveAnswer("hard")
        elseif answer == "accurately" then
            say("\"Needless to say, some targets on an individual are better than others. 'Tis always best to hit something that will either seriously incapacitate one's foe, or create enough pain to distract him.\"")
            _RemoveAnswer("accurately")
        elseif answer == "train" then
            if local1 == 7 then
                say("\"I will train thee for 45 gold. Wilt thou pay?\"")
                if not call_090AH() then
                    call_08BEH(45, 4, {0, 0})
                else
                    say("\"Fine.\"")
                end
            else
                say("\"Perhaps this would be a more appropriate topic when I am at work.\"")
            end
        elseif answer == "forge" then
            say("\"Dost thou wish to make a sword?\"")
            if local2 == 3 or local2 == 4 or local2 == 5 then
                local3 = call_090AH()
                if not local3 then
                    say("\"Perhaps sometime when thou hast more time.\"")
                else
                    say("He smiles. \"I would be very happy to show thee the steps necessary to create a very fine blade.\" He quickly jots down a few things on a scroll and turns to give it to you.*")
                    local4 = callis_002C(true, 13, -359, 797, 1)
                    if local4 then
                        say("\"May thy blade be sturdy and sharp!\"*")
                    else
                        say("\"Perhaps when thou hast fewer things to occupy thy pack, I can give this to thee.\"")
                    end
                end
            else
                say("\"I can help thee with that when I am at work.\"")
            end
            _RemoveAnswer("forge")
        elseif answer == "bye" then
            say("\"May the strength in thine arms always match the strength of thy will.\"*")
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