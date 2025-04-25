-- Manages Dell's dialogue in Trinsic, covering his shopkeeping, Fellowship involvement, and dismissive murder attitude.
function func_0412(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9

    if eventid == 1 then
        switch_talk_to(-18, 0)
        local0 = get_schedule()
        local1 = get_player_name()
        local2 = get_player_name()
        local3 = switch_talk_to(-18)
        local4 = "Avatar"
        local5 = apply_effect(-16, -18) -- Unmapped intrinsic 08FC

        if local0 == 7 then
            if local5 then
                say("Dell frowns at you for distracting him during the Fellowship meeting.*")
            else
                say("\"I do not have time to talk with thee! I must get to the meeting of The Fellowship! Come to my shop tomorrow!\"*")
            end
            return
        end

        add_answer({"bye", "murder", "job", "name"})

        if not get_flag(83) then
            say("You see a stern shopkeeper who might once have been a strong fighter.")
            if local3 == 7 then
                say("\"Thou hast entered my shop, so thou had best buy something.\"")
            end
            say("\"Who might I be addressing?\"")
            local6 = get_answer({local4, local2})
            if local6 == local2 then
                say("\"Hmph. My name is Dell.\"")
            else
                say("\"Oh, art thou really? I did not know there were so many of thee! Why, only last week did an 'Avatar' come through here! He took me for 20 gold, too! An expert trickster, he was!\"~~Dell looks you up and down. \"Avatar, indeed! I do not like Avatars. But never mind that. I am called Dell. What dost thou want?\"")
            end
            set_flag(83, true)
        else
            say("\"How may I help thee?\" Dell asks.")
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                say("\"My name is Dell. Did I not say that already?\"")
                remove_answer("name")
            elseif answer == "job" then
                say("Dell looks disgruntled. \"I sell weapons, armour, and provisions when I am not doing work for The Fellowship.\"")
                add_answer("buy")
                if local3 == 7 then
                    say("\"If thou art not going to buy anything, then get thy face out of my sight!\"")
                end
                add_answer("Fellowship")
            elseif answer == "murder" then
                say("\"I am afraid I know nothing about it save for what is being said in the street, so do not ask me. If thou art not going to buy anything, then thou art wasting my time. Go away.\"")
                remove_answer("murder")
                local7 = get_item_type(-1)
                if local7 then
                    switch_talk_to(-1, 0)
                    say("Iolo whispers to you, \"Pleasant chap, is he not?\"")
                    hide_npc(-1)
                    switch_talk_to(-18, 0)
                end
            elseif answer == "Fellowship" then
                apply_effect() -- Unmapped intrinsic 0919
                remove_answer("Fellowship")
            elseif answer == "philosophy" then
                apply_effect() -- Unmapped intrinsic 091A
                remove_answer("philosophy")
            elseif answer == "buy" then
                if local3 == 7 then
                    say("\"Certainly, " .. local1 .. ". What type of ware wouldst thou wish to see?\"")
                    save_answers()
                    add_answer({"provisions", "armour", "weapons", "nothing"})
                    local answer = get_answer()
                    if answer == "weapons" then
                        buy_item("weapons") -- Unmapped intrinsic 0872
                    elseif answer == "armour" then
                        buy_item("armour") -- Unmapped intrinsic 0873
                    elseif answer == "provisions" then
                        buy_item("provisions") -- Unmapped intrinsic 0874
                    elseif answer == "nothing" then
                        restore_answers()
                    end
                else
                    say("\"Come to my shop during business hours.\"")
                end
            elseif answer == "bye" then
                say("\"Hmpf.\"")
                if local3 == 7 then
                    say("\"Spend more money next time thou dost come in.\"*")
                end
                break
            end
        end
    elseif eventid == 0 then
        local0 = get_schedule()
        local3 = switch_talk_to(-18)
        local8 = random(1, 4)
        local9 = check_item_state(-18)

        if local3 == 7 then
            if local8 == 1 then
                local9 = "@Buy something!@"
            elseif local8 == 2 then
                local9 = "@Armour! Weapons!@"
            elseif local8 == 3 then
                local9 = "@Swamp boots? Bedrolls?@"
            elseif local8 == 4 then
                local9 = "@Finest goods here!@"
            end
            item_say(local9, -18)
        else
            switch_talk_to(-18)
        end
    end
    return
end