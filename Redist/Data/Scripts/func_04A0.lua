require "U7LuaFuncs"
-- Function 04A0: Effrem's dialogue with baby Mikhail
function func_04A0(eventid, itemref)
    -- Local variables (10 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9

    if eventid == 0 then
        call_092EH(-160)
        return
    elseif eventid ~= 1 then
        return
    end

    _SwitchTalkTo(0, -160)
    local0 = call_0908H()
    local1 = call_0909H()
    local2 = "the Avatar"
    local3 = _IsPlayerFemale()
    local4 = false
    local5 = call_08F7H(-159)
    local6 = local3 and "woman" or "man"
    local7 = local3 and "she" or "he"
    local8 = get_flag(0x01F4) and local1 or local0
    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x0202) then
        say("You see a man with a sour expression on his face holding a baby boy. As he sees you, his face brightens.")
        set_flag(0x0202, true)
    else
        say("\"Hello again, ", local8, ". I am here as usual, taking care of little Mikhail.\" Effrem grimaces.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"I am Effrem, ", local1, ". I am but a simple resident of Moonglow.\"")
            if not get_flag(0x01F4) then
                say("\"What is thy name?\"")
                local9 = call_090BH(local1, local2, local0)
                if local9 == local0 then
                    say("\"Hello, ", local0, ".\" He turns to the baby.~~ \"Say `hello' to ", local0, ", Mikhail.\"")
                    set_flag(0x01F4, true)
                elseif local9 == local1 then
                    say("\"Fine, ", local1, ", if that is the title by which thou dost wish to be called.\" He looks at the infant. \"The ", local6, " is quite a snob is ", local7, " not, Mikhail?\"")
                elseif local9 == local2 then
                    say("\"Aha, the Avatar, thou sayest. Whatever thou thinkest....\" He turns to the baby.~~\"This poor person here wants to be the Avatar. Too bad there is only one Avatar, eh Mikhail?\"")
                end
            end
            _AddAnswer({"Moonglow", "Mikhail"})
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("\"Me? I do not have a job. Not a real one like my wife has. All I do all day is watch over my little Mikhail, here.\" He turns to look at the baby, taking on a patronizing tone. \"Yes, I take care of thee, do I not? Yes, I do. I sure do.\" He kisses the boy and then looks back up at you, embarrassed.~~\"Where was I? Oh yes. All I do is take care of the boy. What I should be doing is working, not staying at home. That should be Jillian's job. She belongs here at home, not me.\"")
            if not local4 then
                _AddAnswer("Jillian")
            end
        elseif answer == "Mikhail" then
            say("\"That is the name of my son. 'Tis a good name, yes?\"")
            _RemoveAnswer("Mikhail")
        elseif answer == "Jillian" or answer == "wife" then
            say("\"My wife? Jillian? She's the scholar. She is a very good one, too. Not that I could not have done well. I could have. Better, in fact. But it is not worth arguing about now. She has her occupation, even if I do not have one. I should have a job, though. Dost thou not agree, ", local1, "? This is not what a man ought to be doing. Staying at home raising the children, like this. 'Tis a disgrace!\"")
            if local5 then
                _SwitchTalkTo(0, -159)
                say("\"Now Effrem! Thou knowest perfectly well what we agreed when little Mikhail was born. Thou shouldst be ashamed, talking such nonsense.\"")
                _HideNPC(-159)
                _SwitchTalkTo(0, -160)
                say("He raises his shoulders, making him appear quite sheepish.")
            end
            _RemoveAnswer({"Jillian", "wife"})
            local4 = true
            if not local4 then
                _AddAnswer("wife")
            end
        elseif answer == "Moonglow" then
            say("\"What about Moonglow?\" He shrugs, \"'Tis a fair town, but a little too crowded these days. I hear it was a much nicer place back when Moonglow was separate from the Lycaeum. Much smaller.~~\"This place is too large to really get to know anyone. Not that I have had much of an opportunity, having to stay at home and take care of my son.\" He looks down at the boy, smiles, and tickles the baby's nose.")
            if not local5 then
                say("\"This is not a job for a man. My wife should be home with the boy, not me. I should be out earning a living. That is what I ought to be doing!\"")
            end
            if not local4 then
                _AddAnswer("wife")
            end
            _RemoveAnswer("Moonglow")
        elseif answer == "bye" then
            if _IsPlayerFemale() then
                say("\"Leaving so soon? Fine, leave me with the baby. Go on, leave me. Just like my wife!\"")
            else
                say("\"Leaving so soon? Ah, that's all right, ", local1, ". I understand, thou hast real man things to do.\"")
            end
            break
        end

        -- Note: Original has 'db 40' here, ignored
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