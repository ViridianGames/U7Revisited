-- Function 04D0: Blorn's gargoyle-hating dialogue and Lap-Lem feud
function func_04D0(eventid, itemref)
    -- Local variables (5 as per .localc)
    local local0, local1, local2, local3, local4

    if eventid == 0 then
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(208, 0)
    local0 = call_0909H()
    add_answer({"bye", "job", "name"})

    if not get_flag(0x028D) then
        add_dialogue("The man before you narrows his eyes to slits as he sees you.")
        set_flag(0x028D, true)
    else
        add_dialogue("Blorn sighs heavily. \"Why dost thou bother me now?\"")
        if get_flag(0x0283) and not get_flag(0x0280) then
            add_answer("gargoyles")
        end
    end

    if not get_flag(0x0281) then
        set_flag(0x0282, false)
        set_flag(0x0299, false)
    end

    if get_flag(0x0282) then
        add_answer("Lap-Lem")
    elseif not get_flag(0x0299) then
        add_answer("return amulet")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"Blorn, if thou must know.\"")
            remove_answer("name")
            if get_flag(0x0283) and not get_flag(0x0280) then
                add_answer("gargoyles")
            end
        elseif answer == "job" then
            add_dialogue("\"I don't believe I wish to tell thee.\"")
        elseif answer == "gargoyles" then
            add_dialogue("A growl escapes his throat.~~\"What about the bloody gargoyles? Don't tell me thou art a gargoyle lover.\"")
            local1 = call_090AH()
            if local1 then
                add_dialogue("\"Thou art disgusting, swine!\" He spits on your boot.*")
                return
            else
                add_dialogue("\"That is good, my friend.\"~~A sudden inspiration seems to flash across his face.~~\"Perhaps thou canst help me. As thou undoubtedly knowest, I was set upon by a cruel gargoyle not too long ago. He nearly took my life!~~'Twould be a great honor, ", local0, ", if thou wouldst agree to avenge me! Art thou willing?\"")
                local2 = call_090AH()
                if local2 then
                    add_dialogue("\"I thank thee, ", local0, ", thank thee. But I must warn thee, he is a very violent gargoyle. His name is Lap-Lem, which means `man slayer.' And, do not mention my name, for he hates me more than any other human and would surely attack thee without provocation if my name were to be mentioned.\"")
                    set_flag(0x0299, true)
                else
                    add_dialogue("\"Fine, ", local0, ". Thou art nothing more than a coward.\" He shakes his head.")
                end
                set_flag(0x0280, true)
            end
            remove_answer("gargoyles")
        elseif answer == "return amulet" then
            add_dialogue("He glares at you for a moment, then shrugs, muttering, \"It's not like he earned it honestly or anything...\"")
            local3 = callis_002C(true, 3, -359, 955, 1)
            if local3 then
                add_dialogue("\"Here! I hope it strangles him!\" He thrusts the amulet into your palm. \"And I hope he bloody strangles thee, too!\"")
                set_flag(0x0281, true)
            else
                add_dialogue("\"Thou dost not even have room for it! Get thee away, thou son of a jackal!\"*")
                return
            end
            remove_answer("return amulet")
        elseif answer == "Lap-Lem" then
            add_dialogue("\"Thou hast killed the jackal?\"")
            local4 = call_090AH()
            if local4 then
                add_dialogue("\"Wonderful! Thou art truly a trusted friend. I thank thee for thine assistance!\" He grins at you.")
            else
                add_dialogue("\"Well, I am sure thou wilt have time soon enough, for he will surely head this way to attack me again.\"")
            end
            remove_answer("Lap-Lem")
        elseif answer == "bye" then
            add_dialogue("He gives a slight nod and a quiet grunt, and returns to his business.*")
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