require "U7LuaFuncs"
-- Function 08EF: Manages Trent's dialogue
function func_08EF()
    -- Local variables (6 as per .localc)
    local local0, local1, local2, local3, local4, local5

    local0 = callis_000E(-1, 747, -142)
    local1 = call_0909H()
    if not get_flag(0x01C1) then
        if get_flag(0x01A8) then
            if local0 then
                say("The large ghost continues to work, but now he whistles a sweet, sad tune as he hammers on the iron bars of the cage.")
            else
                say("\"Why, where has the cage gone to? 'Twas here just a moment ago, I am certain. I cannot progress until I can find the cage!\"")
                abort()
            end
        else
            say("Trent paces around the burned-out remains of his shop. When he sees you return, he rushes forward, looking for his love, Rowena.")
            local2 = callis_0023()
            if contains(-144, local2) then
                callis_001F(-144)
                say("The starcrossed lovers rush into each other's ghostly embrace. For a time it's hard to see where one spirit begins and the other ends. You barely make out the image of Trent replacing Rowena's ring on her finger.~~Then the two slowly turn to face you. \"Thou hast done so much for us, I hope that in helping us, thou hast been assisted in thine own quest.\" Trent bows to you then turns to regard his lovely wife.")
                callis_001D(15, -144)
                set_flag(0x01A6, true)
                abort()
            else
                say("\"How can I help thee, ", local1, "? Is there something I have forgotten?\" He looks at you, perplexed.")
            end
        end
    end

    callis_0005({"bye", "What next?"})
    if not get_flag(0x01C1) then
        callis_0005({"free", "Soul Cage"})
    end

    while true do
        if cmp_strings("Soul Cage", 0x00B2) then
            say("\"This is a special cage, made to fit the shape of a man. Mistress Mordra says that it will contain the Liche, Horance, once it has been lowered into his Well of Souls.\" His voice seems much softer than before.")
            callis_0006("Soul Cage")
        end
        if cmp_strings("free", 0x00DD) then
            say("\"Yes, thou wilt help me free her, wilt thou not?\" A tinge of the edge comes back to his voice.")
            local3 = call_090AH()
            if local3 then
                say("His grip on the haft of his hammer relaxes and he smiles with gratitude.~~\"Thou cannot know how much this means to me. I thank thee.\"")
            else
                say("His grip on the haft of his hammer tightens. \"See to it thou art quick about thy departure! If thou dost, I will assume thou hast changed thy mind!\"")
                abort()
            end
            callis_0006("free")
        end
        if cmp_strings("What next?", 0x0145) then
            local4 = call_0931H(-359, -359, 264, 1, -357)
            if get_flag(0x01A8) then
                if not local4 then
                    say("\"I will need a bar of iron to complete the cage. Several can be found in the town cemetery.\"")
                    callis_0006("What next?")
                else
                    say("\"Ah, I'll need the iron bar that thou dost carry.\" He holds out his hand and takes the iron bar from you.")
                    local5 = callis_002B(false, -359, -359, 264, 1)
                    say("\"With this, I will finish it shortly. Wait here whilst I tend to the cage.\"")
                    say("\"Take the cage to Mistress Mordra and she will tell thee more about it and its use.\"")
                    set_flag(0x01CF, true)
                    calle_0617H(itemref)
                    abort()
                end
            else
                say("\"Why, I beg thee to please help in the return my lovely Rowena to me,\" he pleads.")
            end
        end
        if cmp_strings("sacrifice", 0x0158) then
            say("\"I cannot even consider that until I am reunited with my love.\" He seems very adamant about this.")
            callis_0006("sacrifice")
        end
        if cmp_strings("bye", 0x0165) then
            say("\"Please, hurry. Every second my love must endure Horance's foul presence is like a knife in my side.\" He begins to pace about his shop.")
            abort()
        end
        break
    end

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

function cmp_strings(str, addr)
    return false -- Placeholder
end

function contains(item, list)
    return false -- Placeholder
end