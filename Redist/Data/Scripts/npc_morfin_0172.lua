--- Best guess: Manages Morfin's dialogue in Paws, a merchant running the slaughterhouse, discussing venom theft, his ledger, and meat sales.
function npc_morfin_0172(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011, var_0012, var_0013, var_0014, var_0015, var_0016, var_0017, var_0018, var_0019, var_001A

    start_conversation()
    if eventid == 1 then
        switch_talk_to(NPC_MORFIN)
        var_0000 = get_player_name()
        var_0001 = get_lord_or_lady()
        var_0004 = get_schedule(NPC_MORFIN)
        -- Schedule type is only needed for shop hours; keep lookup safe.
        var_0005 = 0
        do
            local ok, name = pcall(get_npc_name, NPC_MORFIN)
            if ok and name then
                local ok2, sched = pcall(get_schedule_type, name)
                if ok2 and type(sched) == "number" then
                    var_0005 = sched
                end
            end
        end
        var_0002 = "Avatar"
        var_0003 = "None of thy concern"
        var_0006 = var_0001
        -- usecode name restoration from first-meeting choices
        if get_flag(FLAG_MORFIN_KNOWS_PLAYER_NAME) then
            var_0006 = var_0000
        end
        if get_flag(FLAG_MORFIN_REFUSED_NAME) then
            var_0006 = var_0001
        end
        if get_flag(FLAG_MORFIN_TAUNTED_AVATAR) then
            var_0006 = var_0001
        end

        -- Greeting first so the dialogue box always has text even if later probes fail.
        if not get_flag(FLAG_MET_MORFIN) then
            add_dialogue("You see a man whose eyes slowly shift back and forth as a crooked smile curls his lips. He walks up to you, looks you up and down. \"Oh, there must be a travelling show in town!\" he says sniggering. \"That is a very nice clown costume! Who art thou?\"")
            var_0008 = ask_multiple_choice({"Who art thou?", var_0000, var_0002, var_0003})
            if var_0008 == var_0000 then
                add_dialogue("\"Very well, " .. var_0000 .. ". What dost thou want?\"")
                set_flag(FLAG_MORFIN_KNOWS_PLAYER_NAME, true)
                var_0006 = var_0000
            elseif var_0008 == var_0003 then
                add_dialogue("\"Rude dog!\"")
                set_flag(FLAG_MORFIN_REFUSED_NAME, true)
                set_flag(FLAG_MET_MORFIN, true)
                clear_answers()
                return
            elseif var_0008 == var_0002 then
                add_dialogue("\"Thou art a vile fool, desperate for others to like thee. I would pity thee, were it not that I loathe thee even more!\"")
                set_flag(FLAG_MORFIN_TAUNTED_AVATAR, true)
                var_0006 = var_0002
                set_flag(FLAG_MET_MORFIN, true)
                clear_answers()
                return
            end
            set_flag(FLAG_MET_MORFIN, true)
        else
            add_dialogue("\"Greetings, " .. var_0006 .. ",\" says Morfin.")
        end

        add_answer({"bye", "job", "name"})
        -- usecode: apology if Avatar-insult path and not yet apologized
        if get_flag(FLAG_MORFIN_TAUNTED_AVATAR) and not get_flag(FLAG_MORFIN_APOLOGIZED) then
            add_answer("apology")
        end
        -- usecode: Tobias accusation path if framed and not solved
        if get_flag(FLAG_FERIDWYN_ACCUSED_TOBIAS) and not get_flag(FLAG_VENOM_CASE_SOLVED) then
            add_answer("Tobias stole venom")
        end
        -- usecode: ledger only after reading Morfin's venom sales ledger
        if get_flag(FLAG_READ_MORFIN_LEDGER) then
            add_answer("ledger")
        end
        if is_object_in_party_inventory(SHAPE_SILVER_SERPENT_VENOM) then
            add_answer("return venom")
        end
        while true do
            coroutine.yield()
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"My name is Morfin.\"")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"I am a merchant who operates one of the most thriving businesses in Paws, which includes the slaughterhouse.\"")
                add_answer({"slaughterhouse", "Paws", "merchant"})
            elseif answer == "merchant" then
                add_dialogue("\"Oh, I sell a little of this and that, here and there. Wherever there is a demand, I try to supply it.\"")
                add_answer({"supply", "demand"})
                remove_answer("merchant")
            elseif answer == "demand" then
                add_dialogue("\"There is quite a demand for the venom of the silver serpent in certain areas, for instance.\"")
                remove_answer("demand")
            elseif answer == "supply" then
                add_dialogue("\"I keep a small stock of silver serpent venom from time to time which I sell to the apothecary in Britannia for a modest profit. The government is trying to control sales of it until they can determine how dangerous the effects are.\"")
                remove_answer("supply")
                add_answer({"effects", "apothecary"})
            elseif answer == "apothecary" then
                add_dialogue("\"His name is Kessler.\"")
                remove_answer("apothecary")
            elseif answer == "Paws" then
                add_dialogue("\"I do suppose my ventures are profitable enough for me to afford to move to Britain, but things are so much less expensive here. Of course, the theft has me a bit wary.\"")
                add_dialogue("\"If thou dost wish to know more about the people here, speak to the couple who run the Fellowship shelter, Feridwyn and Brita.\"")
                remove_answer("Paws")
                if not get_flag(FLAG_VENOM_CASE_SOLVED) then
                    add_answer("theft")
                end
            elseif answer == "slaughterhouse" then
                add_dialogue("\"I take it thou hast noticed the smell. If so I do apologize.\" He shrugs his shoulders, grinning, and holds his palms upward.")
                add_dialogue("\"I think of it as the smell of success. Thou mayest purchase some meat if thou so wishest.\"")
                add_answer("buy meat")
                remove_answer("slaughterhouse")
            elseif answer == "buy meat" then
                if var_0005 == 7 then
                    add_dialogue("\"I sell mutton, beef, and ham. Which wouldst thou like?\"")
                    save_answers()
                    add_answer({"ham", "beef", "mutton", "nothing"})
                else
                    add_dialogue("\"The slaughterhouse is closed. Come around when it is open for business and I shall sell thee meats then.\"")
                end
                remove_answer("buy meat")
            elseif answer == "nothing" then
                add_dialogue("\"Some other time, perhaps.\"")
                restore_answers()
            elseif answer == "mutton" then
                add_dialogue("\"'Twill cost thee 3 gold each. Still interested?\"")
                if ask_yes_no() then
                    add_dialogue("\"How many dost thou want?\"")
                    var_0009 = input_numeric_value(1, 1, 20, 1)
                    var_000A = var_0009 * 3
                    var_000B = remove_party_items(true, 359, 644, 359, var_000A)
                    if var_000B then
                        var_000C = add_party_items(true, 8, 359, 377, var_0009)
                        if var_000C then
                            add_dialogue("\"Here it is.\"")
                        else
                            add_dialogue("\"Thou hast not the room for this meat.\"")
                            var_000D = add_party_items(true, 359, 644, 359, var_000A)
                        end
                    else
                        add_dialogue("\"Thou hast not the gold for this, " .. var_0006 .. ". Perhaps something else.\"")
                    end
                else
                    add_dialogue("\"Perhaps next time, " .. var_0006 .. ".\"")
                end
                remove_answer("mutton")
            elseif answer == "beef" then
                add_dialogue("\"'Twill cost thee 2 gold each. Still interested?\"")
                if ask_yes_no() then
                    add_dialogue("\"How many dost thou want?\"")
                    var_000E = input_numeric_value(1, 1, 20, 1)
                    var_000F = var_000E * 2
                    var_0010 = remove_party_items(true, 359, 644, 359, var_000F)
                    if var_0010 then
                        var_0011 = add_party_items(true, 9, 359, 377, var_000E)
                        if var_0011 then
                            add_dialogue("\"Here it is.\"")
                        else
                            add_dialogue("\"Thou hast not the room for this meat.\"")
                            var_0012 = add_party_items(true, 359, 644, 359, var_000F)
                        end
                    else
                        add_dialogue("\"Thou hast not the gold for this, " .. var_0006 .. ". Perhaps something else.\"")
                    end
                else
                    add_dialogue("\"Perhaps next time, " .. var_0006 .. ".\"")
                end
                remove_answer("beef")
            elseif answer == "ham" then
                add_dialogue("\"'Twill cost thee 4 gold each. Still interested?\"")
                if ask_yes_no() then
                    add_dialogue("\"How many dost thou want?\"")
                    var_0013 = input_numeric_value(1, 1, 20, 1)
                    var_0014 = var_0013 * 4
                    var_0015 = remove_party_items(true, 359, 644, 359, var_0014)
                    if var_0015 then
                        var_0016 = add_party_items(true, 11, 359, 377, var_0013)
                        if var_0016 then
                            add_dialogue("\"Here it is.\"")
                        else
                            add_dialogue("\"Thou hast not the room for this meat.\"")
                            var_0017 = add_party_items(true, 359, 644, 359, var_0014)
                        end
                    else
                        add_dialogue("\"Thou hast not the gold for this, " .. var_0006 .. ". Perhaps something else.\"")
                    end
                else
                    add_dialogue("\"Perhaps next time, " .. var_0006 .. ".\"")
                end
                remove_answer("ham")
            elseif answer == "venom" then
                add_dialogue("\"A terrible crime, causing me no small amount of monetary distress. It has caused the surrounding community to worry about their possessions as well.\"")
                if not get_flag(FLAG_VENOM_CASE_SOLVED) then
                    add_dialogue("\"I would be thine humble servant shouldst thou help investigate the matter. Wilt thou?\"")
                    var_0018 = ask_yes_no()
                    if var_0018 then
                        add_dialogue("\"Then I shall cooperate fully, " .. var_0001 .. ".\" He bows.")
                    else
                        add_dialogue("\"I do hope the culprit will be revealed through other methods then.\"")
                    end
                else
                    add_dialogue("\"I thank thee for solving the mystery of who was behind it.\"")
                end
                remove_answer("venom")
            elseif answer == "theft" then
                add_dialogue("\"Thou art a stranger in Paws. Beware the thief who roams this town! The culprit has stolen a quantity of my valuable silver serpent venom!\"")
                set_flag(FLAG_STOLEN_VENOM, true)
                remove_answer("theft")
                add_answer("venom")
            elseif answer == "apology" then
                add_dialogue("\"I do apologize for my rudeness earlier, " .. var_0006 .. ". I have since realized that thou art an honest person. Please forgive mine insults.\" He bows, dripping insincerity.")
                remove_answer("apology")
                set_flag(FLAG_MORFIN_APOLOGIZED, true)
            elseif answer == "ledger" then
                add_dialogue("You tell Morfin that you have seen his ledger. \"Wait, " .. var_0006 .. "! I admit I do sell Silver Serpent Venom to other places besides the Apothecary. But what I am doing is not -precisely- against the law!\"")
                add_answer({"law", "sell"})
                remove_answer("ledger")
            elseif answer == "sell" then
                add_dialogue("\"My supply comes from some old friends in Buccaneer's Den. Where they get it, who can say?\"")
                remove_answer("sell")
            elseif answer == "law" then
                add_dialogue("\"I have a notarized contract with the Britannian Mining Company. They use it to keep their gargoyles working longer hours. It seems gargoyles have a greater resistance to the effects of Silver Serpent Venom. Poor devils.\" He grins maliciously at his own joke.")
                remove_answer("law")
                add_answer("effects")
            elseif answer == "effects" then
                add_dialogue("\"They are widely known. Silver serpent venom is a reagent that, when ingested in small doses, temporarily enhances one's physical strength, stamina and quickness along with bringing a feeling of euphoria.\"")
                add_dialogue("\"After the effects wear off, the subject feels quite drained. This tends to make them want to take it again.\"")
                add_dialogue("\"Prolonged use in such a fashion will bring about a condition that deteriorates the skin, eventually causing it to rot away.\"")
                add_dialogue("\"Finally, too great a dose, or too great an accumulation of doses, is fatal, as the venom is a deadly poison.\"")
                add_dialogue("\"It may very well have some healing properties when used in other ways we have yet to discover, but any user of the venom should not do so without caution.\"")
                remove_answer("effects")
                add_answer("user")
            elseif answer == "user" or answer == "Tobias stole venom" then
                if get_flag(FLAG_FERIDWYN_ACCUSED_TOBIAS) then
                    add_dialogue("\"I am not so sure Tobias was the one who stole the venom. I have not seen any of the signs of venom use in Tobias and I am quite familiar with its symptoms. But, now that I think about it, I have noticed that Garritt has appeared very tired lately. He seems hyperactive one moment and unhealthy the next.\"")
                    if not get_flag(FLAG_GOT_GARRITT_KEY) then
                        add_answer("Garritt")
                    end
                    remove_answer("Tobias stole venom")
                else
                    add_dialogue("\"I do not believe I have noticed anyone in town who is showing the symptoms of venom use. From now on I shall keep watch, so thou shouldst ask again later.\"")
                end
                remove_answer("user")
            elseif answer == "Garritt" then
                add_dialogue("\"Perhaps thou shouldst make a search of Garritt's belongings! Which reminds me-- I saw him earlier playing near the slaughterhouse. He dropped this key. Perhaps it opens something... significant.\"")
                var_0019 = add_party_items(false, 6, 224, 641, 1)
                if var_0019 then
                    add_dialogue("\"Here it is.\"")
                    set_flag(FLAG_GOT_GARRITT_KEY, true)
                else
                    add_dialogue("\"I shall give it to thee when thine hands are not so full.\"")
                end
                remove_answer("Garritt")
            elseif answer == "return venom" then
                var_001A = remove_party_items(true, 359, 649, 359, 1)
                if var_001A then
                    add_dialogue("\"I thank thee for ferreting out the thief and returning my snake venom.\"")
                    if not get_flag(FLAG_VENOM_CASE_SOLVED) then
                        add_dialogue("\"So Garritt was the culprit, eh? I am not surprised now that I think about it. I must keep closer tabs on my venom from now on.\"")
                    end
                else
                    add_dialogue("\"Of course, I do wish for thee to return my venom to me if thou hast recovered it.\"")
                end
                remove_answer("return venom")
            elseif answer == "bye" then
                add_dialogue("\"Good day to thee.\"")
                clear_answers()
                break
            end
        end
    elseif eventid == 0 then
        utility_unknown_1070(NPC_MORFIN)
    end
end
