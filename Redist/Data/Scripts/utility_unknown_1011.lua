--- Best guess: Manages a dialogue with Shamino discussing combat preferences (valor vs. enchantment, melee vs. ranged), with gender-specific responses and flag-based progression.
function utility_unknown_1011(var_0000)
    start_conversation()
    local var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    save_answers()
    var_0001 = false
    var_0002 = false
    add_answer({"bye", "valor in arms", "enchantment"})
    add_dialogue("\"Tell me something, if thou please. Many years have passed since I first learned my woodcraft. Such craft includes skill in arms, and I must know... Does the Avatar prefer mystical enchantment to overcome enemies, or physical strength and valor in arms?\"")
    var_0003 = false
    while true do
        if string.lower(unknown_XXXXH()) == "enchantment" then
            add_dialogue("\"I have suspected it! No skill have I in such deep matters, but perchance our speech might turn to enchantment when our quest is complete.\"")
            set_flag(350, true)
            break
        elseif string.lower(unknown_XXXXH()) == "valor in arms" then
            add_dialogue("\"I have often suspected it! I am honored to travel with thee. I shall watch thee diligently, for surely thou art the greatest fighter who ever lived.\"")
            add_dialogue("\"When our quest is complete we shall regale each other with our exploits. Tell me, dost thou prefer hand to hand combat or ranged weaponry?\"")
            remove_answer({"valor in arms", "enchantment"})
            add_answer({"ranged weaponry", "hand to hand"})
            set_flag(350, false)
            var_0001 = false
        elseif string.lower(unknown_XXXXH()) == "hand to hand" then
            remove_answer("hand to hand")
            var_0004 = "and thou seemest man enough for such close work"
            if is_player_female() == 1 then
                var_0004 = "especially in women. The women of Britannia seldom have them"
                var_0002 = true
            end
            add_dialogue("\"Such weapons require strength and daring! I admire such qualities, " .. var_0004 .. ".\"")
            add_dialogue("\"But my preferences run to the bow. An ancient weapon, and elegant, a fine bow of Yew may bring down game sooner than a sword.\"")
            var_0003 = true
        elseif string.lower(unknown_XXXXH()) == "ranged weaponry" then
            remove_answer("ranged weaponry")
            add_dialogue("\"Such is also my choice. Few are my peers in the art of archery. A keen eye and steady hand are required, and that is rare in the men of this day. Even rarer in women. Sad, that the women of Britannia should be innocent of such art!\"")
            var_0002 = true
            var_0003 = true
        elseif var_0002 then
            var_0002 = false
            var_0005 = false
            for _, var_0008 in ipairs(var_0003) do
                if get_npc_property(10, var_0008) == 1 then
                    var_0005 = true
                    break
                end
            end
            if var_0005 then
                switch_talk_to(var_0008)
                add_dialogue("\"Take care with thy words, master woodsman.\"")
                switch_talk_to(10)
                add_dialogue("\"I do not mean this gracious company! Surely thou art among the elite of Britannia and a rare figure of a woman.\"")
                switch_talk_to(var_0008)
                add_dialogue("\"Thy speech does me service. Alas! Too few are the women who learn skill in arms.\"")
                hide_npc(var_0008)
            end
        elseif var_0003 then
            break
        elseif string.lower(unknown_XXXXH()) == "bye" then
            if not var_0001 then
                add_dialogue("\"Please, Avatar, I simply must know.\"")
            else
                return
            end
            var_0001 = true
        end
    end
    restore_answers()
    return
end