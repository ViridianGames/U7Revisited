-- Function 04BC: Sarpling's shop dialogue and Runeb's plot revelation
function func_04BC(eventid, itemref)
    -- Local variables (5 as per .localc)
    local local0, local1, local2, local3, local4

    if eventid == 0 then
        call_092FH(-188)
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(188, 0)
    local0 = callis_003B()
    local1 = callis_001C(callis_001B(-188))

    if local0 == 7 then
        local2 = call_08FCH(-185, -188)
        if local2 then
            add_dialogue("The gargoyle is too involved with the Fellowship meeting to talk to you at this moment.*")
        else
            add_dialogue("\"To be unable to talk now. To see me after the Fellowship meeting.\" He continues on his way.*")
        end
        return
    end

    add_answer({"bye", "Fellowship", "job", "name"})
    local3 = true

    if not get_flag(0x024D) then
        add_dialogue("You see a very distraught gargoyle.")
        set_flag(0x024D, true)
    else
        add_dialogue("\"To give you greetings, human.\"")
    end

    if not get_flag(0x0250) then
        local3 = true
        if get_flag(0x0241) and not get_flag(0x0240) then
            add_answer("altar conflicts")
        end
        if not get_flag(0x023F) then
            add_answer("found note")
            remove_answer("altar conflicts")
        end
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"To be able to call me Sarpling.\"")
            set_flag(0x0250, true)
            remove_answer("name")
            if not local3 then
                if get_flag(0x0241) and not get_flag(0x0240) then
                    add_answer("altar conflicts")
                end
                if not get_flag(0x023F) then
                    add_answer("found note")
                    remove_answer("altar conflicts")
                end
            end
        elseif answer == "job" then
            add_dialogue("\"To provide various magics and items in Terfin.\"")
            add_answer({"Terfin", "buy"})
        elseif answer == "Terfin" then
            add_dialogue("\"To be the city in which you are located. To be the city of gargoyles.\"")
            add_answer("gargoyles")
            remove_answer("Terfin")
        elseif answer == "gargoyles" then
            add_dialogue("\"To know Quan is the Fellowship leader. To believe he gives good guidance.\" He appears thoughtful.~~ \"To have spoken to Draxinusom?\"")
            local4 = call_090AH()
            if local4 then
                add_dialogue("\"To see first, Draxinusom. To be leader of the city. To know many of the residents.\"")
            else
                add_dialogue("\"To see Forbrak or Quaeven, then. To know they see all the citizens regularly.\"")
            end
            remove_answer("gargoyles")
        elseif answer == "Fellowship" then
            add_dialogue("\"To be an important part of my life. To support The Fellowship fully.\"")
            remove_answer("Fellowship")
        elseif answer == "altar conflicts" then
            add_dialogue("\"To know nothing about the altars. To wonder what you mean?\"")
            remove_answer("altar conflicts")
        elseif answer == "found note" then
            add_dialogue("A surprised expression, mixed with fear, covers his face.~~ \"To be all Runeb's decisions! To be all Runeb's doing! To want nothing to do with the destruction of the altars, or with the assassination plot!\"")
            remove_answer("found note")
            add_answer("Assassination plot!")
        elseif answer == "Assassination plot!" then
            add_dialogue("\"To not already know about the plot?\" he wails.~~ \"To have caused problems this time, Sarpling,\" he says to himself. \"To have brought much trouble!~~ \"To tell you Runeb wanted to frame Quan for the altars. To kill Quan if plan failed, and to be in control of The Fellowship in Terfin. To be Runeb's goal.~~ \"To be in much danger you and me!\"*")
            set_flag(0x0240, true)
            return
        elseif answer == "buy" then
            remove_answer("buy")
            if local1 == 7 then
                add_dialogue("\"To want reagents or jewelry and potions?\"")
                add_answer({"jewelry and potions", "reagents"})
            else
                add_dialogue("\"To sell you things when my shop is open.\"")
            end
        elseif answer == "reagents" then
            call_08E2H()
            remove_answer("reagents")
        elseif answer == "jewelry and potions" then
            call_08E1H()
            remove_answer("jewelry and potions")
        elseif answer == "bye" then
            add_dialogue("\"To give you farewell, human.\"*")
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