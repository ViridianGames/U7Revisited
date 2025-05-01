-- Function 04CC: Mara's miner dialogue and anti-gargoyle sentiment
function func_04CC(eventid, itemref)
    -- Local variables (9 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8

    if eventid == 0 then
        call_092EH(-204)
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(203, 0)
    local0 = call_0909H()
    local1 = call_0908H()
    local2 = "the Avatar"
    local3 = callis_001B(-204)
    local4 = callis_001B(-205)
    local5 = callis_003B()
    local6 = callis_001C(local3)
    local7 = callis_003C(local3)
    add_answer({"bye", "job", "name"})

    if local7 == 2 then
        calli_001D(0, local3)
        calli_001D(0, local4)
    end

    if not get_flag(0x0289) then
        add_dialogue("You see a well-muscled woman who lifts her head in acknowledgement of your presence.")
        set_flag(0x0289, true)
    else
        add_dialogue("\"Yes, ", local0, "?\"")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("The woman grabs your hand and shakes vigorously. \"Hello. M'name's Mara.\"")
            if local6 == 26 then
                add_dialogue("\"What is thine?\"")
                local8 = call_090BH({local0, local1, local2})
                if local8 == local2 then
                    add_dialogue("\"The Avatar!\" she shouts angrily. \"Why thou art the one responsible for bringing those wretched gargoyles into our fine land!\"*")
                    calli_001D(0, local3)
                    calli_003D(2, local3)
                    calli_001D(0, local4)
                    calli_003D(2, local4)
                    return
                else
                    add_dialogue("\"'Tis good to meet thee!\"")
                end
            end
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("She flexes proudly, \"I am a miner in Vesper.\"")
            add_answer("Vesper")
        elseif answer == "Vesper" then
            add_dialogue("\"This used to be a pleasant town,\" she looks around, apparently checking if anyone is near, \"'til the gargoyles became so unruly. Now most of us have to spend far too much time wondering when the gargoyles will decide they want to kill us.\"")
            add_answer({"us", "gargoyles"})
            remove_answer("Vesper")
        elseif answer == "gargoyles" then
            add_dialogue("She shrugs. \"There is naught to say, except that they are a menace. This town would be a much better place without them.\"")
            remove_answer("gargoyles")
        elseif answer == "us" then
            add_dialogue("\"Well, I know Cador feels as I do, as does his wife. I have heard the mayor express his concern about them. I don't really know his clerk, Liana.\"")
            add_answer({"Liana", "mayor", "wife", "Cador"})
            remove_answer("us")
        elseif answer == "wife" then
            add_dialogue("\"Yvella is a lovely woman. She spends her days caring for their daughter, Catherine.\"")
            remove_answer("wife")
        elseif answer == "Liana" then
            add_dialogue("\"I have only seen her a few times. I do not know her well enough to say this, but I think she is angry about something, for she is always in a bad mood.\"")
            remove_answer("Liana")
        elseif answer == "Cador" then
            add_dialogue("\"He is in charge of managing the mines. Does a fair job, too. He usually joins me at the Gilded Lizard.\"")
            add_answer("Gilded Lizard")
            remove_answer("Cador")
        elseif answer == "mayor" then
            add_dialogue("\"His name is Auston. I like him, but I suspect that Liana is the one who truly keeps Vesper in order.\"")
            remove_answer("mayor")
        elseif answer == "Gilded Lizard" then
            add_dialogue("\"That is the tavern here in Vesper. Yongi's the barkeeper. He serves a passing fair tankard of ale.\"")
            remove_answer("Gilded Lizard")
        elseif answer == "bye" then
            add_dialogue("Mara shakes your hand and slaps you on the back, saying, \"Fare thee well, friend!\"*")
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