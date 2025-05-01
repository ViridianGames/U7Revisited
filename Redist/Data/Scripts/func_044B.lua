-- func_044B.lua
-- Rudyom's dialogue about magic, moongates, and blackrock

function func_044B(eventid)
    local answers = {}
    local flag_0065 = get_flag(0x0065) -- Moongates/blackrock topics
    local flag_00E7 = get_flag(0x00E7) -- First meeting
    local flag_0003 = get_flag(0x0003) -- Magic ether state
    local flag_0004 = get_flag(0x0004) -- Moongates gone
    local npc_id = -74 -- Rudyom's NPC ID

    if eventid == 1 then
        switch_talk_to(74, 0) -- Originally _SwitchTalkTo(0, npc_id), swapped and abs(npc_id)
        local var_0000 = call_extern(0x090A, 0) -- Unknown interaction
        local var_0001 = call_extern(0x08DB, 1) -- Spells interaction
        local var_0002 = call_extern(0x08DC, 2) -- Reagents interaction
        local var_0003 = call_extern(0x0911, 3) -- Unknown interaction

        add_answer("bye")
        add_answer("job")
        add_answer("name")
        if flag_0065 then
            add_answer("Moongates")
            add_answer("blackrock")
        end

        if not flag_00E7 then
            add_dialogue("This elderly mage looks older and more senile than when you last saw him.")
            set_flag(0x00E7, true)
        elseif not flag_0003 then
            add_dialogue("\"Who art thou?\" Rudyom asks. \"Oh -- I remember.\"")
        else
            add_dialogue("\"Hello again, Avatar!\" Rudyom says, beaming.")
        end

        while true do
            if #answers == 0 then
                add_dialogue("Rudyom looks confused. \"What was that? Let's try again.\"")
                add_answer("bye")
                add_answer("job")
                add_answer("name")
                if flag_0065 then
                    add_answer("Moongates")
                    add_answer("blackrock")
                end
            end

            local choice = get_answer(answers)
            if choice == "name" then
                add_dialogue("\"That I know. My name is Rudyom.\"")
                remove_answer("name")
            elseif choice == "job" then
                if not flag_0003 then
                    add_dialogue("\"I am not sure anymore. I was a powerful mage at one time! Now nothing works. Magic is afoul! I suppose I could sell thee some reagents and spells if thou dost want. And mind the carpet -- it does not work!\"")
                    add_answer("carpet")
                else
                    add_dialogue("\"I am a powerful mage! Magic is my milieu! I can sell thee spells or reagents.\"")
                end
                add_answer("reagents")
                add_answer("spells")
                add_answer("magic")
            elseif choice == "magic" then
                if not flag_0003 then
                    add_dialogue("\"I do not understand what is wrong. My magic does not work so well anymore.\"")
                else
                    add_dialogue("\"The ether is flowing freely! Magic is with us once again!\"")
                end
                remove_answer("magic")
            elseif choice == "carpet" then
                add_dialogue("\"The big blue carpet. 'Tis a flying carpet. It does not work like it should.\"")
                add_dialogue("Rudyom looks around and scratches his head.")
                add_dialogue("\"Funny. It was here a while ago. Oh! I remember now. Some adventurers borrowed my flying carpet a few weeks ago. When they returned they said they had lost it near Serpent's Spine. Somewhere in the vicinity of the Lost River. I suppose if thou didst want to go and find it, thou couldst keep it. It did not work very well. Perhaps thou canst make it work. I did not like the color, anyway!\"")
                remove_answer("carpet")
            elseif choice == "spells" then
                add_dialogue("\"Dost thou wish to buy some spells?\"")
                if call_extern(0x090A, var_0000) == 0 then
                    call_extern(0x08DB, var_0001)
                else
                    add_dialogue("\"Oh. Never mind, then.\"")
                end
            elseif choice == "reagents" then
                add_dialogue("\"Dost thou wish to buy some reagents?\"")
                if call_extern(0x090A, var_0000) == 0 then
                    call_extern(0x08DC, var_0002)
                else
                    add_dialogue("\"Oh. Never mind, then.\"")
                end
            elseif choice == "Moongates" then
                if flag_0004 then
                    add_dialogue("\"The Moongates are gone, vanished! I know not why. Perhaps the blackrock experiments disrupted them.\"")
                else
                    add_dialogue("\"Moongates? They still function, but the ether is unstable. Be cautious when traveling.\"")
                end
                remove_answer("Moongates")
            elseif choice == "blackrock" then
                add_dialogue("\"Blackrock is a curious substance. I was experimenting with it, but my notes are scattered. It has properties unlike any other material.\"")
                add_dialogue("\"Be wary, Avatar. Meddling with blackrock can have unforeseen consequences.\"")
                remove_answer("blackrock")
            elseif choice == "bye" then
                add_dialogue("\"Farewell, Avatar. May the ether guide thee.\"")
                break
            end
        end
    end
end