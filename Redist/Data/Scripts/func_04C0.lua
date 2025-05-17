--- Best guess: Manages Menion’s dialogue in Serpent’s Hold, a trainer and swordsmith offering combat training and forging instructions.
function func_04C0(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    if eventid == 1 then
        switch_talk_to(0, 192)
        var_0000 = get_lord_or_lady()
        var_0001 = unknown_001CH(unknown_001BH(192))
        var_0002 = get_schedule()
        start_conversation()
        add_answer({"bye", "job", "name"})
        if not get_flag(617) then
            add_dialogue("The large, muscle-bound man smiles pleasantly at you.")
            set_flag(617, true)
        else
            add_dialogue("\"Greetings, \" .. var_0000 .. \",\" says Menion.")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"I am Menion, \" .. var_0000 .. \".\" He shakes your hand.")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"I am a trainer. I help warriors become bigger and stronger and better fighters. I also forge swords to match the strength in my students' arms.\"")
                add_answer({"students", "forge", "train"})
            elseif answer == "students" then
                add_dialogue("\"I have taught many a warrior how to use his -- or her -- force against an opponent.\"")
                remove_answer("students")
                add_answer("force")
            elseif answer == "force" then
                add_dialogue("\"Yes, \" .. var_0000 .. \". The key to effective fighting is striking hard and accurately at one's foe.\"")
                remove_answer("force")
                add_answer({"accurately", "hard"})
            elseif answer == "hard" then
                add_dialogue("\"Physical strength permits the attacker a better chance of penetrating the other fighter's armour. Obviously, in a lethal combat, that is an important objective.\"")
                remove_answer("hard")
            elseif answer == "accurately" then
                add_dialogue("\"Needless to say, some targets on an individual are better than others. 'Tis always best to hit something that will either seriously incapacitate one's foe, or create enough pain to distract him.\"")
                remove_answer("accurately")
            elseif answer == "train" then
                if var_0001 == 7 then
                    add_dialogue("\"I will train thee for 45 gold. Wilt thou pay?\"")
                    if unknown_090AH() then
                        unknown_08BEH(45, 4, 0)
                    else
                        add_dialogue("\"Fine.\"")
                    end
                else
                    add_dialogue("\"Perhaps this would be a more appropriate topic when I am at work.\"")
                end
            elseif answer == "forge" then
                add_dialogue("\"Dost thou wish to make a sword?\"")
                if var_0002 == 3 or var_0002 == 4 or var_0002 == 5 then
                    var_0003 = unknown_090AH()
                    if not var_0003 then
                        add_dialogue("\"Perhaps sometime when thou hast more time.\"")
                    else
                        add_dialogue("He smiles. \"I would be very happy to show thee the steps necessary to create a very fine blade.\" He quickly jots down a few things on a scroll and turns to give it to you.")
                        var_0004 = unknown_002CH(true, 0, 13, 797, 1)
                        if var_0004 then
                            add_dialogue("\"May thy blade be sturdy and sharp!\"")
                        else
                            add_dialogue("\"Perhaps when thou hast fewer things to occupy thy pack, I can give this to thee.\"")
                        end
                    end
                else
                    add_dialogue("\"I can help thee with that when I am at work.\"")
                end
                remove_answer("forge")
            elseif answer == "bye" then
                add_dialogue("\"May the strength in thine arms always match the strength of thy will.\"")
                break
            end
        end
    elseif eventid == 0 then
        unknown_092EH(192)
    end
    return
end