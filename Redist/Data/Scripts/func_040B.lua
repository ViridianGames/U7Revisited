--- Best guess: Manages Petre’s dialogue, covering the Trinsic murder, stables, and horse sales, with flag-based progression.
function func_040B(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    if eventid ~= 1 then
        if eventid == 0 then
            unknown_092EH(-11)
        end
        add_dialogue("\"Goodbye,\" the man sniffs.")
        return
    end

    start_conversation()
    var_0000 = get_lord_or_lady()
    var_0001 = get_party_members()
    var_0002 = is_player_female()
    switch_talk_to(11, 0)
    if not get_flag(20) then
        var_0003 = var_0002 and "woman" or "man"
        add_dialogue("The peasant looks at you as if he has seen a ghost! \"Iolo! This " .. var_0003 .. " did appear from thin air! Help me!\"")
        return
    end
    if not get_flag(75) then
        --add_dialogue("You see a distraught peasant. \"Art thou really the Avatar?\"")
        var_0004 = ask_yes_no("You see a distraught peasant. \"Art thou really the Avatar?\"")
        if var_0004 then
            add_dialogue("Petre bows before you. \"" .. var_0000 .. ".\"")
            set_flag(75, true)
            --unknown_001DH(11, -11)
        else
            add_dialogue("Petre looks confused. \"Thou shouldst not make fun of me!\" He turns away.")
            set_flag(75, true)
            abort()
        end
    else
        add_dialogue("\"What is it, " .. var_0000 .. "?\" Petre asks.")
    end
    add_answer({"bye", "job", "name"})
    if not get_flag(60) then
        add_answer({"footprints", "murder"})
    end
    if not get_flag(63) then
        add_answer({"Spark", "Klog", "Fellowship"})
    end
    while true do
        if not get_flag(60) then
            add_dialogue("\"Look in the stables! 'Tis horrible! I will answer thy questions, but first look in the stables!\"")
            return
        end
        local answer = get_answer()
        if answer == "name" then
            add_dialogue("\"I am called Petre,\" the man sniffs.")
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("\"I am the stables caretaker.\"")
            add_answer("stables")
        elseif answer == "stables" then
            add_dialogue("\"I have worked here for years. I can sell thee a nice horse and carriage if thou dost want one. The animal and the carriage are located in a small shelter just outside the north gate of the town.\"")
            if not get_flag(87) then
                add_dialogue("\"Right now the place gives me the creeps!\"")
                add_dialogue("His eyes are wild with fright.")
            else
                add_dialogue("\"The Mayor did not let me clean in there until twenty-four hours after thou didst leave Trinsic. He thought we had to keep the place of the crime unsullied. Well, if thou dost ask me, I can tell thee that it still stinks like the end of the world in there!\"")
            end
            remove_answer("stables")
            add_answer("carriage")
        elseif answer == "murder" then
            add_dialogue("\"I discovered poor Christopher and Inamo earlier this morning. I did not touch a thing. Made me sick, it did!\"")
            remove_answer("murder")
            add_answer({"Inamo", "Christopher"})
        elseif answer == "Christopher" then
            add_dialogue("\"Nice man. He made the shoes for mine horses.\"")
            remove_answer("Christopher")
        elseif answer == "Inamo" then
            add_dialogue("\"He worked for very little money. Did basic chores around the stables and the pub. I let him sleep in the little back room. He must have been in the wrong place at the wrong time.\"")
            remove_answer("Inamo")
        elseif answer == "carriage" then
            add_dialogue("\"The horse and carriage combination sells for 60 gold. Dost thou want a title?\"")
            var_0005 = ask_yes_no()
            if var_0005 then
                var_0006 = unknown_0028H(59, 359, 644, 357)
                if var_0006 >= 60 then
                    var_0007 = unknown_002CH(false, 359, 28, 797, 1)
                    if var_0007 then
                        add_dialogue("\"Very good. Nothing like a little business transaction to take my mind off the ghastly scene in the stables.\"")
                        var_0008 = unknown_002BH(359, 359, 644, 60)
                    else
                        add_dialogue("\"Oh, my. Thine hands are too full to take the title!\"")
                    end
                else
                    add_dialogue("\"Oh. Thou dost not have enough gold to buy the title.\"")
                end
            else
                add_dialogue("\"Some other time, then.\"")
            end
            remove_answer("carriage")
        elseif answer == "footprints" then
            add_dialogue("\"They doth lead out the back way, yes? They must be the tracks of the murderer!\"")
            add_dialogue("His eyes widen a bit more.")
            add_dialogue("\"Or... murderers!\"")
            remove_answer("footprints")
        elseif answer == "Fellowship" then
            add_dialogue("\"I do not want to join them, but they seem all right.\"")
            remove_answer("Fellowship")
        elseif answer == "Klog" then
            add_dialogue("\"I do not know the man too well. I have no dealings with him.\"")
            remove_answer("Klog")
        elseif answer == "Spark" then
            if -2 == var_0001 then
                add_dialogue("\"That be Christopher's son. Nice lad.\"")
            else
                add_dialogue("Petre ruffles the boy's hair.")
                add_dialogue("\"This here is Christopher's son. He's a good lad, is Spark, when he's not pilfering things from honest shopkeepers.\"")
            end
            remove_answer("Spark")
        elseif answer == "bye" then
            break
        end
    end
    return
end