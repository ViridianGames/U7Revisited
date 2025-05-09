--- Best guess: Handles dialogue with Mariah, a mage at the Lycaeum in Moonglow, discussing her spell and potion sales, her disorientation, and her appreciation for the library's shelves and quills.
function func_0499(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    start_conversation()
    if eventid == 1 then
        switch_talk_to(153, 0)
        var_0000 = get_player_title()
        var_0001 = unknown_0908H() --- Guess: Gets player info
        add_answer({"bye", "job", "name"})
        if not get_flag(507) then
            add_dialogue("You see your old friend Mariah.")
            set_flag(507, true)
        else
            if get_flag(3) then
                add_dialogue("\"Yes, " .. var_0000 .. "?\" Mariah smiles, a trifle too sweetly.")
            else
                add_dialogue("\"Yes, " .. var_0001 .. "? How may I help thee?\" Mariah greets you.")
            end
        end
        if not get_flag(3) then
            while true do
                var_0002 = get_answer()
                if var_0002 == "name" then
                    var_0003 = unknown_08F7H(1) --- Guess: Checks player status
                    if var_0003 then
                        switch_talk_to(1, 0)
                        add_dialogue("\"Surely thou dost recognize thine old companion, Mariah?\"")
                        hide_npc(1)
                        switch_talk_to(153, 0)
                    else
                        add_dialogue("\"Hast thou already forgotten me, " .. var_0001 .. "? I am Mariah.\"")
                    end
                    remove_answer("name")
                elseif var_0002 == "job" then
                    add_dialogue("\"I sell spells, reagents, and sometimes a few potions here at the Lycaeum. Dost thou wish to buy any of these, " .. var_0001 .. "?\"")
                    add_answer({"Lycaeum", "potions", "reagents", "spells"})
                elseif var_0002 == "spells" then
                    unknown_08BBH(153) --- Guess: Buys spells
                elseif var_0002 == "reagents" then
                    unknown_08BCH("Reagents") --- Guess: Buys reagents or potions
                elseif var_0002 == "potions" then
                    add_dialogue("\"I am afraid, " .. var_0001 .. ", that I have a very meager selection.\"")
                    unknown_08BCH("Potions") --- Guess: Buys reagents or potions
                elseif var_0002 == "Lycaeum" then
                    add_dialogue("She shakes her head sadly. \"I have not been `myself' for so long that I no longer recognize this town.\" Her eyes widen.")
                    add_dialogue("\"There are so many buildings around the Lycaeum now, hast thou seen them?\"")
                    add_dialogue("She pauses, looking at you.")
                    add_dialogue("\"By the way, old friend. I assume thou art responsible for returning the ether to its normal state. I thank thee.\"")
                    remove_answer("Lycaeum")
                elseif var_0002 == "bye" then
                    add_dialogue("\"Fair days ahead, friend " .. var_0001 .. ".\"")
                    abort()
                end
            end
        else
            while true do
                var_0002 = get_answer()
                if var_0002 == "name" then
                    var_0003 = unknown_08F7H(1) --- Guess: Checks player status
                    if var_0003 then
                        switch_talk_to(1, 0)
                        add_dialogue("\"Surely thou dost recognize thine old companion, Mariah?\"")
                        hide_npc(1)
                        switch_talk_to(153, 0)
                        add_dialogue("\"Yes, dost thou not recognize me?\" She pauses, glaring at you. \"But who art thou, and where are my pastries?\"")
                    else
                        add_dialogue("\"Yes, thou mayest tell me thy name,\" she says, glancing around the building. \"Are not the many books beautiful?\"")
                    end
                    remove_answer("name")
                elseif var_0002 == "job" then
                    add_dialogue("She smiles. \"I have a very important job, I do. My, are not those shelves lovely? So neat and orderly.\" She looks back at you.")
                    add_dialogue("\"Be careful! The ink wells are full, and the quills so sharp.\" She giggles.")
                    add_answer({"quills", "ink wells", "shelves"})
                elseif var_0002 == "shelves" then
                    add_dialogue("\"Are not they the neatest, most orderly, and well-kept shelves thou hast seen? They do an excellent job of maintaining them!\"")
                    add_answer("they")
                    remove_answer("shelves")
                elseif var_0002 == "ink wells" then
                    add_dialogue("\"They are always so full and ready for use. They are so good about keeping them filled and clean!\"")
                    add_answer("they")
                    remove_answer("ink wells")
                elseif var_0002 == "quills" then
                    add_dialogue("\"Oh, yes, they are quite sharp! Always there when one needs to scribe a missive. They do an excellent job of having many ready at a moment's notice!\"")
                    add_answer("they")
                    remove_answer("quills")
                elseif var_0002 == "they" then
                    add_dialogue("\"Yes, they do!\" Her face turns sad. \"But I only sell.\"")
                    add_answer("sell")
                    remove_answer("they")
                elseif var_0002 == "sell" then
                    add_dialogue("\"Yes,\" she agrees, \"I do indeed sell. I even spell. In fact, I even sell spells! But, if thou desirest reagents, thou art out of luck, for I only sell those during one of the seven weekdays. Wouldst thou like to know which day?\"")
                    add_dialogue("\"What a lovely set of books thou must have! I have just the item for thee to match thy shelves -- a potion. If thou wilt buy a spell or reagent from me, I will sell thee a potion for only its normal price!\"")
                    add_answer({"potions", "reagents", "which day"})
                    remove_answer("sell")
                elseif var_0002 == "which day" then
                    add_dialogue("\"Why, today. Thou art in luck. Buy a spell.\"")
                    unknown_08BBH(153) --- Guess: Buys spells
                    remove_answer("which day")
                elseif var_0002 == "reagents" then
                    unknown_08BCH("Reagents") --- Guess: Buys reagents or potions
                elseif var_0002 == "potions" then
                    unknown_08BCH("Potions") --- Guess: Buys reagents or potions
                elseif var_0002 == "bye" then
                    add_dialogue("\"Certainly, come back anytime and buy.\"")
                    abort()
                end
            end
        end
    elseif eventid == 0 then
        var_0003 = unknown_001CH(153) --- Guess: Gets schedule
        var_0004 = random(1, 4)
        if var_0003 == 11 then
            if not get_flag(3) then
                if var_0004 == 1 then
                    var_0005 = "@Where -are- those pastries!@"
                elseif var_0004 == 2 then
                    var_0005 = "@Lovely, lovely shelves!@"
                elseif var_0004 == 3 then
                    var_0005 = "@Lovely, lovely ink wells!@"
                elseif var_0004 == 4 then
                    var_0005 = "@Magic is in the air...@"
                end
                bark(153, var_0005)
            else
                unknown_092EH(153) --- Guess: Triggers game event
            end
        end
    end
end