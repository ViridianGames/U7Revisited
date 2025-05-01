-- Manages Mariah's dialogue in Moonglow, as a disoriented mage selling spells and reagents, commenting on the Lycaeum and her mental state.
function func_0499(eventid, itemref)
    local local0, local1, local2, local3, local4, local5

    if eventid ~= 1 then
        local3 = get_schedule(-153)
        switch_talk_to(153, 0)
        set_schedule(153, 11)
        if local3 == 11 then
            if not get_flag(3) then
                local4 = get_random(1, 4)
                if local4 == 1 then
                    local5 = "@Where -are- those pastries!@"
                elseif local4 == 2 then
                    local5 = "@Lovely, lovely shelves!@"
                elseif local4 == 3 then
                    local5 = "@Lovely, lovely ink wells!@"
                elseif local4 == 4 then
                    local5 = "@Magic is in the air...@"
                end
                item_say(local5, -153)
            else
                apply_effect(-153) -- Unmapped intrinsic
            end
        end
        return
    end

    switch_talk_to(153, 0)
    local0 = get_player_name()
    local1 = get_party_size()
    add_answer({"bye", "job", "name"})

    if not get_flag(507) then
        say("You see your old friend Mariah.")
        set_flag(507, true)
    elseif get_flag(3) then
        say("\"Yes, " .. local0 .. "? How may I help thee?\" Mariah greets you.")
    else
        say("\"Yes, " .. local1 .. "?\" Mariah smiles, a trifle too sweetly.")
    end

    if get_flag(3) then
        while true do
            local answer = get_answer()
            if answer == "name" then
                local2 = switch_talk_to(1)
                if local2 then
                    switch_talk_to(1, 0)
                    say("\"Surely thou dost recognize thine old companion, Mariah?\"*")
                    hide_npc(1)
                    switch_talk_to(153, 0)
                else
                    say("\"Hast thou already forgotten me, " .. local1 .. "? I am Mariah.\"")
                end
                remove_answer("name")
            elseif answer == "job" then
                say("\"I sell spells, reagents, and sometimes a few potions here at the Lycaeum. Dost thou wish to buy any of these, " .. local1 .. "?\"")
                add_answer({"Lycaeum", "potions", "reagents", "spells"})
            elseif answer == "spells" then
                buy_spell(-153) -- Unmapped intrinsic
            elseif answer == "reagents" then
                buy_reagent("Reagents") -- Unmapped intrinsic
            elseif answer == "potions" then
                say("\"I am afraid, " .. local1 .. ", that I have a very meager selection.\"")
                buy_reagent("Potions") -- Unmapped intrinsic
            elseif answer == "Lycaeum" then
                say("She shakes her head sadly. \"I have not been `myself' for so long that I no longer recognize this town.\" Her eyes widen.~~ \"There are so many buildings around the Lycaeum now, hast thou seen them?\"~~She pauses, looking at you.~~\"By the way, old friend. I assume thou art responsible for returning the ether to its normal state. I thank thee.\"")
                remove_answer("Lycaeum")
            elseif answer == "bye" then
                say("\"Fair days ahead, friend " .. local1 .. ".\"*")
                break
            end
        end
    else
        while true do
            local answer = get_answer()
            if answer == "name" then
                local2 = switch_talk_to(1)
                if local2 then
                    switch_talk_to(1, 0)
                    say("\"Surely thou dost recognize thine old companion, Mariah?\"*")
                    hide_npc(1)
                    switch_talk_to(153, 0)
                    say("\"Yes, dost thou not recognize me?\" She pauses, glaring at you. \"But who art thou, and where are my pastries?\"")
                else
                    say("\"Yes, thou mayest tell me thy name,\" she says, glancing around the building. \"Are not the many books beautiful?\"")
                end
                remove_answer("name")
            elseif answer == "job" then
                say("She smiles. \"I have a very important job, I do. My, are not those shelves lovely? So neat and orderly.\" She looks back at you.~~\"Be careful! The ink wells are full, and the quills so sharp.\" She giggles.")
                add_answer({"quills", "ink wells", "shelves"})
            elseif answer == "shelves" then
                say("\"Are not they the neatest, most orderly, and well-kept shelves thou hast seen? They do an excellent job of maintaining them!\"")
                add_answer("they")
                remove_answer("shelves")
            elseif answer == "ink wells" then
                say("\"They are always so full and ready for use. They are so good about keeping them filled and clean!\"")
                add_answer("they")
                remove_answer("ink wells")
            elseif answer == "quills" then
                say("\"Oh, yes, they are quite sharp! Always there when one needs to scribe a missive. They do an excellent job of having many ready at a moment's notice!\"")
                add_answer("they")
                remove_answer("quills")
            elseif answer == "they" then
                say("\"Yes, they do!\" Her face turns sad. \"But I only sell.\"")
                add_answer("sell")
                remove_answer("they")
            elseif answer == "sell" then
                say("\"Yes,\" she agrees, \"I do indeed sell. I even spell. In fact, I even sell spells! But, if thou desirest reagents, thou art out of luck, for I only sell those during one of the seven weekdays. Wouldst thou like to know which day?~~\"What a lovely set of books thou must have! I have just the item for thee to match thy shelves -- a potion. If thou wilt buy a spell or reagent from me, I will sell thee a potion for only its normal price!\"")
                add_answer({"potions", "reagents", "which day"})
                remove_answer("sell")
            elseif answer == "which day" then
                say("\"Why, today. Thou art in luck. Buy a spell.\"")
                buy_spell(-153) -- Unmapped intrinsic
                remove_answer("which day")
            elseif answer == "reagents" then
                buy_reagent("Reagents") -- Unmapped intrinsic
            elseif answer == "potions" then
                buy_reagent("Potions") -- Unmapped intrinsic
            elseif answer == "bye" then
                say("\"Certainly, come back anytime and buy.\"*")
                break
            end
        end
    end
    return
end