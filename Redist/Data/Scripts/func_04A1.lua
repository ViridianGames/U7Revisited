require "U7LuaFuncs"
-- Function 04A1: Chad's dialogue and training mechanic
function func_04A1(eventid, itemref)
    -- Local variables (8 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7

    if eventid == 0 then
        call_092EH(-161)
        return
    elseif eventid ~= 1 then
        return
    end

    _SwitchTalkTo(0, -161)
    local0 = call_0908H()
    local1 = call_0909H()
    local2 = "Avatar"
    local3 = get_flag(0x01F1) and local0 or get_flag(0x01F3) and local2 or get_flag(0x01F2) and local1 or local0
    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x0203) then
        say("You see a lithe-looking fighter smile in your direction.")
    else
        say("Chad smiles. \"Hello, ", local3, ". I hope thy days are going well.\"")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"Chad, at thy service, ", local1, ". And what is thy name?\"")
            _RemoveAnswer("name")
            local4 = call_090BH(local1, local2, local0)
            if local4 == local0 then
                say("\"Greetings, ", local0, ". I am at thy service.\"")
                set_flag(0x01F1, true)
            elseif local4 == local1 then
                say("\"Greetings, ", local1, ".\" He shrugs.")
                set_flag(0x01F2, true)
            elseif local4 == local2 then
                say("\"Of course, of course,\" he smiles. \"I should have realized that thou wert the Avatar. Why, it must have been, oh, at least, two weeks since thy last visit!\" He winks.")
                if call_08F7H(-3) then
                    _SwitchTalkTo(0, -3)
                    say("\"Thou art a fool! Cannot thy feeble eyes see this is the Avatar?\"")
                    _HideNPC(-3)
                    _SwitchTalkTo(0, -161)
                    say("\"Yes, yes! I can see that,\" he laughs. \"Then I must be Iolo!\"")
                    local6 = call_08F7H(-1)
                    _SwitchTalkTo(0, -3)
                    say(local6 and "\"No, rogue! He is Iolo!\" He nods to Iolo. \"Thou... art a blind idiot!\"" or "\"No, rogue, thou art a blind idiot!\"")
                    _HideNPC(-3)
                    _SwitchTalkTo(0, -161)
                end
                set_flag(0x01F3, true)
            end
            set_flag(0x0203, true)
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("\"I teach expertise with light weapons here in Moonglow.\"")
            _AddAnswer({"Moonglow", "train"})
        elseif answer == "Moonglow" then
            say("\"Dost thou want the location of the city or to know about the townspeople?\"")
            _AddAnswer({"townspeople", "location"})
            _RemoveAnswer("Moonglow")
        elseif answer == "location" then
            say("\"Moonglow is on an island directly east of the border between Britain and Paws.\"")
            _RemoveAnswer("location")
        elseif answer == "townspeople" then
            say("\"The person to ask for that information would be Phearcy, the bartender. All I know are other bar patrons: Tolemac and Morz, two farmers.\"")
            _RemoveAnswer("townspeople")
        elseif answer == "train" then
            local7 = callis_003B()
            if local7 == 6 or local7 == 7 then
                say("\"Yes, I train people. But only during the day. Now, 'tis time for drink!\"")
            else
                say("\"Wilt thou pay the 45 gold for the training session?\"")
                if call_090AH() then
                    call_085FH(45, {4, 1})
                else
                    say("\"Well, mayhap next time thou wilt be willing.\"")
                end
            end
        elseif answer == "bye" then
            say("\"Remember, always keeps thy wits about and thy blade ready.\"")
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