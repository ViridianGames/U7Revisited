-- Manages Gaye's dialogue in Britain, covering clothier operations, clothing sales, Willy's interest, and Fellowship activities.
function func_0435(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11

    if eventid == 1 then
        switch_talk_to(-53, 0)
        local0 = get_player_name()
        local1 = get_item_type()
        local2 = get_party_size()
        local3 = switch_talk_to(-53)

        if local3 == 7 then
            local4 = apply_effect(-26, -53) -- Unmapped intrinsic 08FC
            if local4 then
                say("Gaye is watching the Fellowship meeting. She turns to you brusquely and puts a finger to her lips, gesturing for you to be silent.*")
                return
            elseif get_flag(218) then
                say("\"I cannot imagine where Batlin is. I am worried about him...\"")
            else
                say("\"I cannot speak now! I am on my way to the Fellowship meeting at the Hall!\"*")
                return
            end
        end

        add_answer({"bye", "job", "name"})

        if not get_flag(182) then
            add_answer("Willy")
        end

        if not get_flag(182) then
            say("You see a woman who oozes partially sincere friendliness.")
            say("His eyes widen at the sight of you.")
            say("\"I had heard thou were travelling in Britannia again, but it took mine own eyes to believe it! Welcome, Avatar!\"")
            set_flag(182, true)
        else
            say("\"Hello again, and what may I do for thee today?\" asks Gaye.")
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                say("\"My name is Gaye.\"")
                remove_answer("name")
            elseif answer == "job" then
                say("\"I oversee the clothier's here in Britain when I am not pursuing the teachings of The Fellowship.\"")
                add_answer({"Fellowship", "buy", "clothiers"})
            elseif answer == "clothiers" then
                say("\"At our clothier's shop we have the finest silks and garments to buy that thou hast ever seen, imported from every corner of Britannia to cater to all tastes.\"")
                remove_answer("clothiers")
            elseif answer == "buy" then
                if local3 ~= 19 then
                    say("\"I am so sorry, the clothier's shop is closed. Please return during our regular business hours. We are open from nine until six every day.\"")
                else
                    if not get_flag(103) then
                        say("\"Do not tell me! Raymundo sent thee to get an Avatar costume! They cost thirty gold coins. Dost thou want one?\"")
                        local5 = get_answer()
                        if local5 then
                            say("She looks you up and down. \"Yes, I think we might be able to find something for thee.\"~~After several minutes of rummaging through the store, Gaye returns. \"Here it is! Not many left-- we have had a run on them recently!\"")
                            local6 = get_gold(-359, -359, 644, -357) -- Unmapped intrinsic
                            if local6 < 30 then
                                say("\"Um. Perhaps thou couldst return when thou dost have enough gold.\" She lays the costume down and smiles.")
                            else
                                local7 = add_item(-359, -359, 838, 1) -- Unmapped intrinsic
                                if not local7 then
                                    say("\"Oh. Thou canst not carry this with what thou art already carrying. Mayhaps thou couldst dispose of something and return for the costume.\"")
                                else
                                    say("\"It is, indeed, a pleasure to do business with thee, O great Avatar!\" She grins and hands you the costume.")
                                    set_flag(104, true)
                                    remove_gold(-359, -359, 644, 30) -- Unmapped intrinsic
                                end
                            end
                        else
                            say("\"'Tis strange! I thought for certain that thou wert the theatrical type!\"")
                            buy_clothing() -- Unmapped intrinsic 088E
                        end
                    else
                        say("\"Wouldst thou like to buy some clothing today?\"")
                        local9 = get_answer()
                        if local9 then
                            say("\"We have many nice clothes to choose from.\"")
                            buy_clothing() -- Unmapped intrinsic 088E
                        else
                            say("\"Thou mayest look around for thyself. If thou dost change thy mind be sure to let me know.\"")
                        end
                    end
                end
                remove_answer("buy")
            elseif answer == "Fellowship" then
                if not local1 then
                    fellowship_invitation() -- Unmapped intrinsic 0919
                end
                say("\"Thou wouldst want to attend the Fellowship meeting tonight at nine o'clock. It is always a moving experience to hear the words of Batlin, our founder.\"")
                remove_answer("Fellowship")
                remove_answer("philosophy")
            elseif answer == "Willy" then
                say("\"Yes, he is a very amusing fellow. I am quite taken with him and I do see him against my better judgment. He does not seem like the type to join The Fellowship, though. Since The Fellowship is my whole life, I do not know if there is a place in it for him. I have not made up my mind about that yet.\"")
                remove_answer("Willy")
            elseif answer == "bye" then
                say("\"Good day, " .. local0 .. ".\"*")
                break
            end
        end
    elseif eventid == 0 then
        local2 = get_party_size()
        local3 = switch_talk_to(-53)
        local10 = random(1, 4)
        local11 = ""

        if local3 == 19 then
            if local10 == 1 then
                local11 = "@Clothing? Boots?@"
            elseif local10 == 2 then
                local11 = "@Swamp boots?@"
            elseif local10 == 3 then
                local11 = "@Tunic? Dress?@"
            elseif local10 == 4 then
                local11 = "@Fine clothes here!@"
            end
            item_say(local11, -53)
        else
            switch_talk_to(-53)
        end
    end
    return
end