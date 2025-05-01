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
    add_answer({"bye", "job", "name"})

    if not get_flag(0x0269) then
        add_dialogue("The large, muscle-bound man smiles pleasantly at you.")
        set_flag(0x0269, true)
    else
        add_dialogue("\"Greetings, ", local0, ",\" says Menion.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"I am Menion, ", local0, ".\" He shakes your hand.")
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("\"I am a trainer. I help warriors become bigger and stronger and better fighters. I also forge swords to match the strength in my students' arms.\"")
            add_answer({"students", "forge", "train"})
        elseif answer == "students" then
            add_dialogue("\"I have taught many a warrior how to use his -- or her -- force against an opponent.\"")
            add_answer("force")
            remove_answer("students")
        elseif answer == "force" then
            add_dialogue("\"Yes, ", local0, ". The key to effective fighting is striking hard and accurately at one's foe.\"")
            add_answer({"accurately", "hard"})
            remove_answer("force")
        elseif answer == "hard" then
            add_dialogue("\"Physical strength permits the attacker a better chance of penetrating the other fighter's armour. Obviously, in a lethal combat, that is an important objective.\"")
            remove_answer("hard")
        elseif answer == "accurately" then
            add_dialogue("\"Needless to say, some targets on an individual are better than others. 'Tis always best to hit something that will either seriously incapacitate one's foe, or create enough pain to distract him.\"")
            remove_answer("accurately")
        elseif answer == "train" then
            if local1 == 7 then
                add_dialogue("\"I will train thee for 45 gold. Wilt thou pay?\"")
                if not call_090AH() then
                    call_08BEH(45, 4, {0, 0})
                else
                    add_dialogue("\"Fine.\"")
                end
            else
                add_dialogue("\"Perhaps this would be a more appropriate topic when I am at work.\"")
            end
        elseif answer == "forge" then
            add_dialogue("\"Dost thou wish to make a sword?\"")
            if local2 == 3 or local2 == 4 or local2 == 5 then
                local3 = call_090AH()
                if not local3 then
                    add_dialogue("\"Perhaps sometime when thou hast more time.\"")
                else
                    add_dialogue("He smiles. \"I would be very happy to show thee the steps necessary to create a very fine blade.\" He quickly jots down a few things on a scroll and turns to give it to you.*")
                    local4 = callis_002C(true, 13, -359, 797, 1)
                    if local4 then
                        add_dialogue("\"May thy blade be sturdy and sharp!\"*")
                    else
                        add_dialogue("\"Perhaps when thou hast fewer things to occupy thy pack, I can give this to thee.\"")
                    end
                end
            else
                add_dialogue("\"I can help thee with that when I am at work.\"")
            end
            remove_answer("forge")
        elseif answer == "bye" then
            add_dialogue("\"May the strength in thine arms always match the strength of thy will.\"*")
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