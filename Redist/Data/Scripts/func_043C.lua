-- func_043C.lua
-- Mack's dialogue near Britain


function func_043C(eventid)
    local answers = {}
    local flag_00B3 = get_flag(0x00B3) -- First meeting
    local flag_008A = get_flag(0x008A) -- UFO topic
    local npc_id = -50 -- Mack's NPC ID

    if eventid == 1 then
        _SwitchTalkTo(0, npc_id)
        local var_0000 = call_extern(0x0909, 0) -- Unknown interaction
        local var_0001 = call_extern(0x090A, 1) -- Item interaction
        local var_0002 = call_extern(0x092E, 2) -- Unknown interaction

        add_answer( "bye")
        add_answer( "job")
        add_answer( "name")
        if flag_008A then
            add_answer( "UFO")
        end

        if not flag_00B3 then
            add_dialogue("You see a wiry farmer with wild eyes, clutching a turnip like it’s gold.")
            set_flag(0x00B3, true)
        else
            add_dialogue("\"Back again, \" .. get_player_name() .. \"?\" Mack says, eyeing you suspiciously.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Mack scratches his head. \"What’s that? Got more questions?\"")
                add_answer( "bye")
                add_answer( "job")
                add_answer( "name")
            end

            local choice = get_answer(answers)
            if choice == "name" then
                add_dialogue("\"Mack’s my name! Farmer, inventor, and truth-seeker!\"")
                remove_answer("name")
            elseif choice == "job" then
                add_dialogue("\"I farm turnips, best in Britannia! Also tinker with inventions. Made a contraption to scare crows, but it scares me too sometimes.\"")
                add_answer( "turnips")
                add_answer( "inventions")
            elseif choice == "turnips" then
                add_dialogue("\"My turnips are the finest! Big, juicy, and full of secrets. Want one? Only 3 gold!\"")
                add_answer( "buy")
                remove_answer("turnips")
            elseif choice == "inventions" then
                add_dialogue("\"Got a plow-sharpening machine and a chicken feeder. But my pride’s the Great Hoe—cuts weeds like magic! Still working out the kinks, though.\"")
                add_answer( "Great Hoe")
                remove_answer("inventions")
            elseif choice == "Great Hoe" then
                add_dialogue("\"It’s a marvel! Sharpens itself, but sometimes it wanders off. Found it in the barn once, hoeing by itself!\"")
                remove_answer("Great Hoe")
            elseif choice == "buy" then
                add_dialogue("\"A turnip for 3 gold. Deal?\"")
                local response = call_extern(0x090A, var_0001)
                if response == 0 then
                    local gold_result = U7.removeGold(3)
                    if gold_result then
                        local item_result = U7.giveItem(16, 1, 380)
                        if item_result then
                            add_dialogue("\"Here’s thy turnip! Guard it well!\"")
                        else
                            add_dialogue("\"Thou art too weighed down to carry this turnip!\"")
                        end
                    else
                        add_dialogue("\"No gold, no turnip. Come back when thou art richer!\"")
                    end
                else
                    add_dialogue("\"Suit thyself, but thou art missing out!\"")
                end
                remove_answer("buy")
            elseif choice == "UFO" then
                add_dialogue("\"Thou knowest about the lights in the sky? I saw one, big as a barn, hovering over my field! It left strange marks in the dirt. The turnips there grew twice as big!\"")
                add_answer( "lights")
                add_answer( "marks")
                remove_answer("UFO")
            elseif choice == "lights" then
                add_dialogue("\"Bright, pulsing lights, not like any star. Moved too fast to be a bird or balloon. I’m telling thee, it was no natural thing!\"")
                remove_answer("lights")
            elseif choice == "marks" then
                add_dialogue("\"Circles in the dirt, perfect as a compass. I keep ‘em hidden under hay. If thou findest a strange metal piece, bring it to me!\"")
                add_answer( "metal piece")
                remove_answer("marks")
            elseif choice == "metal piece" then
                add_dialogue("\"A shiny bit, like no metal I’ve seen. If thou bringest me one, I’ll trade thee something special—maybe a turnip or two!\"")
                local item_check = U7.hasItem(16, 1, 381)
                if item_check then
                    local trade_result = U7.removeItem(16, 1, 381)
                    if trade_result then
                        local item_result = U7.giveItem(16, 2, 380)
                        if item_result then
                            add_dialogue("\"By the Virtues, thou found it! Here’s two turnips for thy trouble!\"")
                        else
                            add_dialogue("\"Thou canst not carry more turnips! Clear some space!\"")
                        end
                    end
                else
                    add_dialogue("\"No metal piece? Keep an eye out, friend!\"")
                end
                remove_answer("metal piece")
            elseif choice == "bye" then
                add_dialogue("\"Watch the skies, \" .. get_player_name() .. \"!\"")
                break
            end
        end
    elseif eventid == 0 then
        call_extern(0x092E, npc_id)
    end
end

return func_043C