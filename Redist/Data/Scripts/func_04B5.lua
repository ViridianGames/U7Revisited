-- Function 04B5: Inforlem's trainer dialogue
function func_04B5(eventid, itemref)
    -- Local variables (2 as per .localc)
    local local0, local1

    if eventid == 0 then
        call_092FH(-181)
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(181, 0)
    local0 = false
    local1 = callis_003B()
    add_answer({"bye", "job", "name"})

    if not get_flag(0x0246) then
        add_dialogue("The gargoyle has a pleasant expression on his face.")
        set_flag(0x0246, true)
    else
        add_dialogue("\"To be pleased at your return, human,\" says Inforlem.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"To be known as Inforlem.\"")
            add_answer("Inforlem")
            remove_answer("name")
        elseif answer == "Inforlem" then
            add_dialogue("\"To mean `make strong one.'\"")
            remove_answer("Inforlem")
        elseif answer == "job" then
            add_dialogue("\"To train others in Terfin to be strong and powerful. To sell some weapons, also.\"")
            add_answer({"buy", "Terfin", "others", "train"})
            if not get_flag(0x0244) and not local0 then
                add_answer("conflicts")
            end
        elseif answer == "buy" then
            if local1 == 3 or local1 == 4 or local1 == 5 then
                call_089CH()
            else
                add_dialogue("\"To sell during shop hours. To ask you to come back to me at that time, please.\"")
            end
        elseif answer == "train" then
            if local1 == 3 or local1 == 4 or local1 == 5 then
                add_dialogue("\"To be a better warrior or mage?\"")
                add_answer({"mage", "warrior"})
            else
                add_dialogue("\"To train during training hours. To ask you to come back to me at that time, please.\"")
            end
        elseif answer == "warrior" then
            add_dialogue("\"To charge 50 gold for each training session. To be all right?\"")
            local2 = call_090AH()
            if local2 then
                call_089BH(50, 4, {1, 0, 3})
            else
                add_dialogue("\"To apologize, but I must charge that amount!\"")
            end
            remove_answer("warrior")
        elseif answer == "mage" then
            add_dialogue("\"To charge 50 gold for each training session. To be acceptable?\"")
            local2 = call_090AH()
            if local2 then
                call_089AH(50, 2, {6})
            else
                add_dialogue("\"To apologize, but I must charge that amount!\"")
            end
            remove_answer("mage")
        elseif answer == "conflicts" then
            add_dialogue("\"To know of the conflicts between the altars and the Fellowship, but to have no information. To suggest you see Quan, The Fellowship leader here and ask him.\"")
            set_flag(0x023C, true)
            local0 = true
            remove_answer("conflicts")
        elseif answer == "Terfin" then
            add_dialogue("\"To see there are troubles here, but to be unaware of the causes and solutions.\"")
            remove_answer("Terfin")
        elseif answer == "others" then
            add_dialogue("\"To tell you Forbrak knows much about Terfin and its residents, and,\" he says, \"about its conflicts.\"")
            add_answer("Forbrak")
            if not local0 then
                add_answer("conflicts")
            end
            remove_answer("others")
        elseif answer == "Forbrak" then
            add_dialogue("\"To be the tavernkeeper.\"")
            remove_answer("Forbrak")
        elseif answer == "bye" then
            add_dialogue("\"To expect to see you again, human.\"*")
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