-- Function 040B: Manages Petre's dialogue and interactions
function func_040B(itemref)
    -- Local variables (9 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8

    if eventid() == 1 then
        local0 = call_0909H()
        local1 = callis_0023()
        local2 = callis_005A()
        _AddAnswer({"bye", "job", "name"})
        _SwitchTalkTo(0, -11)
        if not get_flag(20) then
            if local2 then
                local3 = "woman"
            else
                local3 = "man"
            end
            say("The peasant looks at you as if he has seen a ghost! \"Iolo! This " .. local3 .. " did appear from thin air! Help me!\"")
            abort()
        end
        if not get_flag(75) then
            say("You see a distraught peasant. \"Art thou really the Avatar?\"")
            local4 = call_090AH()
            if local4 then
                say("Petre bows before you. \"^" .. local0 .. ".\"")
                set_flag(75, true)
                callis_001D(11, -11)
            else
                say("Petre looks confused. \"Thou shouldst not make fun of me!\" He turns away.")
                set_flag(75, true)
                abort()
            end
        else
            say("\"What is it, " .. local0 .. "?\" Petre asks.")
        end
        if not get_flag(60) then
            _AddAnswer({"footprints", "murder"})
        end
        if not get_flag(63) then
            _AddAnswer({"Spark", "Klog", "Fellowship"})
        end
        while true do
            if not get_flag(60) then
                say("\"Look in the stables! 'Tis horrible! I will answer thy questions, but first look in the stables!\"")
                abort()
            end
            if cmp_strings("name", 1) then
                say("\"I am called Petre,\" the man sniffs.")
                _RemoveAnswer("name")
            elseif cmp_strings("job", 1) then
                say("\"I am the stables caretaker.\"")
                _AddAnswer("stables")
            elseif cmp_strings("stables", 1) then
                say("\"I have worked here for years. I can sell thee a nice horse and carriage if thou dost want one. The animal and the carriage are located in a small shelter just outside the north gate of the town.\"")
                if not get_flag(87) then
                    say("\"Right now the place gives me the creeps!\"~~His eyes are wild with fright.")
                else
                    say("\"The Mayor did not let me clean in there until twenty-four hours after thou didst leave Trinsic. He thought we had to keep the place of the crime unsullied. Well, if thou dost ask me, I can tell thee that it still stinks like the end of the world in there!\"")
                end
                _RemoveAnswer("stables")
                _AddAnswer("carriage")
            elseif cmp_strings("murder", 1) then
                say("\"I discovered poor Christopher and Inamo earlier this morning. I did not touch a thing. Made me sick, it did!\"")
                _RemoveAnswer("murder")
                _AddAnswer({"Inamo", "Christopher"})
            elseif cmp_strings("Christopher", 1) then
                say("\"Nice man. He made the shoes for mine horses.\"")
                _RemoveAnswer("Christopher")
            elseif cmp_strings("Inamo", 1) then
                say("\"He worked for very little money. Did basic chores around the stables and the pub. I let him sleep in the little back room. He must have been in the wrong place at the wrong time.\"")
                _RemoveAnswer("Inamo")
            elseif cmp_strings("carriage", 1) then
                say("\"The horse and carriage combination sells for 60 gold. Dost thou want a title?\"")
                local5 = call_090AH()
                if local5 then
                    local6 = callis_0028(-359, -359, 644, -357)
                    if local6 >= 60 then
                        if not callis_002C(false, -359, 28, 797, 1) then
                            say("\"Very good. Nothing like a little business transaction to take my mind off the ghastly scene in the stables.\"")
                            callis_002B(true, -359, -359, 644, 60)
                        else
                            say("\"Oh, my. Thine hands are too full to take the title!\"")
                        end
                    else
                        say("\"Oh. Thou dost not have enough gold to buy the title.\"")
                    end
                else
                    say("\"Some other time, then.\"")
                end
                _RemoveAnswer("carriage")
            elseif cmp_strings("footprints", 1) then
                say("\"They doth lead out the back way, yes? They must be the tracks of the murderer!\"~~His eyes widen a bit more.~~\"Or... murderers!\"")
                _RemoveAnswer("footprints")
            elseif cmp_strings("Fellowship", 1) then
                say("\"I do not want to join them, but they seem all right.\"")
                _RemoveAnswer("Fellowship")
            elseif cmp_strings("Klog", 1) then
                say("\"I do not know the man too well. I have no dealings with him.\"")
                _RemoveAnswer("Klog")
            elseif cmp_strings("Spark", 1) then
                if -2 in local1 then
                    say("\"That be Christopher's son. Nice lad.\"")
                else
                    say("Petre ruffles the boy's hair.~~\"This here is Christopher's son. He's a good lad, is Spark, when he's not pilfering things from honest shopkeepers.\"")
                end
                _RemoveAnswer("Spark")
            elseif cmp_strings("bye", 1) then
                say("\"Goodbye,\" the man sniffs.")
                break
            end
        end
    elseif eventid() == 0 then
        call_092EH(-11)
    end
end

-- Helper functions
function eventid()
    return 0 -- Placeholder
end

function say(...)
    print(table.concat({...}))
end

function get_flag(id)
    return false -- Placeholder
end

function set_flag(id, value)
    -- Placeholder
end

function cmp_strings(str, count)
    return false -- Placeholder
end