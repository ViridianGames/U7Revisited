-- Function 04AC: Morfin's merchant dialogue and venom theft investigation
function func_04AC(eventid, itemref)
    -- Local variables (27 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9
    local local10, local11, local12, local13, local14, local15, local16, local17, local18, local19
    local local20, local21, local22, local23, local24, local25, local26

    if eventid == 0 then
        call_092EH(-172)
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(172, 0)
    local0 = call_0908H()
    local1 = call_0909H()
    local2 = "Avatar"
    local3 = "None of thy concern"
    local4 = callis_003B()
    local5 = callis_001B(-172)
    add_answer({"bye", "job", "name"})

    if get_flag(0x022F) then
        local6 = local0
    elseif get_flag(0x0230) then
        local6 = local1
    elseif not get_flag(0x0214) then
        local6 = local1
        if not get_flag(0x0235) then
            add_answer("apology")
        end
    end
    if get_flag(0x0213) and not get_flag(0x0218) then
        add_answer("Tobias stole venom")
    end
    if get_flag(0x0233) then
        add_answer("ledger")
    end
    if call_0931H(1, -359, 649, 1, -357) then
        add_answer("return venom")
    end

    if not get_flag(0x0225) then
        add_dialogue("You see a man whose eyes slowly shift back and forth as a crooked smile curls his lips. He walks up to you, looks you up and down. \"Oh, there must be a travelling show in town!\" he says sniggering. \"That is a very nice clown costume! Who art thou?\"*")
        local8 = call_090BH(local3, local2, local0)
        if local8 == local0 then
            add_dialogue("\"Very well, ", local0, ". What dost thou want?\"")
            set_flag(0x022F, true)
            local6 = local0
        elseif local8 == local3 then
            add_dialogue("\"Rude dog!\"*")
            set_flag(0x0230, true)
            set_flag(0x0225, true)
            return -- abrt
        elseif local8 == local2 then
            add_dialogue("\"Thou art a vile fool, desperate for others to like thee. I would pity thee, were it not that I loathe thee even more!\"*")
            set_flag(0x0214, true)
            local6 = local2
            set_flag(0x0225, true)
            return -- abrt
        end
        set_flag(0x0225, true)
    else
        add_dialogue("\"Greetings, ", local6, ",\" says Morfin.")
    end

    while true do
        local answer = wait_for_answer()

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
            add_dialogue("\"I do suppose my ventures are profitable enough for me to afford to move to Britain, but things are so much less expensive here. Of course, the theft has me a bit wary.~~\"If thou dost wish to know more about the people here, speak to the couple who run the Fellowship shelter, Feridwyn and Brita.\"")
            remove_answer("Paws")
            if not get_flag(0x0218) then
                add_answer("theft")
            end
        elseif answer == "slaughterhouse" then
            add_dialogue("\"I take it thou hast noticed the smell. If so I do apologize.\" He shrugs his shoulders, grinning, and holds his palms upward.~~\"I think of it as the smell of success. Thou mayest purchase some meat if thou so wishest.\"")
            add_answer("buy meat")
            remove_answer("slaughterhouse")
        elseif answer == "buy meat" then
            if local5 == 7 then
                add_dialogue("\"I sell mutton, beef, and ham. Which wouldst thou like?\"")
                _SaveAnswers()
                add_answer({"ham", "beef", "mutton", "nothing"})
            else
                add_dialogue("\"The slaughterhouse is closed. Come around when it is open for business and I shall sell thee meats then.\"")
            end
            remove_answer("buy meat")
        elseif answer == "nothing" then
            add_dialogue("\"Some other time, perhaps.\"")
            _RestoreAnswers()
        elseif answer == "mutton" then
            add_dialogue("\"'Twill cost thee 3 gold each. Still interested?\"")
            local9 = call_090AH()
            if local9 then
                add_dialogue("\"How many dost thou want?\"")
                local10 = call_AskNumber(1, 1, 20, 1)
                local11 = local10 * 3
                local12 = callis_002B(true, -359, -359, 644, local11)
                if local12 then
                    local13 = callis_002C(true, 8, -359, 377, local10)
                    if local13 then
                        add_dialogue("\"Here it is.\"")
                    else
                        add_dialogue("\"Thou hast not the room for this meat.\"")
                        callis_002C(true, -359, -359, 644, local11)
                    end
                else
                    add_dialogue("\"Thou hast not the gold for this, ", local6, ". Perhaps something else.\"")
                end
            else
                add_dialogue("\"Perhaps next time, ", local6, ".\"")
            end
            remove_answer("mutton")
        elseif answer == "beef" then
            add_dialogue("\"'Twill cost thee 2 gold each. Still interested?\"")
            local14 = call_090AH()
            if local14 then
                add_dialogue("\"How many dost thou want?\"")
                local15 = call_AskNumber(1, 1, 20, 1)
                local16 = local15 * 2
                local17 = callis_002B(true, -359, -359, 644, local16)
                if local17 then
                    local18 = callis_002C(true, 9, -359, 377, local15)
                    if local18 then
                        add_dialogue("\"Here it is.\"")
                    else
                        add_dialogue("\"Thou hast not the room for this meat.\"")
                        callis_002C(true, -359, -359, 644, local16)
                    end
                else
                    add_dialogue("\"Thou hast not the gold for this, ", local6, ". Perhaps something else.\"")
                end
            else
                add_dialogue("\"Perhaps next time, ", local6, ".\"")
            end
            remove_answer("beef")
        elseif answer == "ham" then
            add_dialogue("\"'Twill cost thee 4 gold each. Still interested?\"")
            local19 = call_090AH()
            if local19 then
                add_dialogue("\"How many dost thou want?\"")
                local20 = call_AskNumber(1, 1, 20, 1)
                local21 = local20 * 4
                local22 = callis_002B(true, -359, -359, 644, local21)
                if local22 then
                    local23 = callis_002C(true, 11, -359, 377, local20)
                    if local23 then
                        add_dialogue("\"Here it is.\"")
                    else
                        add_dialogue("\"Thou hast not the room for this meat.\"")
                        callis_002C(true, -359, -359, 644, local21)
                    end
                else
                    add_dialogue("\"Thou hast not the gold for this, ", local6, ". Perhaps something else.\"")
                end
            else
                add_dialogue("\"Perhaps next time, ", local6, ".\"")
            end
            remove_answer("ham")
        elseif answer == "venom" then
            add_dialogue("\"A terrible crime, causing me no small amount of monetary distress. It has caused the surrounding community to worry about their possessions as well.\"")
            if not get_flag(0x0218) then
                add_dialogue("\"I would be thine humble servant shouldst thou help investigate the matter. Wilt thou?\"")
                local24 = call_090AH()
                if local24 then
                    add_dialogue("\"Then I shall cooperate fully, ", local1, ".\" He bows.")
                else
                    add_dialogue("\"I do hope the culprit will be revealed through other methods then.\"")
                end
            else
                add_dialogue("\"I thank thee for solving the mystery of who was behind it.\"")
            end
            remove_answer("venom")
        elseif answer == "theft" then
            add_dialogue("\"Thou art a stranger in Paws. Beware the thief who roams this town! The culprit has stolen a quantity of my valuable silver serpent venom!\"")
            set_flag(0x0212, true)
            remove_answer("theft")
            add_answer("venom")
        elseif answer == "apology" then
            add_dialogue("\"I do apologize for my rudeness earlier, ", local6, ". I have since realized that thou art an honest person. Please forgive mine insults.\" He bows, dripping insincerity.")
            remove_answer("apology")
            set_flag(0x0235, true)
        elseif answer == "ledger" then
            add_dialogue("You tell Morfin that you have seen his ledger. \"Wait, ", local6, "! I admit I do sell Silver Serpent Venom to other places besides the Apothecary. But what I am doing is not -precisely- against the law!\"")
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
            add_dialogue("\"They are widely known. Silver serpent venom is a reagent that, when ingested in small doses, temporarily enhances one's physical strength, stamina and quickness along with bringing a feeling of euphoria.~~\"After the effects wear off, the subject feels quite drained. This tends to make them want to take it again.~~\"Prolonged use in such a fashion will bring about a condition that deteriorates the skin, eventually causing it to rot away.~~\"Finally, too great a dose, or too great an accumulation of doses, is fatal, as the venom is a deadly poison.~~\"It may very well have some healing properties when used in other ways we have yet to discover, but any user of the venom should not do so without caution.\"")
            remove_answer("effects")
            add_answer("user")
        elseif answer == "Tobias stole venom" or answer == "user" then
            if get_flag(0x0213) then
                add_dialogue("\"I am not so sure Tobias was the one who stole the venom. I have not seen any of the signs of venom use in Tobias and I am quite familiar with its symptoms. But, now that I think about it, I have noticed that Garritt has appeared very tired lately. He seems hyperactive one moment and unhealthy the next.\"")
                if not get_flag(0x0237) then
                    add_answer("Garritt")
                end
                remove_answer("Tobias stole venom")
            else
                add_dialogue("\"I do not believe I have noticed anyone in town who is showing the symptoms of venom use. From now on I shall keep watch, so thou shouldst ask again later.\"")
            end
            remove_answer("user")
        elseif answer == "Garritt" then
            add_dialogue("\"Perhaps thou shouldst make a search of Garritt's belongings! Which reminds me-- I saw him earlier playing near the slaughterhouse. He dropped this key. Perhaps it opens something... significant.\"")
            local25 = callis_002C(false, 6, 224, 641, 1)
            if local25 then
                add_dialogue("\"Here it is.\"")
                set_flag(0x0237, true)
            else
                add_dialogue("\"I shall give it to thee when thine hands are not so full.\"")
            end
            remove_answer("Garritt")
        elseif answer == "return venom" then
            local26 = callis_002B(true, -359, -359, 649, 1)
            if local26 then
                add_dialogue("\"I thank thee for ferreting out the thief and returning my snake venom.\"")
                if not get_flag(0x0218) then
                    add_dialogue("\"So Garritt was the culprit, eh? I am not surprised now that I think about it. I must keep closer tabs on my venom from now on.\"")
                end
            else
                add_dialogue("\"Of course, I do wish for thee to return my venom to me if thou hast recovered it.\"")
            end
            remove_answer("return venom")
        elseif answer == "bye" then
            add_dialogue("\"Good day to thee.\"*")
            break
        end
    end

    return
end

-- Helper functions
function add_dialogue(...)
    print(table.concat({...}))
end

function wait_for_answer()
    return "bye" -- Placeholder
end

function get_flag(flag)
    return false -- Placeholder
end

function set_flag(flag, value)
    -- Placeholder
end