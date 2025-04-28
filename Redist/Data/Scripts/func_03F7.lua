require "U7LuaFuncs"
-- Function 03F7: Golem dialogue and item interactions
function func_03F7(eventid, itemref)
    -- Local variables (6 as per .localc)
    local local0, local1, local2, local3, local4, local5

    if eventid ~= 1 then
        return
    end

    local0 = _GetContainerItems(4, 243, 797, itemref)
    _SwitchTalkTo(0, -288)

    if not local0 then
        if not get_flag(0x0328) then
            call_0893H()
        end
        if not get_flag(0x031C) then
            call_0892H()
        end
        if not get_flag(0x031F) and not get_flag(0x0322) then
            local0 = call_0931H(-359, 144, 642, 1, -357)
            if not local0 then
                say("\"Hast thou in thy possession the book on the Stone of Castambre?\"")
                if call_090AH() then
                    say("His eyes reveal his hope. As he takes the book from you, it almost appears as if he is smiling.")
                    call_0891H()
                else
                    say("\"That is, indeed, a pity,\" he says, shaking his head in sadness.")
                end
            end
        end
        if not get_flag(0x0314) then
            say("\"Greetings to thee, honorable one. I can but assume that my presence here was thy doing.\" It becomes quickly apparent that this creature possesses a greater capability for speech than his fallen companion.")
            if not get_flag(0x031C) then
                local1 = callis_0035(0, 40, 414, -356)
                while local1 do
                    -- Note: Original has 'sloop' and 'db 2' for iteration, ignored
                    local4 = _GetItemFrame(local4)
                    if local4 == 4 or local4 == 5 then
                        say("The recently raised golem stares down at the prone, lifeless body of Bollux. Quickly he looks up at you.\"Wh-what has happened?\"")
                        call_0890H()
                    end
                    local1 = callis_0035(0, 40, 414, -356)
                end
            else
                say("\"Now thou must excuse me, for I am off to find my fellow sentry.\"")
                set_flag(0x0314, true)
                return -- abrt
            end
        elseif not get_flag(0x031E) then
            say("\"Hail, friend. I hope that I may assist thee in some way.\"")
            call_0890H()
        else
            say("\"Art thou here to aid me in healing my brother?\"")
            if call_090AH() then
                say("\"Very good. I am pleased to call thee friend.\"")
                set_flag(0x031E, true)
                call_0890H()
            else
                say("\"Then begone, for I have work to do!\"")
                return -- abrt
            end
        end
    else
        local0 = _GetContainerItems(4, 244, 797, itemref)
        if local0 or (_GetItemQuality(callis_0035(176, 1, 797, itemref)) == 244) then
            call_0894H(itemref)
        end
    end

    return
end

-- Helper functions
function say(message)
    print(message)
end

function get_flag(flag)
    return false -- Placeholder
end

function set_flag(flag, value)
    -- Placeholder
end