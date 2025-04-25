-- Function 08AD: Manages Horance's Well of Souls dialogue
function func_08AD()
    -- Local variables (4 as per .localc)
    local local0, local1, local2, local3

    callis_0003(1, -141)
    local0 = call_0909H()
    local1 = call_0908H()

    if not get_flag(0x01AD) then
        set_flag(0x01AD, true)
        say("\"I thank thee, ", local0, ". That dark spirit had suppressed my will for so long that I was not sure I had one left. Thou hast done a great deed for Skara Brae, for myself and, indeed, all of Britannia, but then I suppose this is merely a matter of course for one such as thee. My gratitude is thine.\" He bows deeply to you.")
        if not get_flag(0x0003) then
            say("But now, I fear that all is still not right with the world. The ether stirs chaotically outside of this Dark Tower. Were it not for some property within the walls, I fear my mind would suffer the ravages of its force.")
        end
    else
        if get_flag(0x01D1) then
            local2 = "Hast thou reconsidered my request?"
        else
            local2 = ""
        end
        say("\"It is good to see thee again, ", local1, ".", local2, "\"")
    end

    if not get_flag(0x01D1) then
        local3 = "Ah, I see. No matter"
        call_08AEH(local3)
    end

    if not get_flag(0x01AC) and not get_flag(0x01D1) then
        say("\"Now, ", local0, ". I must ask this favor of thee. The Well of Souls, at the bottom of this tower, holds many tormented souls within it and binds the spirits of Skara Brae to this island. It must be destroyed.\" Horance looks at you intently.~ \"I can only hope that thou wilt try to free them.\"")
        say("\"Well, wilt thou?\" He looks at you expectantly.")
        local3 = "I understand. Fear not"
        call_08AEH(local3)
    end

    if not get_flag(0x01AE) then
        say("Horance thinks for a moment then, \"When the well is destroyed, the souls within will be released to float aimlessly upon the ether for a time. I have badly wronged the Lady Rowena and her husband, I would see this wrong mended. Please, lead her out of this dark place and see that she is reunited with Trent. That way they will remain together when they are released. I will know when you've accomplished this task, and then we can continue with the destruction of the well.\"")
        set_flag(0x01AE, true)
    elseif not get_flag(0x01A6) then
        say("\"But please, ", local0, ", I beg thee make haste. Take Rowena to Trent! Time is short! Talk to her and take her to her husband! The souls in the well are constantly in pain, and some become so drained that they are snuffed out of existence like the flame of a candle.\" He looks as if he feels the pain himself.")
    elseif not get_flag(0x0198) then
        call_08AFH()
    else
        say("\"Good, now we can get on with freeing the rest of Skara Brae. The destruction of the Well of Souls can only be brought about by the selfless sacrifice of a spirit. A living being will not do, because the soul is tied to the body.~~Go out into the town and find a spirit willing to make the sacrifice for the sake of all Skara Brae. I suggest that thou shouldst ask Mayor Forsythe first, as it is his right to be considered before the others.\" He strokes his chin thoughtfully as you leave.")
        set_flag(0x0198, true)
    end

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