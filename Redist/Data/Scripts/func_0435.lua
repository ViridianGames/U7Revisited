--- Best guess: Handles dialogue with Gaye, the clothier in Britain, discussing her shop, Fellowship involvement, and relationship with Willy, offering Avatar costumes and clothing for sale.
function func_0435(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B

    start_conversation()
    if eventid == 1 then
        switch_talk_to(53, 0)
        var_0000 = get_lord_or_lady()
        var_0001 = unknown_0067H() --- Guess: Checks Fellowship membership
        var_0002 = unknown_003BH() --- Guess: Checks game state or timer
        var_0003 = unknown_001CH(53) --- Guess: Gets object state
        if var_0002 == 7 then
            var_0004 = unknown_08FCH(26, 53) --- Guess: Checks time for Fellowship meeting
            if var_0004 then
                add_dialogue("Gaye is watching the Fellowship meeting. She turns to you brusquely and puts a finger to her lips, gesturing for you to be silent.")
                abort()
            else
                if get_flag(218) then
                    add_dialogue("\"I cannot imagine where Batlin is. I am worried about him...\"")
                else
                    add_dialogue("\"I cannot speak now! I am on my way to the Fellowship meeting at the Hall!\"")
                end
                abort()
            end
        end
        add_answer({"bye", "job", "name"})
        if not get_flag(181) then
            add_answer("Willy")
        end
        if not get_flag(182) then
            add_dialogue("You see a woman who oozes partially sincere friendliness.")
            set_flag(182, true)
        else
            add_dialogue("\"Hello again, and what may I do for thee today?\" asks Gaye.")
        end
        while true do
            var_0005 = get_answer()
            if var_0005 == "name" then
                add_dialogue("\"My name is Gaye.\"")
                remove_answer("name")
            elseif var_0005 == "job" then
                add_dialogue("\"I oversee the clothier's here in Britain when I am not pursuing the teachings of The Fellowship.\"")
                add_answer({"Fellowship", "buy", "clothiers"})
            elseif var_0005 == "clothiers" then
                add_dialogue("\"At our clothier's shop we have the finest silks and garments to buy that thou hast ever seen, imported from every corner of Britannia to cater to all tastes.\"")
                remove_answer("clothiers")
            elseif var_0005 == "buy" then
                if var_0003 ~= 19 then
                    add_dialogue("\"I am so sorry, the clothier's shop is closed. Please return during our regular business hours. We are open from nine until six every day.\"")
                else
                    if not get_flag(103) then
                        add_dialogue("\"Do not tell me! Raymundo sent thee to get an Avatar costume! They cost thirty gold coins. Dost thou want one?\"")
                        var_0005 = select_option()
                        if var_0005 then
                            add_dialogue("She looks you up and down. \"Yes, I think we might be able to find something for thee.\"")
                            add_dialogue("After several minutes of rummaging through the store, Gaye returns. \"Here it is! Not many left-- we have had a run on them recently!\"")
                            var_0006 = unknown_0028(359, 359, 644, 357) --- Guess: Checks player inventory or gold
                            if var_0006 < 30 then
                                add_dialogue("\"Um. Perhaps thou couldst return when thou dost have enough gold.\" She lays the costume down and smiles.")
                            else
                                var_0007 = unknown_002C(false, 359, 359, 838, 1) --- Guess: Checks inventory space
                                if not var_0007 then
                                    add_dialogue("\"Oh. Thou canst not carry this with what thou art already carrying. Mayhaps thou couldst dispose of something and return for the costume.\"")
                                else
                                    add_dialogue("\"It is, indeed, a pleasure to do business with thee, O great Avatar!\" She grins and hands you the costume.")
                                    var_0008 = unknown_002B(true, 359, 359, 644, 30) --- Guess: Deducts gold and adds costume
                                    set_flag(104, true)
                                end
                            end
                        else
                            add_dialogue("\"'Tis strange! I thought for certain that thou wert the theatrical type!\"")
                            unknown_088EH() --- Guess: Processes clothing purchase
                        end
                    else
                        add_dialogue("\"Wouldst thou like to buy some clothing today?\"")
                        var_0009 = select_option()
                        if var_0009 then
                            add_dialogue("\"We have many nice clothes to choose from.\"")
                            unknown_088EH() --- Guess: Processes clothing purchase
                        else
                            add_dialogue("\"Thou mayest look around for thyself. If thou dost change thy mind be sure to let me know.\"")
                        end
                    end
                end
                remove_answer("buy")
            elseif var_0005 == "Fellowship" then
                if not var_0001 then
                    unknown_0919H() --- Guess: Explains Fellowship philosophy
                end
                add_dialogue("\"Thou wouldst want to attend the Fellowship meeting tonight at nine o'clock. It is always a moving experience to hear the words of Batlin, our founder.\"")
                remove_answer("Fellowship")
                remove_answer("philosophy")
            elseif var_0005 == "Willy" then
                add_dialogue("\"Yes, he is a very amusing fellow. I am quite taken with him and I do see him against my better judgment. He does not seem like the type to join The Fellowship, though. Since The Fellowship is my whole life, I do not know if there is a place in it for him. I have not made up my mind about that yet.\"")
                remove_answer("Willy")
            elseif var_0005 == "bye" then
                break
            end
        end
        add_dialogue("\"Good day, " .. var_0000 .. ".\"")
    elseif eventid == 0 then
        var_0002 = unknown_003BH() --- Guess: Checks game state or timer
        var_0003 = unknown_001CH(53) --- Guess: Gets object state
        if var_0003 == 19 then
            var_000A = random(1, 4)
            if var_000A == 1 then
                var_000B = "@Clothing? Boots?@"
            elseif var_000A == 2 then
                var_000B = "@Swamp boots?@"
            elseif var_000A == 3 then
                var_000B = "@Tunic? Dress?@"
            elseif var_000A == 4 then
                var_000B = "@Fine clothes here!@"
            end
            bark(53, var_000B)
        else
            unknown_092EH(53) --- Guess: Triggers a game event
        end
    end
end