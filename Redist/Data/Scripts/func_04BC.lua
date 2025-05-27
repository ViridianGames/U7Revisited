--- Best guess: Manages Sarpling’s dialogue in Terfin, a Fellowship-supporting shopkeeper fearful of Runeb’s altar destruction and assassination plot.
function func_04BC(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    if eventid == 1 then
        switch_talk_to(0, 188)
        var_0000 = get_schedule()
        var_0001 = unknown_001CH(get_npc_name(188))
        if var_0000 == 7 then
            var_0002 = unknown_08FCH(185, 188)
            if var_0002 then
                add_dialogue("The gargoyle is too involved with the Fellowship meeting to talk to you at this moment.")
            else
                add_dialogue("\"To be unable to talk now. To see me after the Fellowship meeting.\" He continues on his way.")
            end
            return
        end
        start_conversation()
        add_answer({"bye", "Fellowship", "job", "name"})
        if not get_flag(589) then
            add_dialogue("You see a very distraught gargoyle.")
            set_flag(589, true)
        else
            add_dialogue("\"To give you greetings, human.\"")
        end
        if get_flag(592) then
            var_0003 = true
            if get_flag(577) and not get_flag(576) then
                add_answer("altar conflicts")
            end
            if get_flag(575) then
                add_answer("found note")
                remove_answer("altar conflicts")
            end
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"To be able to call me Sarpling.\"")
                set_flag(592, true)
                remove_answer("name")
                if var_0003 then
                    if get_flag(577) and not get_flag(576) then
                        add_answer("altar conflicts")
                    end
                    if get_flag(575) then
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
                add_dialogue("\"To know Quan is the Fellowship leader. To believe he gives good guidance.\" He appears thoughtful.")
                add_dialogue("\"To have spoken to Draxinusom?\"")
                var_0004 = ask_yes_no()
                if var_0004 then
                    add_dialogue("\"To see Forbrak or Quaeven, then. To know they see all the citizens regularly.\"")
                else
                    add_dialogue("\"To see first, Draxinusom. To be leader of the city. To know many of the residents.\"")
                end
                remove_answer("gargoyles")
            elseif answer == "Fellowship" then
                add_dialogue("\"To be an important part of my life. To support The Fellowship fully.\"")
                remove_answer("Fellowship")
            elseif answer == "altar conflicts" then
                add_dialogue("\"To know nothing about the altars. To wonder what you mean?\"")
                remove_answer("altar conflicts")
            elseif answer == "found note" then
                add_dialogue("A surprised expression, mixed with fear, covers his face.")
                add_dialogue("\"To be all Runeb's decisions! To be all Runeb's doing! To want nothing to do with the destruction of the altars, or with the assassination plot!\"")
                remove_answer("found note")
                add_answer("Assassination plot!")
            elseif answer == "Assassination plot!" then
                add_dialogue("\"To not already know about the plot?\" he wails.")
                add_dialogue("\"To have caused problems this time, Sarpling,\" he says to himself. \"To have brought much trouble!\"")
                add_dialogue("\"To tell you Runeb wanted to frame Quan for the altars. To kill Quan if plan failed, and to be in control of The Fellowship in Terfin. To be Runeb's goal.\"")
                add_dialogue("\"To be in much danger you and me!\"")
                set_flag(576, true)
                return
            elseif answer == "buy" then
                remove_answer("buy")
                if var_0001 == 7 then
                    add_dialogue("\"To want reagents or jewelry and potions?\"")
                    add_answer({"jewelry and potions", "reagents"})
                else
                    add_dialogue("\"To sell you things when my shop is open.\"")
                end
            elseif answer == "reagents" then
                unknown_08E2H()
                remove_answer("reagents")
            elseif answer == "jewelry and potions" then
                unknown_08E1H()
                remove_answer("jewelry and potions")
            elseif answer == "bye" then
                add_dialogue("\"To give you farewell, human.\"")
                break
            end
        end
    elseif eventid == 0 then
        unknown_092FH(188)
    end
    return
end