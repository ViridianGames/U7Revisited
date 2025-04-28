require "U7LuaFuncs"
-- Function 04E4: Lucky's rogue dialogue and training offer
function func_04E4(eventid, itemref)
    -- Local variables (4 as per .localc)
    local local0, local1, local2, local3

    if eventid == 0 then
        local1 = callis_001C(callis_001B(-228))
        if local1 == 11 then
            local2 = callis_Random2(4, 1)
            if local2 == 1 then
                local3 = "@Har!@"
            elseif local2 == 2 then
                local3 = "@Avast!@"
            elseif local2 == 3 then
                local3 = "@Blast!@"
            elseif local2 == 4 then
                local3 = "@Damn parrot droppings...@"
            end
            _ItemSay(local3, -228)
        else
            call_092EH(-228)
        end
        return
    elseif eventid ~= 1 then
        return
    end

    _SwitchTalkTo(0, -228)
    local0 = callis_003B()
    local1 = callis_001C(callis_001B(-228))
    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x02B1) then
        say("You see a man whose sinewy body is like steel. The glint in his eye tells you that he is no fool.")
        set_flag(0x02B1, true)
    else
        say("\"What dost thou want with Lucky?\" the pirate asks.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"I am Lucky... in all things.\"")
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("\"I make my living off the world! It gives... and I take!\" The pirate laughs boisterously. \"I am a worldly gentleman, friends -- that is my 'job'! Oh, and I train initiates for a bit of pocket change.\"")
            _AddAnswer({"train", "world"})
        elseif answer == "world" then
            say("\"The ways of the world, is what I mean. I am a man of the road; I am a seasoned traveller. I travel through the world as a hundred different men.\"")
            _RemoveAnswer("world")
            _AddAnswer({"different", "traveller"})
        elseif answer == "traveller" then
            say("\"In truth there are few places where I have not been and little that I have not done.\"")
            _RemoveAnswer("traveller")
        elseif answer == "different" then
            say("\"Thou canst be a different person just by assumption. 'Tis an attitude. I am an expert in the art of charismatic communication for the purposes of deception. It gives one many skills. For example, I can walk into any shop and make a purchase. But I will walk away with much more than I bought, for I know how to fool the shopkeeper. Little things like that.\"")
            _RemoveAnswer("different")
        elseif answer == "train" then
            if local1 == 7 then
                say("\"I charge 35 gold for a training session. Doth this meet with thine approval?\"")
                if call_090AH() then
                    call_08B6H(35, 2)
                else
                    say("Lucky shrugs. \"Thou wilt not find another trainer on the island!\"")
                    _RemoveAnswer("train")
                end
            else
                say("\"I shall be happy to show thee my ways of the world during normal business hours at my residence -- afternoons and evenings.\"")
                _RemoveAnswer("train")
            end
        elseif answer == "bye" then
            say("\"Be careful, my friend.\"*")
            return
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