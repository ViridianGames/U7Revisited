-- Function 04A3: Phearcy's bartender dialogue and Zelda/Brion quest
function func_04A3(eventid, itemref)
    -- Local variables (9 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8

    if eventid == 0 then
        call_092EH(-163)
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(163, 0)
    local0 = call_0908H()
    local1 = call_0909H()
    local2 = call_08F7H(-4)
    local3 = callis_003B()
    local4 = false

    if local3 == 7 then
        local5 = call_08FCH(-250, -163)
        if local5 then
            say("\"Sorry, ", local1, ", I may talk to thee later. But now I wish to pay attention to the meeting.\"")
        else
            say("\"Sorry, ", local1, ", I must get to the Fellowship meeting!\"")
        end
        return -- abrt
    end

    _AddAnswer({"bye", "Fellowship", "job", "name"})
    if local2 then
        say("\"Why, Hello, Sir Dupre. Things fare well I trust?\"")
        switch_talk_to(4, 0)
        say("\"Greetings, fair Phearcy. Yes, thank thee, things are well.\"")
        _HideNPC(-4)
        switch_talk_to(163, 0)
    end

    if not get_flag(0x0205) then
        say("You see a man who gives you a friendly smile.")
        set_flag(0x0205, true)
    else
        say("\"How may I help thee, ", local1, "?\" asks Phearcy.")
    end

    if not get_flag(0x01DA) and not get_flag(0x01D9) then
        say("\"Hast thou discovered the reason for Zelda's moods?\"")
        local6 = call_090AH()
        if local6 then
            say("\"Excellent. Thou canst tell me while I get thy refreshment.\" As he prepares your meal, you tell him what you know about Zelda and Brion.")
            set_flag(0x01D9, true)
            local7 = callis_002C(true, 15, -359, 377, 5)
            if not local7 then
                say("\"Too bad, ", local1, ". When thou art carrying less weighty things I shall give thee thy jerky.\"")
            end
            local8 = callis_002C(true, 0, -359, 616, 5)
            if not local8 then
                say("\"And when thy load is lighter, then I can give thee thy beverages.\"")
            end
        else
            say("\"'Tis a shame, ", local1, ". Perhaps thou wilt know next time.\"")
        end
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"I am Phearcy, at thy service.\" He gives a short bow.")
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("\"I am the bartender here in Moonglow.\"")
            _AddAnswer({"buy", "Moonglow"})
        elseif answer == "Fellowship" then
            say("\"Oh, thou referest to this?\" he asks, pointing to his medallion. \"Thou hast not heard of The Fellowship? I strongly recommend that thou speakest with Rankin or Balayna at the branch office. The Fellowship has done many things for our town, if not for all of Britannia. I am a firm believer in neo-realism.\"")
            _AddAnswer("neo-realism")
            _RemoveAnswer("Fellowship")
        elseif answer == "neo-realism" then
            say("\"That is the fundamental principle of The Fellowship. It is composed of the triad of inner strength, which is strive for unity, trust thy brother, and... one other one.... Oh, yes, thou dost get what thou deservest, or some such.\"")
            _RemoveAnswer("neo-realism")
        elseif answer == "Moonglow" then
            say("\"Thou wants to know about someone in the town? Thou hast asked the right person. I know all about the residents here in Moonglow. I would be happy to tell thee about any of the shop keepers, scholars, or farmers who live here. Or art thou interested in the trainer, healer, mage, or Fellowship leaders?\"")
            _RemoveAnswer("Moonglow")
            _SaveAnswers()
            _AddAnswer({"leaders", "mage", "healer", "trainer", "farmers", "scholars", "shop keeper", "no one"})
        elseif answer == "scholars" then
            say("\"Ah, the learned scholars. I can tell thee about Brion, Nelson, Zelda, and Jillian.\"")
            _SaveAnswers()
            _AddAnswer({"Jillian", "Zelda", "Nelson", "Brion", "no one"})
        elseif answer == "leaders" then
            say("\"Dost thou want to know about the one in charge or his clerk?\"")
            _SaveAnswers()
            _AddAnswer({"clerk", "charge", "no one"})
        elseif answer == "mage" then
            say("\"Ah, yes, Mariah is very nice.\"")
            if not get_flag(0x01D9) then
                say("\"She can sell thee many spells.\"")
            elseif not local4 then
                say("\"But I am more interested in discussing Zelda.\"")
            end
            _RemoveAnswer("mage")
        elseif answer == "shop keeper" then
            say("\"She is a tailor. Lovely woman, that Carlyn. She minds the bar when I go to the Fellowship meetings at night.\"")
            if not get_flag(0x01D9) and not local4 then
                say("\"But I would rather discuss Zelda.\"")
            end
            _RemoveAnswer("shop keeper")
        elseif answer == "Jillian" then
            say("\"Wonderful scholar. Very nice woman. Married to Effrem.\"")
            _AddAnswer("Effrem")
            if not get_flag(0x01D9) and not local4 then
                say("\"But I am more interested in discussing Zelda.\"")
            end
            _RemoveAnswer("Jillian")
        elseif answer == "Effrem" then
            say("\"Friendly fellow -- I like him.\"")
            if not get_flag(0x01D9) then
                say("\"He stays home to care for their son.\"")
            elseif not local4 then
                say("\"But I am more interested in discussing Brion.\"")
            end
            _RemoveAnswer("Effrem")
        elseif answer == "trainer" then
            say("\"Chad is a friendly fellow -- I like him.\"")
            if not get_flag(0x01D9) and not local4 then
                say("\"But I would rather discuss Brion.\"")
            end
            _RemoveAnswer("trainer")
        elseif answer == "farmers" then
            say("\"Tolemac and Cubolt are brothers. With Morz's help, they run a farm.\"")
            if not get_flag(0x01D9) and not local4 then
                say("\"But I would prefer to talk about Brion.\"")
            end
            _RemoveAnswer("farmers")
        elseif answer == "healer" then
            say("\"Friendly fellow -- I like him. His name is Elad.\"")
            if not get_flag(0x01D9) then
                say("\"Sadly, his true desire is to leave Moonglow in search of adventure. But he will not leave, for he feels too much obligation for his patients.\" Phearcy shrugs.\"Perhaps not without reason.\"")
            elseif not local4 then
                say("\"But Brion is more interesting to me.\"")
            end
            _RemoveAnswer("healer")
        elseif answer == "Nelson" then
            say("\"He is Brion's twin brother.\"")
            if not get_flag(0x01D9) and not local4 then
                say("\"Speaking of that, I would like to discuss Brion.\"")
            end
            _RemoveAnswer("Nelson")
        elseif answer == "charge" then
            say("\"Rankin is in charge of the entire local branch. If thou hast any questions about The Fellowship, he can answer them.\"")
            _RemoveAnswer("charge")
        elseif answer == "clerk" then
            say("\"If thou hast any questions about The Fellowship, Balayna can answer them.\"")
            _RemoveAnswer("clerk")
        elseif answer == "Zelda" or answer == "Brion" then
            if get_flag(0x01D9) then
                say("\"Well, as thou dost know, Brion is the head of Observatory, and Zelda, the advisor at the Lyceaum, is in love with him.\"")
            else
                say("\"Ah, so thou dost wonder, too. All I know is that every time someone mentions Brion's name to Zelda, her serious expression changes to a smile.~~I have a deal for thee. Find out what their story is, and I will give thee and thy friends a free meal and drink. Thou canst find Brion at the observatory and Zelda at the Lycaeum.\"")
                local4 = true
            end
            _RemoveAnswer({"Zelda", "Brion"})
        elseif answer == "no one" then
            _RestoreAnswers()
            _AddAnswer("bye")
        elseif answer == "buy" then
            say("\"Food or drink, ", local1, "?\"")
            _SaveAnswers()
            _AddAnswer({"drink", "food"})
            _RemoveAnswer("buy")
        elseif answer == "food" then
            call_08CBH()
            _RestoreAnswers()
            _RemoveAnswer("food")
        elseif answer == "drink" then
            call_08CCH()
            _RestoreAnswers()
            _RemoveAnswer("drink")
        elseif answer == "bye" then
            say("\"Remember! Tell them thou didst eat at the Friendly Knave!\"")
            break
        end

        -- Note: Original has 'db 40' here, ignored
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

function _SaveAnswers()
    -- Placeholder for saving answers
end

function _RestoreAnswers()
    -- Placeholder for restoring answers
end