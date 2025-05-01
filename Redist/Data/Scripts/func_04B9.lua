-- Function 04B9: Quan's Fellowship dialogue and altar conflict denial
function func_04B9(eventid, itemref)
    -- Local variables (5 as per .localc)
    local local0, local1, local2, local3, local4

    if eventid == 0 then
        call_092FH(-185)
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(185, 0)
    local0 = call_0908H()
    local1 = callis_003B()
    local2 = call_0931H(1, -359, 981, 1, -357)

    if local1 == 7 then
        add_dialogue("The gargoyle seems to be too busy conducting the Fellowship meeting to speak with you now.")
        call_08CEH()
        return
    end

    add_answer({"bye", "Fellowship", "job", "name"})
    if not get_flag(0x01EF) then
        add_answer("Elizabeth and Abraham")
    end

    if not get_flag(0x024A) then
        add_dialogue("You see a winged gargoyle. Noticing you, he turns and says, \"To be welcome, human. To need assistance?\"")
        set_flag(0x024A, true)
    else
        add_dialogue("\"To ask how I may assist, human.\"")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"To be the one named Quan.\"")
            remove_answer("name")
            add_answer("Quan")
        elseif answer == "Quan" then
            add_dialogue("\"To have no meaning in Gargish. To be a special name, specific to me,\" he smiles.")
            remove_answer("Quan")
        elseif answer == "job" then
            add_dialogue("\"To head The Fellowship in Terfin.\"")
            add_answer({"Terfin"})
            if not get_flag(0x01F5) then
                add_answer("voice")
            end
        elseif answer == "voice" then
            add_dialogue("\"To be the inner voice of guidance that lives in all creatures. To become more distinct and frequent with stronger Fellowship ties.\"")
            remove_answer("voice")
        elseif answer == "Terfin" then
            add_dialogue("\"To be the only gargoyle city in Britannia. To have fewer gargoyles in the land than during your last visit to Britannia, human.\" He shakes his head.")
            add_answer({"gargoyles", "fewer"})
            remove_answer("Terfin")
        elseif answer == "fewer" then
            add_dialogue("\"To have succumbed to the effects of disease and famine that have recently struck Britannia. To tell you that gargoyles breed less frequently, and we have not had the time to make up for losses in our population.~~\"To have new hope, however,\" he grins, \"with The Fellowship.\"")
            remove_answer("fewer")
        elseif answer == "gargoyles" then
            add_dialogue("\"To suggest talking to Runeb, the Fellowship clerk, or Quaeven. To have jobs needing knowledge of others in Terfin.\" He grins apologetically.~~ \"To be too busy to know all in Terfin.\"")
            remove_answer("gargoyles")
        elseif answer == "Fellowship" then
            local3 = callis_0067()
            if local3 then
                if not get_flag(0x0006) then
                    add_dialogue("\"To hold meetings at 9 p.m., in unity with other branches, human. To be welcome at our meetings.\"")
                else
                    add_dialogue("\"To be a boon to gargoyles and humans alike. To have a philosophy to help all creatures of all races reach their highest level of potential.\"")
                    add_answer("philosophy")
                end
            else
                add_dialogue("\"To be a boon to gargoyles and humans alike. To have a philosophy to help all creatures of all races reach their highest level of potential.\"")
                add_answer("philosophy")
            end
            if get_flag(0x023C) and not get_flag(0x0242) then
                add_answer("altar conflicts")
            end
            remove_answer("Fellowship")
        elseif answer == "Elizabeth and Abraham" then
            if not get_flag(0x0264) then
                add_dialogue("\"To have just missed the human Fellowship officials who were here collecting funds. To have left for the Meditation Retreat near Serpent's Hold. To be sorry.\"")
                set_flag(0x0243, true)
            else
                add_dialogue("\"To have not seen human Fellowship officials in many days.\"")
            end
            remove_answer("Elizabeth and Abraham")
        elseif answer == "philosophy" then
            add_dialogue("An almost gleeful expression fills his visage.~~ \"To be very similar to the altar of singularity. To have three principles called the Triad of Inner Strength. To apply three principles in unison to be more creative and happy.~~ \"To see the similarity? To have control, passion, and diligence mesh into one -- singularity. To have Triad -- Strive for Unity, Trust your Brother, and Worthiness Precedes Reward -- applied in unison!\"")
            remove_answer("philosophy")
        elseif answer == "altar conflicts" then
            add_dialogue("\"To understand not,\" he says, puzzled.")
            if get_flag(0x0253) then
                add_answer("altar destruction")
            end
            remove_answer("altar conflicts")
        elseif answer == "altar destruction" then
            add_dialogue("\"To know nothing of this! To believe it not! To be not possible.~~ \"To know that all members are content with their lives, and incapable of such acts, even if the altars be outdated.~~ \"To tell you to speak with members themselves to see and believe.\"")
            add_answer({"members", "outdated"})
            remove_answer("altar destruction")
            if not get_flag(0x023F) then
                add_answer("Sarpling's note")
            end
            if not get_flag(0x0240) then
                add_answer("Runeb assassinate")
            end
        elseif answer == "outdated" then
            add_dialogue("\"To need the Triad for proper application to the individual gargoyle -- or person!\"")
            remove_answer("outdated")
        elseif answer == "members" then
            add_dialogue("\"To talk to Runeb, Sarpling, and Quaeven.\"")
            add_answer({"Quaeven", "Sarpling", "Runeb"})
            remove_answer("members")
        elseif answer == "Runeb" then
            local4 = callis_0037(callis_001B(-184))
            if not local4 then
                add_dialogue("\"To have been the clerk of The Fellowship here.\"")
            else
                add_dialogue("\"To be the clerk of The Fellowship here.\"")
            end
            remove_answer("Runeb")
        elseif answer == "Sarpling" then
            add_dialogue("\"To sell magics and such at his shop.\"")
            set_flag(0x0241, true)
            remove_answer("Sarpling")
        elseif answer == "Quaeven" then
            add_dialogue("\"To be in charge of the learning center.\"")
            remove_answer("Quaeven")
        elseif answer == "Sarpling's note" then
            add_dialogue("\"To be impossible for Runeb to be responsible.\" He smiles kindly. \"To be a practical joke.\"")
            set_flag(0x0242, true)
            remove_answer("Sarpling's note")
        elseif answer == "Runeb assassinate" then
            add_dialogue("\"To be too heinous a plot for Runeb.\" He frowns. \"To be some kind of bad joke.\"")
            set_flag(0x0242, true)
            remove_answer("Runeb assassinate")
        elseif answer == "bye" then
            add_dialogue("\"To hope you find unity.\"*")
            if not local2 then
                add_dialogue("The Cube did not vibrate once while speaking with Quan. You realize he is totally innocent of the dangerous powers above him.*")
            end
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