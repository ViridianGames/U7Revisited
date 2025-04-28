require "U7LuaFuncs"
-- Function 04E0: Roberto's host dialogue and secret passage hint
function func_04E0(eventid, itemref)
    -- Local variables (12 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11

    if eventid == 0 then
        return
    elseif eventid ~= 1 then
        return
    end

    _SwitchTalkTo(0, -224)
    local0 = callis_003B()
    local1 = callis_001C(callis_001B(-224))
    local2 = call_0908H()
    local3 = "Avatar"
    local4 = callis_IsPlayerFemale()
    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x02A1) then
        local5 = local2
    elseif not get_flag(0x02A2) then
        local5 = local3
    end

    if local1 == 7 and not (get_flag(0x029C) and callis_0065(4) < 2 or get_flag(0x029D) and callis_0065(2) < 2 or get_flag(0x029E) and callis_0065(3) < 2) then
        say("The man looks at you with surprise and says, \"Hold, ", local4 and "milady" or "sir", "! Thou didst just enjoy thyself, didst thou not? Please come back when thou art rested!\"*")
        return
    end

    if not get_flag(0x02AD) then
        say("You see a strikingly handsome man with eyes that pierce your soul.")
        if local4 then
            say("\"Hello, gorgeous!\"")
        else
            say("\"Hello. Uhm, art thou sure thou dost not really want to speak with Wench or Martine?\"")
            local6 = call_090AH()
            if local6 then
                say("\"Fine, sailor, whatever makes thy blood boil...\"")
            else
                say("\"Then thou hadst best speak with one of them. They are probably more to thy liking!\"*")
                return
            end
        end
        say("\"What is thy name?\"")
        local9 = call_090BH({local3, local2})
        if local9 == local2 then
            if local4 then
                say("\"Well, I am very pleased to meet thee, ", local2, ".\"")
            else
                say("\"Hello, ", local2, ".\"")
            end
            local5 = local2
            set_flag(0x02A1, true)
        elseif local9 == local3 then
            say("Roberto does a double-take. \"The Avatar, eh? And I thought I had heard it all...\"")
            local5 = local3
            set_flag(0x02A2, true)
        end
        set_flag(0x02AD, true)
    else
        say("\"Hello again, ", local5, ",\" Roberto says.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"I am known in these parts as Roberto.\"")
            if local4 then
                say("Roberto takes your hand and says, \"And thou art the most beautiful woman I have ever laid eyes upon!\"")
            end
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("Roberto smiles broadly. \"Thou dost not really want to know that, dost thou?\" He shakes his head, suppressing a laugh. \"Very well -- it is my task to see that thou art truly comfortable whilst at The Baths.\"")
            _AddAnswer({"comfortable", "The Baths"})
        elseif answer == "The Baths" then
            say("\"Nice place, is it not? I certainly enjoy working here! It brings me much wealth, and I have many opportunities to meet ", local4 and "beautiful women" or "handsome men", " such as thyself!\"")
            _RemoveAnswer("The Baths")
        elseif answer == "comfortable" then
            say("\"What would suit thee? We could swim in the spring pools, or I could give thee a massage. If thou dost prefer to converse, we could simply talk. Or if thou wouldst like, we could wander into the Community Room and... communicate!\"")
            _AddAnswer({"Community Room", "talk", "massage", "swim"})
            _RemoveAnswer("comfortable")
        elseif answer == "Community Room" then
            say("\"Thou dost want to join me in the Community Room?\"")
            local10 = call_090AH()
            if local10 then
                say("Roberto leads you into a private room.~~\"It really isn't a Community Room at all. We shall be all alone!\" ~~A while later, after you have received the man's full attention, you emerge from the Community Room a much happier Avatar.")
                set_flag(0x029E, true)
                calli_0066(3)
                local11 = callis_002B(true, -359, -359, 644, 50)
            else
                say("\"Do not worry about it, ", local5, ". We can do something else.\"")
            end
            _RemoveAnswer("Community Room")
        elseif answer == "swim" then
            say("Roberto helps you with your clothing and leads you into the warm spring water. It feels terrific, and you feel like going to sleep, but you know you have a quest to complete. After a while, Roberto helps you out of the water and you dress.")
            _RemoveAnswer("swim")
        elseif answer == "massage" then
            say("Roberto helps you with your clothing and leads you to a comfortable table. You lie face down and the man expertly kneads and rubs your aching muscles, slowly sending you over the edge into a state of total relaxation. After a while, Roberto helps you up and you dress.")
            _RemoveAnswer("massage")
        elseif answer == "talk" then
            say("Roberto smiles. \"That is all right. What shall we talk about? Adventuring? Secret passages and dungeons?\"~~ Roberto leans closer and whispers, \"Didst thou know that there are secret passages connecting the buildings on Buccaneer's Den? 'Tis true! I am fairly sure the entrance is through the House of Games, and I am quite sure there is a way into The Baths.\"~~You and Roberto speak of a number of other subjects until you realize that you are spending far too much time in the spa. There is a quest to fulfill!")
            _RemoveAnswer("talk")
        elseif answer == "bye" then
            say("\"I hope to see thee again, ", local5, ".\"*")
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