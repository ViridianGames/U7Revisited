--- Best guess: Handles dialogue with Nicodemus, a quirky mage in Yew, discussing his failing magic, selling potions, reagents, and spells, and enchanting an hourglass for the Time Lord, with references to Knight’s Bridge games.
function func_0466(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B

    start_conversation()
    if eventid == 0 then
        abort()
    end
    switch_talk_to(102, 0)
    var_0000 = get_player_name()
    add_answer({"bye", "job", "name"})
    var_0001 = get_party_members()
    var_0002 = unknown_0028H(0, 359, 839, 357) --- Guess: Counts items
    if not get_flag(466) then
        add_answer({"Time Lord", "hourglass"})
    end
    if var_0002 or get_flag(529) then
        add_answer("enchant")
    end
    if not get_flag(320) then
        add_dialogue("Your old friend Nicodemus has a far away look in his eyes.")
        set_flag(320, true)
    else
        if not get_flag(3) then
            add_dialogue("\"Who art thou?\" Nicodemus asks. \"Oh, I remember. Remember demember! Ha ha ha!\"")
        else
            add_dialogue("\"Hello again, " .. var_0000 .. ",\" says Nicodemus.")
        end
    end
    while true do
        var_0003 = get_answer()
        if var_0003 == "name" then
            if not get_flag(3) then
                add_dialogue("\"That is a very good question. Some days I can actually remember. Let's see... today... Yes! I am Nicodemus! Nicodomus! Nicodimus! Nico-nico-kukodamus! Ha ha ha!\"")
            else
                add_dialogue("\"Thou art addressing Nicodemus.\"")
            end
            remove_answer("name")
        elseif var_0003 == "job" then
            if not get_flag(3) then
                add_dialogue("\"To go absolutely mad! For that is indeed what is happening! My magic no longer works! Every time I attempt to change something into a drake, it only becomes a newt! Oh, newty-wewty scooty-booty!\" He speaks to an imaginary creature beside him. \"Who asked thee? Away with thee!\" He turns to you. \"Sorry. That bloody newt keeps trying to undermine my conversation. Anyway... I suppose I can sell thee some reagents, potions, or spells. I must make a living somecow. I mean somehow! That was Some Cow! Ha ha ha!\"")
                add_answer({"potions", "magic"})
            else
                add_dialogue("\"Why, to perform magic! It seems that the disturbance in the ether has been repaired! I can also sell thee some reagents or spells.\"")
            end
            add_answer({"reagents", "spells"})
        elseif var_0003 == "magic" then
            if not get_flag(3) then
                add_dialogue("\"Magic? What magic!? All the magic in the world has gone completely topsy-turvy! Oh, blurpsy-flurpsy! Ha ha ha! Those are silly words, are they not? 'Tis a pity they are not magical! Ha ha ha!\"")
            else
                add_dialogue("\"The ether is repaired. The mages of the world are indebted to thee.\"")
            end
            remove_answer("magic")
        elseif var_0003 == "spells" then
            add_dialogue("\"Dost thou wish to buy some spells?\"")
            var_0004 = select_option()
            if var_0004 then
                unknown_08C3H() --- Guess: Purchases spells
            else
                add_dialogue("\"Never mind, then!\"")
            end
        elseif var_0003 == "reagents" then
            add_dialogue("\"Dost thou wish to buy some reagents?\"")
            var_0005 = select_option()
            if var_0005 then
                unknown_08C4H() --- Guess: Purchases reagents
            else
                add_dialogue("\"Never mind, then!\"")
            end
        elseif var_0003 == "potions" then
            if not get_flag(3) then
                add_dialogue("\"Potions? What makes thee think I have potions? Art thou sure thou dost not want Lotions? I certainly have lotions! Otions, slotions, motions, votions! Ha ha ha! Wait! Oh, yes! I do have potions! I told thee so, didn't I! Let us see... I have this black potion here. I am not sure what it does exactly, but I am quite sure it turns one invisible.\"")
            else
                add_dialogue("\"Yes, I have potions. Well, I have this black one. It is an invisibility potion.\"")
            end
            add_dialogue("\"Dost thou want it for, say, 75 gold?\"")
            var_0006 = select_option()
            if var_0006 then
                if get_party_gold() >= 75 then
                    var_0007 = unknown_002CH(true, 7, 359, 340, 1) --- Guess: Checks inventory space
                    if var_0007 then
                        add_dialogue("\"Here is the potion.\"")
                        var_0008 = unknown_002BH(true, 359, 359, 644, 75) --- Guess: Deducts item and adds item
                    else
                        add_dialogue("\"Thou dost not have enough room to carry the potion!\"")
                    end
                else
                    add_dialogue("\"Art thou trying to cheat me? Thou dost not have enough gold!\"")
                end
            else
                add_dialogue("\"Then why didst thou mention it? Leave me alone!\"")
            end
            remove_answer("potions")
        elseif var_0003 == "Time Lord" then
            if not get_flag(3) then
                add_dialogue("\"Timey Limey Lord? Hmmm. I don't know him. Wait! Yes I do. Does he have a big black mustache and three pairs of pants? No! I know who he is. He's the fellow who came to fix my sundial the other day, right?\"")
                var_0009 = select_option()
                if var_0009 then
                    add_dialogue("\"I thought so! Tell him that bloody thing still doesn't work! It gives me three shadows! Dadows badows whoopeee! Ha ha ha!\"")
                else
                    add_dialogue("\"He's not? Hmmm. Then he must be the man I am not thinking of!\"")
                end
                add_dialogue("\"Wait! I remember! He is my Knight's Bridge opponent! We play on my Knight's Bridge court just north of mine house.\"")
            else
                add_dialogue("\"I have not spoken to the Time Lord in months! How is the old codger? Give him my regards. Tell him I miss our Knight's Bridge games!\"")
            end
            remove_answer("Time Lord")
            add_answer("Knight's Bridge")
        elseif var_0003 == "Knight's Bridge" then
            add_dialogue("\"'Tis a life-size board game. I have a book around here somewhere which contains the rules.\"")
            remove_answer("Knight's Bridge")
        elseif var_0003 == "hourglass" then
            if get_flag(301) then
                add_dialogue("\"Yes, I just enchanted it.\"")
            elseif not get_flag(529) and not var_0002 then
                if not get_flag(3) then
                    add_dialogue("\"This Time Lord told thee what? An hourglass! I have no blinking hourglass! Glassy wassy hoursplassy! Ha ha ha! Wait! An enchanted hourglass? That does ring a bell. Clang Clang Clang! Ha ha ha! Wait! I remember. I had an hourglass. I sold it. To a gypsy. Or was it an antique dealer? I think I might have sold it to a gypsy antique dealer in Britain. Or Paws. Somewhere on that side of the land. But if my memory serves me correctly, that hourglass used up its enchantment, which is why I sold it. I suppose if the ether is repaired, I could possibly re-enchant it. Bring it to me and we'll see what we can do. I know! We can play a rousing game of chess! But only if I can deal at all times. I do not trust thee.\"")
                else
                    add_dialogue("\"Mine old hourglass! I believe I sold it to an antique dealer in Paws. I might be able to re-enchant it if thou wouldst bring it to me.\"")
                end
            else
                if not get_flag(3) then
                    add_dialogue("\"What's this? An hourglass of some kind? Wait! It looks vaguely familiar! Thief!! This is mine hourglass! I have been looking for it for years! Where didst thou get it, scoundrel? I shall turn thee into a duck!\"")
                    add_dialogue("Nicodemus intones some spell and points at you, but nothing happens.")
                    add_dialogue("\"Zounds! Thou art no more a quacker than I am. Nothing works anymore. Quacker slacker wacker flacker! Ha ha ha!\"")
                else
                    add_dialogue("\"Mine old hourglass! I suppose I could revitalize the enchantment upon it.\"")
                end
            end
            remove_answer("hourglass")
        elseif var_0003 == "enchant" then
            if not get_flag(3) then
                add_dialogue("\"Enchant? Thou dost want me to enchant this wretched thing? Thou must have the brain of a toad! Toady woady bloady coady! Ha ha ha!\"")
                add_dialogue("\"Do me a favor, Mister Avatar. Repair the blinking ether, wilt thou? Do that and I can enchant thy glourblass. I mean floursass. I mean hourglass. Tell that to thy 'Time Lord'. Thou canst also tell him he needs a bath.\"")
            else
                add_dialogue("\"I would be most happy to enchant the hourglass. After freeing the ether, I am most indebted to thee. Let me see it...\"")
                if var_0002 then
                    add_dialogue("Nicodemus takes the hourglass and studies it a moment. He sets it on a table and closes his eyes, concentrating. He intones a few words, throws some reagents into the air, and passes his hand over the artifact.")
                    add_dialogue("\"That should do it.\" He hands the hourglass back to you.")
                    var_000A = unknown_002BH(false, 0, 359, 839, 1) --- Guess: Deducts item and adds item
                    var_000B = unknown_002CH(false, 1, 359, 839, 1) --- Guess: Checks inventory space
                    set_flag(301, true)
                    unknown_0911H(100) --- Guess: Submits item or advances quest
                else
                    add_dialogue("\"Where is it? Thou dost not have the hourglass!\"")
                end
            end
            remove_answer("enchant")
        elseif var_0003 == "bye" then
            break
        end
    end
    if not get_flag(3) then
        add_dialogue("\"Bye bye booby booby bye bye! Ha ha ha!\"")
    else
        add_dialogue("\"Goodbye, " .. var_0000 .. ".\"")
    end
end