-- Manages Grayson's dialogue in Britain, covering armour and weapons sales and Fellowship benefits.
function func_0437(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6

    if eventid == 1 then
        switch_talk_to(55, 0)
        local0 = get_item_type()
        local1 = get_party_size()
        local2 = switch_talk_to(55)

        if local1 == 7 then
            local3 = apply_effect(-26, -55) -- Unmapped intrinsic 08FC
            if local3 then
                add_dialogue("Grayson shushes you, as you are disturbing the Fellowship meeting.*")
                return
            elseif get_flag(218) then
                add_dialogue("\"Now where could that Batlin be? I suppose we shall have to have the meeting without him!\"")
            else
                add_dialogue("\"I must run! I must run! I must! I must! I am late for the Fellowship meeting!\"*")
                return
            end
        end

        local4 = get_player_name()

        add_answer({"bye", "job", "name"})

        if not get_flag(184) then
            add_dialogue("You see a shrewd-looking man who smiles as if he has just seen his next customer.")
            set_flag(184, true)
        else
            add_dialogue("\"Hello again, my good friend,\" says Grayson.")
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"I am Grayson, " .. local4 .. ". A humble and honest man.\"")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"Why, here in Britain I sell the best armour and weapons that money can buy. In my spare time, I do deeds for The Fellowship.\"")
                add_answer({"Fellowship", "buy"})
            elseif answer == "armour" then
                add_dialogue("Grayson looks you up and down. \"Dost thou truly believe that thou art sufficiently protected in what thou art wearing? In truth I fear for thy safety if thou shouldst become involved in combat. Are thou interested in buying something today?\"")
                if get_answer() then
                    buy_armour() -- Unmapped intrinsic 0897
                else
                    add_dialogue("\"Another time, then.\"")
                    restore_answers() -- Unmapped intrinsic
                end
                remove_answer("armour")
            elseif answer == "weapons" then
                add_dialogue("After looking at you, Grayson says, \"I can see that thou art in sore need of weaponry. Dost thou want to buy something today?\"")
                if get_answer() then
                    buy_weapons() -- Unmapped intrinsic 0898
                else
                    add_dialogue("\"Another time, then.\"")
                    restore_answers() -- Unmapped intrinsic
                end
                remove_answer("weapons")
            elseif answer == "buy" then
                add_dialogue("\"I sell a complete line of armour and weapons.\"")
                if local2 == 7 then
                    add_dialogue("\"Which wouldst thou care to inspect?\"")
                    save_answers() -- Unmapped intrinsic
                    add_answer({"weapons", "armour"})
                else
                    add_dialogue("\"Please come to the shop when it is open.\"")
                end
            elseif answer == "Fellowship" then
                if local0 then
                    add_dialogue("\"I see that thou art a member of The Fellowship!\"")
                end
                add_dialogue("\"It has been very beneficial in my life. I was on the verge of going out of business before I joined and now I am more prosperous than ever before.\"")
                remove_answer("Fellowship")
                add_answer({"out of business", "beneficial"})
            elseif answer == "beneficial" then
                add_dialogue("\"I was never sufficiently forward or aggressive enough to be successful as a merchant but The Fellowship changed all that for me.\"")
                remove_answer("beneficial")
                add_answer("changed")
            elseif answer == "changed" then
                add_dialogue("\"By applying the values of the Triad of Inner Strength to my life I have accomplished what I have set out to do with my life. Mine armour and weapon shop is successful and I have a place where I belong in The Fellowship.\"")
                remove_answer("changed")
            elseif answer == "out of business" then
                add_dialogue("\"Thou dost see, I am convinced that my failures were all due to my bad attitude. It took the teachings of The Fellowship to change the way I used my mind and to turn me in the proper direction.\"")
                remove_answer("out of business")
            elseif answer == "bye" then
                add_dialogue("\"Goodbye and farewell, " .. local4 .. ".\"*")
                break
            end
        end
    elseif eventid == 0 then
        local1 = get_party_size()
        local2 = switch_talk_to(55)
        local5 = random(1, 4)
        local6 = ""

        if local2 == 7 then
            if local5 == 1 then
                local6 = "@Weapons?@"
            elseif local5 == 2 then
                local6 = "@Armour?@"
            elseif local5 == 3 then
                local6 = "@Something to equip thee?@"
            elseif local5 == 4 then
                local6 = "@Need a weapon?@"
            end
            bark(55, local6)
        else
            switch_talk_to(55)
        end
    end
    return
end