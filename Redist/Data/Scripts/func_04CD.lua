-- Function 04CD: Zaksam's trainer dialogue and anti-gargoyle views
function func_04CD(eventid, itemref)
    -- Local variables (6 as per .localc)
    local local0, local1, local2, local3, local4, local5

    if eventid == 0 then
        local2 = callis_001C(callis_001B(-205))
        local3 = callis_003B()
        local4 = callis_Random2(4, 1)
        local5 = ""
        
        if local3 == 7 or local3 == 0 or local3 == 1 then
            if local2 == 14 then
                local5 = "Zzzzz . . ."
            end
        end
        if local3 >= 2 and local3 <= 5 and local2 == 7 then
            if local4 == 1 then
                local5 = "Increase thy skill here!"
            elseif local4 == 2 then
                local5 = "Increase thy strength here!"
            elseif local4 == 3 then
                local5 = "Fight better, be stronger!"
            elseif local4 == 4 then
                local5 = "Defend thyself against gargoyles!"
            end
        end
        if local3 == 6 and local2 == 26 then
            local5 = "Mmmmm, excellent wine!"
        end
        bark(205, local5)
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(205, 0)
    local0 = call_0908H()
    local1 = call_0909H()
    local2 = callis_001C(callis_001B(-205))
    add_answer({"bye", "job", "name"})

    if not get_flag(0x028A) then
        add_dialogue("A strong, powerful man looks at you and nods acknowledgment.")
        set_flag(0x028A, true)
    else
        add_dialogue("\"What can I do for thee?\" asks Zaksam.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"I am Zaksam,\" he states proudly.")
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("\"I teach others to be strong fighters. I am a trainer here in Vesper.\"")
            add_answer({"train", "Vesper"})
        elseif answer == "Vesper" then
            add_dialogue("\"I have taught here for many years. I like the town, but I am not too fond of some of the residents.\"")
            add_answer({"residents", "town"})
            remove_answer("Vesper")
        elseif answer == "town" then
            add_dialogue("\"The land to the northeast is a bit dry, but the oasis and nearby shores give us plenty of water for drinking and bathing.\"")
            remove_answer("town")
        elseif answer == "residents" then
            add_dialogue("\"Most of us are respectable, but there are a few that I wonder about. Blorn and the mayor, for example.\"")
            add_answer({"Blorn", "mayor"})
            remove_answer("residents")
        elseif answer == "mayor" then
            add_dialogue("\"'Tis not that I do not trust him. I just wonder about his ability to run the town. His name is Auston. Talk to him and see for thyself what thou thinkest. Better yet, talk to his clerk, Liana.\"")
            remove_answer("mayor")
        elseif answer == "Blorn" then
            add_dialogue("\"That one I do not like a bit. I do not trust him. He reminds me of those gargoyles.\"")
            add_answer("gargoyles")
            remove_answer("Blorn")
        elseif answer == "gargoyles" then
            add_dialogue("\"What is there to say, but do not let them get too close or they will rob thee. Any day now they may try to use violence to take over the town. The mayor himself has asked that I fight if necessary. Though I have no fear of death, that is a battle I do not look forward to.\"")
            add_answer({"violence", "rob"})
            remove_answer("gargoyles")
        elseif answer == "rob" then
            add_dialogue("\"I have already heard that some of my fellow residents have had things stolen by those wretched creatures.\"")
            remove_answer("rob")
        elseif answer == "violence" then
            add_dialogue("\"As thou must surely know, all gargoyles are prone to senseless fits of violence. 'Twould be quite natural to expect them to use it for their own selfish gain.\"")
            remove_answer("violence")
        elseif answer == "train" then
            if local2 == 7 then
                add_dialogue("\"I can train thee for 40 gold. Is this all right?\"")
                if call_090AH() then
                    call_094FH(40, 4, 0)
                else
                    add_dialogue("\"Perhaps next time, ", local1, ".\"")
                end
            else
                add_dialogue("\"I can train thee when I am at my training hall, ", local1, ". Please feel free to see me when it is open.\"")
            end
        elseif answer == "bye" then
            add_dialogue("\"May thy strength be thy guide.\"*")
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