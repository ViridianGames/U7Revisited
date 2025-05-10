--- Best guess: Manages Horance’s dialogue in Skara Brae, guiding the player through a quest to destroy the Well of Souls, with flag-based progression and NPC interactions.
function func_08AD()
    start_conversation()
    local var_0000, var_0001, var_0002, var_0003

    unknown_0003H(1, -141)
    var_0000 = get_lord_or_lady()
    var_0001 = unknown_0908H()
    if not get_flag(429) then
        set_flag(429, true)
        add_dialogue("\"I thank thee, " .. var_0000 .. ". That dark spirit had suppressed my will for so long that I was not sure I had one left. Thou hast done a great deed for Skara Brae, for myself and, indeed, all of Britannia, but then I suppose this is merely a matter of course for one such as thee. My gratitude is thine.\" He bows deeply to you.")
        if not get_flag(3) then
            add_dialogue("\"But now, I fear that all is still not right with the world. The ether stirs chaotically outside of this Dark Tower. Were it not for some property within the walls, I fear my mind would suffer the ravages of its force.\"")
        end
    else
        if get_flag(465) then
            var_0002 = "Hast thou reconsidered my request?"
        else
            var_0002 = ""
        end
        add_dialogue("\"It is good to see thee again, " .. var_0001 .. "." .. var_0002 .. "\"")
    end
    if get_flag(465) then
        var_0003 = "Ah, I see. No matter"
        unknown_08AEH(var_0003)
    end
    if not get_flag(428) then
        if not get_flag(465) then
            add_dialogue("\"Now, " .. var_0000 .. ". I must ask this favor of thee. The Well of Souls, at the bottom of this tower, holds many tormented souls within it and binds the spirits of Skara Brae to this island. It must be destroyed.\" Horance looks at you intently.~~\"I can only hope that thou wilt try to free them.\"")
            add_dialogue("\"Well, wilt thou?\" He looks at you expectantly.")
            var_0003 = "I understand. Fear not"
            unknown_08AEH(var_0003)
        end
    end
    if not get_flag(430) then
        add_dialogue("Horance thinks for a moment then, \"When the well is destroyed, the souls within will be released to float aimlessly upon the ether for a time. I have badly wronged the Lady Rowena and her husband, I would see this wrong mended. Please, lead her out of this dark place and see that she is reunited with Trent. That way they will remain together when they are released. I will know when you've accomplished this task, and then we can continue with the destruction of the well.\"")
        set_flag(430, true)
    elseif not get_flag(422) then
        add_dialogue("\"But please, " .. var_0000 .. ", I beg thee make haste. Take Rowena to Trent! Time is short! Talk to her and take her to her husband! The souls in the well are constantly in pain, and some become so drained that they are snuffed out of existence like the flame of a candle.\" He looks as if he feels the pain himself.")
    elseif get_flag(408) then
        unknown_08AFH()
    else
        add_dialogue("\"Good, now we can get on with freeing the rest of Skara Brae. The destruction of the Well of Souls can only be brought about by the selfless sacrifice of a spirit. A living being will not do, because the soul is tied to the body.\"~~\"Go out into the town and find a spirit willing to make the sacrifice for the sake of all Skara Brae. I suggest that thou shouldst ask Mayor Forsythe first, as it is his right to be considered before the others.\" He strokes his chin thoughtfully as you leave.")
        set_flag(408, true)
    end
    return
end