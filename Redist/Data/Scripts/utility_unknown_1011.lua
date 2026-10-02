--- Ask the Avatar about combat preferences (enchantment vs valor, melee vs ranged).
--- Sets flag 350 when the Avatar prefers mystical enchantment.
function utility_unknown_1011(party_members)
    save_answers()
    clear_answers()
    add_answer({"bye", "valor in arms", "enchantment"})
    add_dialogue("\"Tell me something, if thou please. Many years have passed since I first learned my woodcraft. Such craft includes skill in arms, and I must know... Does the Avatar prefer mystical enchantment to overcome enemies, or physical strength and valor in arms?\"")

    local asked_again = false
    local discussed_women = false
    local finished_arms = false

    while true do
        local answer = get_answer()
        if type(answer) ~= "string" then
            answer = get_answer()
        end
        if type(answer) ~= "string" then
            break
        end
        local lower = string.lower(answer)

        if lower == "enchantment" then
            add_dialogue("\"I have suspected it! No skill have I in such deep matters, but perchance our speech might turn to enchantment when our quest is complete.\"")
            set_flag(350, true)
            break
        elseif lower == "valor in arms" then
            add_dialogue("\"I have often suspected it! I am honored to travel with thee. I shall watch thee diligently, for surely thou art the greatest fighter who ever lived.\"")
            add_dialogue("\"When our quest is complete we shall regale each other with our exploits. Tell me, dost thou prefer hand to hand combat or ranged weaponry?\"")
            remove_answer({"valor in arms", "enchantment"})
            add_answer({"ranged weaponry", "hand to hand"})
            set_flag(350, false)
            asked_again = false
        elseif lower == "hand to hand" then
            remove_answer("hand to hand")
            local qualifier = "and thou seemest man enough for such close work"
            if is_player_female() then
                qualifier = "especially in women. The women of Britannia seldom have them"
                discussed_women = true
            end
            add_dialogue("\"Such weapons require strength and daring! I admire such qualities, " .. qualifier .. ".\"")
            add_dialogue("\"But my preferences run to the bow. An ancient weapon, and elegant, a fine bow of Yew may bring down game sooner than a sword.\"")
            finished_arms = true
        elseif lower == "ranged weaponry" then
            remove_answer("ranged weaponry")
            add_dialogue("\"Such is also my choice. Few are my peers in the art of archery. A keen eye and steady hand are required, and that is rare in the men of this day. Even rarer in women. Sad, that the women of Britannia should be innocent of such art!\"")
            discussed_women = true
            finished_arms = true
        elseif discussed_women then
            discussed_women = false
            -- Optional party push-back from a female companion if one is present.
            local speaker = nil
            if npc_id_in_party(5) then
                speaker = 5 -- Jaana
            elseif npc_id_in_party(8) then
                speaker = 8 -- Julia
            elseif npc_id_in_party(9) then
                speaker = 9 -- Katrina
            end
            if speaker then
                second_speaker(speaker, 0, "\"Take care with thy words, master woodsman.\"")
                add_dialogue("\"I do not mean this gracious company! Surely thou art among the elite of Britannia and a rare figure of a woman.\"")
                second_speaker(speaker, 0, "\"Thy speech does me service. Alas! Too few are the women who learn skill in arms.\"")
            end
        elseif finished_arms then
            break
        elseif lower == "bye" then
            if not asked_again then
                add_dialogue("\"Please, Avatar, I simply must know.\"")
                asked_again = true
            else
                break
            end
        end
    end
    restore_answers()
end
