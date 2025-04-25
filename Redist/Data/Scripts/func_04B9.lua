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

    _SwitchTalkTo(0, -185)
    local0 = call_0908H()
    local1 = callis_003B()
    local2 = call_0931H(1, -359, 981, 1, -357)

    if local1 == 7 then
        say("The gargoyle seems to be too busy conducting the Fellowship meeting to speak with you now.")
        call_08CEH()
        return
    end

    _AddAnswer({"bye", "Fellowship", "job", "name"})
    if not get_flag(0x01EF) then
        _AddAnswer("Elizabeth and Abraham")
    end

    if not get_flag(0x024A) then
        say("You see a winged gargoyle. Noticing you, he turns and says, \"To be welcome, human. To need assistance?\"")
        set_flag(0x024A, true)
    else
        say("\"To ask how I may assist, human.\"")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"To be the one named Quan.\"")
            _RemoveAnswer("name")
            _AddAnswer("Quan")
        elseif answer == "Quan" then
            say("\"To have no meaning in Gargish. To be a special name, specific to me,\" he smiles.")
            _RemoveAnswer("Quan")
        elseif answer == "job" then
            say("\"To head The Fellowship in Terfin.\"")
            _AddAnswer({"Terfin"})
            if not get_flag(0x01F5) then
                _AddAnswer("voice")
            end
        elseif answer == "voice" then
            say("\"To be the inner voice of guidance that lives in all creatures. To become more distinct and frequent with stronger Fellowship ties.\"")
            _RemoveAnswer("voice")
        elseif answer == "Terfin" then
            say("\"To be the only gargoyle city in Britannia. To have fewer gargoyles in the land than during your last visit to Britannia, human.\" He shakes his head.")
            _AddAnswer({"gargoyles", "fewer"})
            _RemoveAnswer("Terfin")
        elseif answer == "fewer" then
            say("\"To have succumbed to the effects of disease and famine that have recently struck Britannia. To tell you that gargoyles breed less frequently, and we have not had the time to make up for losses in our population.~~\"To have new hope, however,\" he grins, \"with The Fellowship.\"")
            _RemoveAnswer("fewer")
        elseif answer == "gargoyles" then
            say("\"To suggest talking to Runeb, the Fellowship clerk, or Quaeven. To have jobs needing knowledge of others in Terfin.\" He grins apologetically.~~ \"To be too busy to know all in Terfin.\"")
            _RemoveAnswer("gargoyles")
        elseif answer == "Fellowship" then
            local3 = callis_0067()
            if local3 then
                if not get_flag(0x0006) then
                    say("\"To hold meetings at 9 p.m., in unity with other branches, human. To be welcome at our meetings.\"")
                else
                    say("\"To be a boon to gargoyles and humans alike. To have a philosophy to help all creatures of all races reach their highest level of potential.\"")
                    _AddAnswer("philosophy")
                end
            else
                say("\"To be a boon to gargoyles and humans alike. To have a philosophy to help all creatures of all races reach their highest level of potential.\"")
                _AddAnswer("philosophy")
            end
            if get_flag(0x023C) and not get_flag(0x0242) then
                _AddAnswer("altar conflicts")
            end
            _RemoveAnswer("Fellowship")
        elseif answer == "Elizabeth and Abraham" then
            if not get_flag(0x0264) then
                say("\"To have just missed the human Fellowship officials who were here collecting funds. To have left for the Meditation Retreat near Serpent's Hold. To be sorry.\"")
                set_flag(0x0243, true)
            else
                say("\"To have not seen human Fellowship officials in many days.\"")
            end
            _RemoveAnswer("Elizabeth and Abraham")
        elseif answer == "philosophy" then
            say("An almost gleeful expression fills his visage.~~ \"To be very similar to the altar of singularity. To have three principles called the Triad of Inner Strength. To apply three principles in unison to be more creative and happy.~~ \"To see the similarity? To have control, passion, and diligence mesh into one -- singularity. To have Triad -- Strive for Unity, Trust your Brother, and Worthiness Precedes Reward -- applied in unison!\"")
            _RemoveAnswer("philosophy")
        elseif answer == "altar conflicts" then
            say("\"To understand not,\" he says, puzzled.")
            if get_flag(0x0253) then
                _AddAnswer("altar destruction")
            end
            _RemoveAnswer("altar conflicts")
        elseif answer == "altar destruction" then
            say("\"To know nothing of this! To believe it not! To be not possible.~~ \"To know that all members are content with their lives, and incapable of such acts, even if the altars be outdated.~~ \"To tell you to speak with members themselves to see and believe.\"")
            _AddAnswer({"members", "outdated"})
            _RemoveAnswer("altar destruction")
            if not get_flag(0x023F) then
                _AddAnswer("Sarpling's note")
            end
            if not get_flag(0x0240) then
                _AddAnswer("Runeb assassinate")
            end
        elseif answer == "outdated" then
            say("\"To need the Triad for proper application to the individual gargoyle -- or person!\"")
            _RemoveAnswer("outdated")
        elseif answer == "members" then
            say("\"To talk to Runeb, Sarpling, and Quaeven.\"")
            _AddAnswer({"Quaeven", "Sarpling", "Runeb"})
            _RemoveAnswer("members")
        elseif answer == "Runeb" then
            local4 = callis_0037(callis_001B(-184))
            if not local4 then
                say("\"To have been the clerk of The Fellowship here.\"")
            else
                say("\"To be the clerk of The Fellowship here.\"")
            end
            _RemoveAnswer("Runeb")
        elseif answer == "Sarpling" then
            say("\"To sell magics and such at his shop.\"")
            set_flag(0x0241, true)
            _RemoveAnswer("Sarpling")
        elseif answer == "Quaeven" then
            say("\"To be in charge of the learning center.\"")
            _RemoveAnswer("Quaeven")
        elseif answer == "Sarpling's note" then
            say("\"To be impossible for Runeb to be responsible.\" He smiles kindly. \"To be a practical joke.\"")
            set_flag(0x0242, true)
            _RemoveAnswer("Sarpling's note")
        elseif answer == "Runeb assassinate" then
            say("\"To be too heinous a plot for Runeb.\" He frowns. \"To be some kind of bad joke.\"")
            set_flag(0x0242, true)
            _RemoveAnswer("Runeb assassinate")
        elseif answer == "bye" then
            say("\"To hope you find unity.\"*")
            if not local2 then
                say("The Cube did not vibrate once while speaking with Quan. You realize he is totally innocent of the dangerous powers above him.*")
            end
            break
        end
    end

    return
end

-- Helper functions
function say(...)
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