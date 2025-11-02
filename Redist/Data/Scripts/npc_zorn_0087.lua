--- Best guess: Handles dialogue with Zorn, Minoc's blacksmith, discussing his weapons and armour, the murders, Owen's monument, and crafting helmets from Caddellite to block the cube generator's sound.
function npc_zorn_0087(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009

    start_conversation()
    if eventid == 1 then
        switch_talk_to(87)
        var_0000 = get_lord_or_lady()
        var_0001 = get_schedule(87) --- Guess: Checks game state or timer
        var_0002 = get_schedule_type(87) --- Guess: Gets object state
        var_0003 = utility_unknown_1073(359, 359, 728, 1, 357) --- Guess: Checks item in inventory
        if var_0003 then
            add_answer("Caddellite")
        end
        if not get_flag(274) then
            add_dialogue("You see a man whose long hours of difficult, smouldering work have frozen his face into a rigid expression with eyes like hot coals.")
            set_flag(274, true)
        else
            add_dialogue("\"How may I serve thee?\" says Zorn.")
        end
        add_answer({"bye", "job", "name"})
        while true do
            var_0004 = get_answer()
            if var_0004 == "name" then
                add_dialogue("\"I am Zorn.\"")
                remove_answer("name")
            elseif var_0004 == "job" then
                if not get_flag(287) then
                    add_dialogue("\"I am the blacksmith of Minoc.\"")
                    add_answer({"Minoc", "blacksmith"})
                else
                    add_dialogue("\"Dost thou have no respect for the dead? Indeed, trying to solicit at a terrible time like this! When people have been found murdered over at William's sawmill!\"")
                    set_flag(287, true)
                    add_answer("murders")
                end
            elseif var_0004 == "blacksmith" then
                add_dialogue("\"I make weapons and armour.\"")
                remove_answer("blacksmith")
                add_answer("weapons and armour")
            elseif var_0004 == "Minoc" then
                add_dialogue("\"Minoc is quite a city. Money changes hands here. But it does not keep people happy. They find something to squabble over. And now these terrible murders have everyone afraid.\"")
                remove_answer("Minoc")
                add_answer({"murders", "squabble"})
            elseif var_0004 == "weapons and armour" then
                if var_0002 == 13 then
                    add_dialogue("\"All of the weapons and armour I sell are made by mine own hand. They would serve thee well.\"")
                    add_answer({"buy armour", "buy weapons"})
                else
                    add_dialogue("\"Perhaps we could speak more of these things another time. Say, perhaps during the business hours of my shop?\"")
                end
                remove_answer("weapons and armour")
            elseif var_0004 == "buy weapons" then
                if var_0002 ~= 13 then
                    add_dialogue("\"The smithy is currently closed for outside business. Thou shalt have to return some other time.\"")
                else
                    add_dialogue("\"I have an assortment of very lethal weapons to show thee.\"")
                    utility_unknown_1106() --- Guess: Purchases weapons
                end
            elseif var_0004 == "buy armour" then
                if var_0002 ~= 13 then
                    add_dialogue("\"The smithy is currently closed for outside business. Thou shalt have to return some other time.\"")
                else
                    add_dialogue("\"Thou mayest buy fine armour from me.\"")
                    utility_unknown_1107() --- Guess: Purchases armour
                end
            elseif var_0004 == "squabble" then
                add_dialogue("\"This noise over Owen's monument, for instance. People ought to tend to their own business and let others handle their own, foolish or not.\"")
                add_answer({"monument", "Owen"})
                remove_answer("squabble")
            elseif var_0004 == "Owen" then
                add_dialogue("\"He is our town shipwright. He is a man who has an exceedingly high opinion of himself.\"")
                remove_answer("Owen")
            elseif var_0004 == "monument" then
                add_dialogue("\"Owen is building a monument to himself. It is forty feet tall, depicting him holding up a roll of plans. Pigeons will have a place to sit, forevermore. Why argue over something as unimportant as that?\"")
                remove_answer("monument")
            elseif var_0004 == "murders" then
                add_dialogue("\"No one in this town ever really hated the gypsies, at least not that I have ever been aware of. Who could have done such a thing?\"")
                remove_answer("murders")
            elseif var_0004 == "Caddellite" then
                add_dialogue("You present the Caddellite to Zorn. \"This is amazing! Why I thought that the only place to find Caddellite was the lost island of Ambrosia. What should I make with this?\"")
                remove_answer("Caddellite")
                add_answer("helmet")
            elseif var_0004 == "helmet" then
                add_dialogue("You describe the sort of helmet that you require, one that can block out the dangerous sound from the cube generator. Zorn nods. \"Yes, I can make some for thee. I shall start work immediately.\"")
                var_0004 = get_party_members()
                var_0004 = #var_0004
                var_0005 = count_objects(359, 359, 728, 357) --- Guess: Counts items
                if var_0005 == 0 then
                    add_dialogue("\"But thou dost not have any Caddellite chunks with which to make helmets!\"")
                elseif var_0004 > var_0005 then
                    add_dialogue("\"Thou hast " .. var_0004 .. " in thy party. I am afraid thou does not have enough Caddellite for me to make that many helmets.\"")
                else
                    var_0006 = remove_party_items(false, 359, 359, 728, var_0005) --- Guess: Deducts item and adds item
                    if var_0005 == 1 then
                        add_dialogue("Zorn takes the Caddellite from you and begins his work.")
                    else
                        add_dialogue("\"Thou hast " .. var_0005 .. " Caddellite chunks. That is how many helmets I can make for thee.\"")
                    end
                    add_dialogue("Zorn takes the Caddellite from you and begins his work. You watch in fascination as the master blacksmith softens the ore in the fire, then molds it into shape. Zorn quickly takes the necessary measurements, then makes some adjustments with the hot material. Finally, it is done.")
                    if var_0005 == 1 then
                        add_dialogue("Zorn dips the helmet in water to cool it.")
                    else
                        add_dialogue("Zorn dips the helmets in water to cool them.")
                    end
                    var_0007 = add_party_items(false, 359, 359, 638, var_0005) --- Guess: Checks inventory space
                    if var_0007 then
                        set_flag(262, true)
                        utility_unknown_1041(200) --- Guess: Submits item or advances quest
                        add_dialogue("\"Here, I have met thy request to thy precise specifications.\"")
                        if var_0005 == 1 then
                            add_dialogue("He hands you the helmet.")
                        else
                            add_dialogue("He hands you the helmets.")
                        end
                    else
                        add_dialogue("\"Thou art too encumbered!\"")
                    end
                end
                remove_answer("helmet")
            elseif var_0004 == "bye" then
                break
            end
        end
        add_dialogue("\"Goodbye, " .. var_0000 .. ".\"")
    elseif eventid == 0 then
        var_0002 = get_schedule_type(87) --- Guess: Gets object state
        if var_0002 == 13 then
            var_0008 = random(1, 4)
            if var_0008 == 1 then
                var_0009 = "@Weapons?@"
            elseif var_0008 == 2 then
                var_0009 = "@Armour?@"
            elseif var_0008 == 3 then
                var_0009 = "@Helms? Shields?@"
            elseif var_0008 == 4 then
                var_0009 = "@Need armour or weapons?@"
            end
            bark(87, var_0009)
        else
            utility_unknown_1070(87) --- Guess: Triggers a game event
        end
    end
end