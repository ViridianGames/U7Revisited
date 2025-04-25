-- Function 08F3: Manages Iolo's combat preference dialogue
function func_08F3(local0)
    -- Local variables (8 as per .localc)
    local local1, local2, local3, local4, local5, local6, local7, local8

    callis_0007()
    local1 = false
    local2 = false
    callis_0005({"bye", "valor in arms", "enchantment"})
    say("\"Tell me something, if thou please. Many years have passed since I first learned my woodcraft. Such craft includes skill in arms, and I must know... Does the Avatar prefer mystical enchantment to overcome enemies, or physical strength and valor in arms?\"")
    local3 = false

    while true do
        if cmp_strings("enchantment", 0x003A) then
            say("\"I have suspected it! No skill have I in such deep matters, but perchance our speech might turn to enchantment when our quest is complete.\"")
            set_flag(0x015E, true)
            break
        end
        if cmp_strings("valor in arms", 0x006C) then
            say("\"I have often suspected it! I am honored to travel with thee. I shall watch thee diligently, for surely thou art the greatest fighter who ever lived.\"")
            say("\"When our quest is complete we shall regale each other with our exploits. Tell me, dost thou prefer hand to hand combat or ranged weaponry?\"")
            callis_0006({"valor in arms", "enchantment"})
            callis_0005({"ranged weaponry", "hand to hand"})
            set_flag(0x015E, false)
            local1 = false
        end
        if cmp_strings("hand to hand", 0x00A8) then
            callis_0006("hand to hand")
            local4 = "and thou seemest man enough for such close work"
            if callis_005A() == 1 then
                local4 = "especially in women. The women of Britannia seldom have them"
                local2 = true
            end
            say("\"Such weapons require strength and daring! I admire such qualities, ", local4, ".\"")
            say("\"But my preferences run to the bow. An ancient weapon, and elegant, a fine bow of Yew may bring down game sooner than a sword.\"")
            local3 = true
        end
        if cmp_strings("ranged weaponry", 0x00C3) then
            callis_0006("ranged weaponry")
            say("\"Such is also my choice. Few are my peers in the art of archery. A keen eye and steady hand are required, and that is rare in the men of this day. Even rarer in women. Sad, that the women of Britannia should be innocent of such art!\"")
            local2 = true
            local3 = true
        end
        if local2 then
            local5 = false
            while sloop() do
                local7 = callis_0020(10, local8)
                if local7 == 1 then
                    local5 = true
                    break
                end
            end
            if local5 then
                callis_0003(0, local8)
                say("\"Take care with thy words, master woodsman.\"")
                callis_0003(0, -10)
                say("\"I do not mean this gracious company! Surely thou art among the elite of Britannia and a rare figure of a woman.\"")
                callis_0003(0, local8)
                say("\"Thy speech does me service. Alas! Too few are the women who learn skill in arms.\"")
                callis_0004(local8)
            end
        end
        if local3 then
            break
        end
        if cmp_strings("bye", 0x0153) then
            if not local1 then
                say("\"Please, Avatar, I simply must know.\"")
                local1 = true
            else
                abort()
            end
        end
        break
    end

    callis_0008()
    return
end

-- Helper functions
function say(...)
    print(table.concat({...}))
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

function sloop()
    return false -- Placeholder
end