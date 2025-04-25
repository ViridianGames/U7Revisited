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

    _SwitchTalkTo(0, -172)
    local0 = call_0908H()
    local1 = call_0909H()
    local2 = "Avatar"
    local3 = "None of thy concern"
    local4 = callis_003B()
    local5 = callis_001B(-172)
    _AddAnswer({"bye", "job", "name"})

    if get_flag(0x022F) then
        local6 = local0
    elseif get_flag(0x0230) then
        local6 = local1
    elseif not get_flag(0x0214) then
        local6 = local1
        if not get_flag(0x0235) then
            _AddAnswer("apology")
        end
    end
    if get_flag(0x0213) and not get_flag(0x0218) then
        _AddAnswer("Tobias stole venom")
    end
    if get_flag(0x0233) then
        _AddAnswer("ledger")
    end
    if call_0931H(1, -359, 649, 1, -357) then
        _AddAnswer("return venom")
    end

    if not get_flag(0x0225) then
        say("You see a man whose eyes slowly shift back and forth as a crooked smile curls his lips. He walks up to you, looks you up and down. \"Oh, there must be a travelling show in town!\" he says sniggering. \"That is a very nice clown costume! Who art thou?\"*")
        local8 = call_090BH(local3, local2, local0)
        if local8 == local0 then
            say("\"Very well, ", local0, ". What dost thou want?\"")
            set_flag(0x022F, true)
            local6 = local0
        elseif local8 == local3 then
            say("\"Rude dog!\"*")
            set_flag(0x0230, true)
            set_flag(0x0225, true)
            return -- abrt
        elseif local8 == local2 then
            say("\"Thou art a vile fool, desperate for others to like thee. I would pity thee, were it not that I loathe thee even more!\"*")
            set_flag(0x0214, true)
            local6 = local2
            set_flag(0x0225, true)
            return -- abrt
        end
        set_flag(0x0225, true)
    else
        say("\"Greetings, ", local6, ",\" says Morfin.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"My name is Morfin.\"")
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("\"I am a merchant who operates one of the most thriving businesses in Paws, which includes the slaughterhouse.\"")
            _AddAnswer({"slaughterhouse", "Paws", "merchant"})
        elseif answer == "merchant" then
            say("\"Oh, I sell a little of this and that, here and there. Wherever there is a demand, I try to supply it.\"")
            _AddAnswer({"supply", "demand"})
            _RemoveAnswer("merchant")
        elseif answer == "demand" then
            say("\"There is quite a demand for the venom of the silver serpent in certain areas, for instance.\"")
            _RemoveAnswer("demand")
        elseif answer == "supply" then
            say("\"I keep a small stock of silver serpent venom from time to time which I sell to the apothecary in Britannia for a modest profit. The government is trying to control sales of it until they can determine how dangerous the effects are.\"")
            _RemoveAnswer("supply")
            _AddAnswer({"effects", "apothecary"})
        elseif answer == "apothecary" then
            say("\"His name is Kessler.\"")
            _RemoveAnswer("apothecary")
        elseif answer == "Paws" then
            say("\"I do suppose my ventures are profitable enough for me to afford to move to Britain, but things are so much less expensive here. Of course, the theft has me a bit wary.~~\"If thou dost wish to know more about the people here, speak to the couple who run the Fellowship shelter, Feridwyn and Brita.\"")
            _RemoveAnswer("Paws")
            if not get_flag(0x0218) then
                _AddAnswer("theft")
            end
        elseif answer == "slaughterhouse" then
            say("\"I take it thou hast noticed the smell. If so I do apologize.\" He shrugs his shoulders, grinning, and holds his palms upward.~~\"I think of it as the smell of success. Thou mayest purchase some meat if thou so wishest.\"")
            _AddAnswer("buy meat")
            _RemoveAnswer("slaughterhouse")
        elseif answer == "buy meat" then
            if local5 == 7 then
                say("\"I sell mutton, beef, and ham. Which wouldst thou like?\"")
                _SaveAnswers()
                _AddAnswer({"ham", "beef", "mutton", "nothing"})
            else
                say("\"The slaughterhouse is closed. Come around when it is open for business and I shall sell thee meats then.\"")
            end
            _RemoveAnswer("buy meat")
        elseif answer == "nothing" then
            say("\"Some other time, perhaps.\"")
            _RestoreAnswers()
        elseif answer == "mutton" then
            say("\"'Twill cost thee 3 gold each. Still interested?\"")
            local9 = call_090AH()
            if local9 then
                say("\"How many dost thou want?\"")
                local10 = call_AskNumber(1, 1, 20, 1)
                local11 = local10 * 3
                local12 = callis_002B(true, -359, -359, 644, local11)
                if local12 then
                    local13 = callis_002C(true, 8, -359, 377, local10)
                    if local13 then
                        say("\"Here it is.\"")
                    else
                        say("\"Thou hast not the room for this meat.\"")
                        callis_002C(true, -359, -359, 644, local11)
                    end
                else
                    say("\"Thou hast not the gold for this, ", local6, ". Perhaps something else.\"")
                end
            else
                say("\"Perhaps next time, ", local6, ".\"")
            end
            _RemoveAnswer("mutton")
        elseif answer == "beef" then
            say("\"'Twill cost thee 2 gold each. Still interested?\"")
            local14 = call_090AH()
            if local14 then
                say("\"How many dost thou want?\"")
                local15 = call_AskNumber(1, 1, 20, 1)
                local16 = local15 * 2
                local17 = callis_002B(true, -359, -359, 644, local16)
                if local17 then
                    local18 = callis_002C(true, 9, -359, 377, local15)
                    if local18 then
                        say("\"Here it is.\"")
                    else
                        say("\"Thou hast not the room for this meat.\"")
                        callis_002C(true, -359, -359, 644, local16)
                    end
                else
                    say("\"Thou hast not the gold for this, ", local6, ". Perhaps something else.\"")
                end
            else
                say("\"Perhaps next time, ", local6, ".\"")
            end
            _RemoveAnswer("beef")
        elseif answer == "ham" then
            say("\"'Twill cost thee 4 gold each. Still interested?\"")
            local19 = call_090AH()
            if local19 then
                say("\"How many dost thou want?\"")
                local20 = call_AskNumber(1, 1, 20, 1)
                local21 = local20 * 4
                local22 = callis_002B(true, -359, -359, 644, local21)
                if local22 then
                    local23 = callis_002C(true, 11, -359, 377, local20)
                    if local23 then
                        say("\"Here it is.\"")
                    else
                        say("\"Thou hast not the room for this meat.\"")
                        callis_002C(true, -359, -359, 644, local21)
                    end
                else
                    say("\"Thou hast not the gold for this, ", local6, ". Perhaps something else.\"")
                end
            else
                say("\"Perhaps next time, ", local6, ".\"")
            end
            _RemoveAnswer("ham")
        elseif answer == "venom" then
            say("\"A terrible crime, causing me no small amount of monetary distress. It has caused the surrounding community to worry about their possessions as well.\"")
            if not get_flag(0x0218) then
                say("\"I would be thine humble servant shouldst thou help investigate the matter. Wilt thou?\"")
                local24 = call_090AH()
                if local24 then
                    say("\"Then I shall cooperate fully, ", local1, ".\" He bows.")
                else
                    say("\"I do hope the culprit will be revealed through other methods then.\"")
                end
            else
                say("\"I thank thee for solving the mystery of who was behind it.\"")
            end
            _RemoveAnswer("venom")
        elseif answer == "theft" then
            say("\"Thou art a stranger in Paws. Beware the thief who roams this town! The culprit has stolen a quantity of my valuable silver serpent venom!\"")
            set_flag(0x0212, true)
            _RemoveAnswer("theft")
            _AddAnswer("venom")
        elseif answer == "apology" then
            say("\"I do apologize for my rudeness earlier, ", local6, ". I have since realized that thou art an honest person. Please forgive mine insults.\" He bows, dripping insincerity.")
            _RemoveAnswer("apology")
            set_flag(0x0235, true)
        elseif answer == "ledger" then
            say("You tell Morfin that you have seen his ledger. \"Wait, ", local6, "! I admit I do sell Silver Serpent Venom to other places besides the Apothecary. But what I am doing is not -precisely- against the law!\"")
            _AddAnswer({"law", "sell"})
            _RemoveAnswer("ledger")
        elseif answer == "sell" then
            say("\"My supply comes from some old friends in Buccaneer's Den. Where they get it, who can say?\"")
            _RemoveAnswer("sell")
        elseif answer == "law" then
            say("\"I have a notarized contract with the Britannian Mining Company. They use it to keep their gargoyles working longer hours. It seems gargoyles have a greater resistance to the effects of Silver Serpent Venom. Poor devils.\" He grins maliciously at his own joke.")
            _RemoveAnswer("law")
            _AddAnswer("effects")
        elseif answer == "effects" then
            say("\"They are widely known. Silver serpent venom is a reagent that, when ingested in small doses, temporarily enhances one's physical strength, stamina and quickness along with bringing a feeling of euphoria.~~\"After the effects wear off, the subject feels quite drained. This tends to make them want to take it again.~~\"Prolonged use in such a fashion will bring about a condition that deteriorates the skin, eventually causing it to rot away.~~\"Finally, too great a dose, or too great an accumulation of doses, is fatal, as the venom is a deadly poison.~~\"It may very well have some healing properties when used in other ways we have yet to discover, but any user of the venom should not do so without caution.\"")
            _RemoveAnswer("effects")
            _AddAnswer("user")
        elseif answer == "Tobias stole venom" or answer == "user" then
            if get_flag(0x0213) then
                say("\"I am not so sure Tobias was the one who stole the venom. I have not seen any of the signs of venom use in Tobias and I am quite familiar with its symptoms. But, now that I think about it, I have noticed that Garritt has appeared very tired lately. He seems hyperactive one moment and unhealthy the next.\"")
                if not get_flag(0x0237) then
                    _AddAnswer("Garritt")
                end
                _RemoveAnswer("Tobias stole venom")
            else
                say("\"I do not believe I have noticed anyone in town who is showing the symptoms of venom use. From now on I shall keep watch, so thou shouldst ask again later.\"")
            end
            _RemoveAnswer("user")
        elseif answer == "Garritt" then
            say("\"Perhaps thou shouldst make a search of Garritt's belongings! Which reminds me-- I saw him earlier playing near the slaughterhouse. He dropped this key. Perhaps it opens something... significant.\"")
            local25 = callis_002C(false, 6, 224, 641, 1)
            if local25 then
                say("\"Here it is.\"")
                set_flag(0x0237, true)
            else
                say("\"I shall give it to thee when thine hands are not so full.\"")
            end
            _RemoveAnswer("Garritt")
        elseif answer == "return venom" then
            local26 = callis_002B(true, -359, -359, 649, 1)
            if local26 then
                say("\"I thank thee for ferreting out the thief and returning my snake venom.\"")
                if not get_flag(0x0218) then
                    say("\"So Garritt was the culprit, eh? I am not surprised now that I think about it. I must keep closer tabs on my venom from now on.\"")
                end
            else
                say("\"Of course, I do wish for thee to return my venom to me if thou hast recovered it.\"")
            end
            _RemoveAnswer("return venom")
        elseif answer == "bye" then
            say("\"Good day to thee.\"*")
            break
        end
    end

    return
end

-- Helper functions
function say(...)
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