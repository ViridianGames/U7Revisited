require "U7LuaFuncs"
-- Function 08D8: Manages Rowena's awakened dialogue
function func_08D8()
    -- Local variables (5 as per .localc)
    local local0, local1, local2, local3, local4

    local0 = callis_005A()
    local1 = call_0909H()
    if not get_flag(0x01B8) then
        callis_0003(0, -144)
        say("The beautiful ghost looks through you with a slack look. Nothing you do seems to attract her attention.")
        set_flag(0x01A7, false)
        abort()
    end
    if not get_flag(0x01A9) then
        local2 = call_08F7H(-141)
        if not local2 then
            say("The music of the little box makes Rowena turn her head in your direction. She blinks several times as if waking from a dream, or, in this case, a nightmare. When she sees the Liche, she pretends to be enthralled, but as soon as he is no longer looking in her direction, she motions for you to come closer.")
        else
            say("The music of the little box makes Rowena turn her head in your direction. She blinks several times as if waking from a dream, or, in this case, a nightmare.")
        end
        say("\"I am in control of my mind for the time being, but I know not for how long. Tell me what has transpired in the town outside.\" You relay to her what you know of the events you've heard in town.")
        if not get_flag(0x01C7) then
            say("\"My poor Trent. I cannot bear to think that he's become so hurt that he would forget our love.\" She wrings her hands in sorrow and notices something on one of them.")
        else
            say("\"And what of my poor Trent? He must be heartsick. I must find a way to get a message to him.\" Something on her hand sparkles brilliantly.")
        end
        say("\"Please, ", local1, ", wouldst thou take this ring to him and tell him that I still love him. Mayhaps it will restore him to the beloved Trent I knew.\"")
        local3 = callis_0024(295)
        local4 = call_0907H(callis_001B(-356))
        if not local4 then
            say("She takes a ring from her slender finger and places it in your hand. You expect it to pass right through, but it rests neatly in your palm.")
        else
            local4 = callis_0026(callis_0018(-356))
            say("She takes a ring from her slender finger and places it in your hand. You expect it to pass right through, and it does. Fortunately, it falls to the floor, softly ringing as it strikes the stones.")
        end
        if not local0 then
            say("\"I thank thee, kind lady. I know not how to repay thee.\"")
        else
            say("\"I thank thee, kind sir. I know not how to repay thee.\"")
        end
        say("Rowena's eyes begin to look a little glassy and she blinks slowly as if entering a deep trance.")
        set_flag(0x01A9, true)
    end
    say("She blinks slowly. \"What beautiful music. My Lord... Horance, once gave me a music box like that one.\" Rowena turns away, distracted.")
    abort()

    return
end

-- Helper functions
function say(...)
    print(table.concat({...}))
end

function get_flag(flag)
    return false -- Placeholder
end

function set_flag(flag, value)
    -- Placeholder
end

function abort()
    -- Placeholder
end