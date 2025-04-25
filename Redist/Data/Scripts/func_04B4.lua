-- Function 04B4: Draxinusom's gargoyle leader dialogue
function func_04B4(eventid, itemref)
    -- Local variables (3 as per .localc)
    local local0, local1, local2

    if eventid == 0 then
        return
    elseif eventid ~= 1 then
        return
    end

    _SwitchTalkTo(0, -180)
    local0 = call_0908H()
    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x0239) and get_flag(0x0238) then
        _AddAnswer("Inamo")
    end
    if not get_flag(0x0004) then
        _AddAnswer("Moongates")
    end

    if not get_flag(0x0245) then
        say("You see an aged gargoyle, bent and withered, with a regal bearing. He smiles gently.")
        set_flag(0x0245, true)
    else
        say("\"To be good to see you again, old friend. To be needing Draxinusom again so soon?\"")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"To have been many years. To be your old acquaintance, ", local0, ", Draxinusom.\"")
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("\"To ask about Job? To be unable to say that I truly have one at this time. To notice how the young ones no longer look to me for guidance any more. To look more to Teregus, or, more often, to those in The Fellowship.\"")
            _AddAnswer({"Fellowship", "Teregus"})
        elseif answer == "Terfin" then
            say("\"To be quite comfortable for our needs. To be, however, unfortunate that it was thought necessary to isolate us from the humans. To have engendered resentment and tension in our younger generations. To remember not the old days, my friend -- the days when we had to work together to survive.\" He smiles, reliving old memories, then shakes his head.~~\"To have had to give up many much when we moved.\"")
            _AddAnswer("give up")
            _RemoveAnswer("Terfin")
        elseif answer == "give up" then
            say("\"To have been many favorite possessions. To be too much trouble to move so much.\" He sighs.")
            if not get_flag(0x01E0) then
                say("\"To especially regret selling my Ethereal Ring.\"")
                _AddAnswer({"Ethereal Ring", "selling"})
            end
            _RemoveAnswer("give up")
        elseif answer == "Ethereal Ring" then
            say("\"Ah. To be, indeed, a lovely treasure. To have been quite useful. A shame to have been, really, to have had to sell it. To have been one of my favorites.\"")
            _RemoveAnswer("Ethereal Ring")
        elseif answer == "selling" then
            say("\"To have sold most of my treasures when we were... uh... asked, shall to say, to move to the island. To have all happened rather quickly, you see. To have sold most to the Sultan of Spektran.\"")
            _AddAnswer("Sultan")
            _RemoveAnswer("selling")
        elseif answer == "Sultan" then
            say("\"To have seemed nice enough, for a human. To be a bit mad, he is, even for a human. To tell you he lives on an island just to the west of us. To know, at least, that my prized possessions would be safe in his hands.\"")
            _AddAnswer("safe")
            set_flag(0x023B, true)
            call_0911H(50)
            _RemoveAnswer("Sultan")
        elseif answer == "safe" then
            say("He nods his head. \"To be rumored to have one of the best-guarded vaults in all of Britannia. To be supposedly enchanted. To know not details.\"")
            _RemoveAnswer("safe")
        elseif answer == "Inamo" then
            _RemoveAnswer("Inamo")
            say("\"To be a fine young gargoyle. To have been raised by Teregus, keeper of the altars. To have left town because of the tension between the altar worshippers and The Fellowship. To have been angry and distrustful of The Fellowship. To have news of him?\"")
            local1 = call_090AH()
            if local1 then
                say("\"To be excellent! To have seen him? To know how he is faring? To be well?\"")
                set_flag(0x0238, true)
                _SaveAnswers()
                _AddAnswer({"well", "not well", "murdered"})
            else
                say("\"Ah. To be too bad. To tell you Teregus wanted to know how he was doing.\"")
            end
        elseif answer == "well" then
            say("\"To be very good. To know Teregus will be pleased to learn that, as well!\"")
            _RestoreAnswers()
        elseif answer == "murdered" then
            say("\"To be terrible news! To have been such a fine gargoyle. To know Teregus will be heartbroken. To be wishing not for him to grieve, but to take to him the news immediately. To be better to hear it from you.\"")
            _RestoreAnswers()
        elseif answer == "Moongates" then
            say("\"Mine own Orb of the Moons exploded recently! To no longer be able to travel via Moongates. To be strange!\"")
            _RemoveAnswer("Moongates")
        elseif answer == "not well" then
            say("\"To be a shame. To be taking the news to Teregus of his youngling. To be wondering why we had not heard from Inamo recently.\"")
            _RestoreAnswers()
        elseif answer == "Teregus" then
            say("\"To be truly a fine young gargoyle. To be one of the most sensible, too. To have seen fit to adhere to the old ways, the ways of the altars. To see that some of the youngest still look up to him, but the majority seem to have been wooed away by the glamor of The Fellowship.\"")
            if not get_flag(0x0238) then
                say("\"To tell you that his weanling, Inamo, is in Trinsic at this time.\"")
                set_flag(0x0239, true)
                _AddAnswer("Inamo")
            end
            _RemoveAnswer("Teregus")
        elseif answer == "Fellowship" then
            say("\"To know not what to think of them and their tenets. To seem not dangerous, but not to be following the old ways, the ways of Passion, Diligence, and Control. To feign worship to the shrines here in Terfin, of course, especially to Control, but not yet to trust them. To wait and see. To have forceful leaders who espouse doctrines of submission.\" He shrugs.~~\"To be genuinely inspired, perhaps, and perhaps not.\"")
            _AddAnswer({"leaders", "Terfin"})
            _RemoveAnswer("Fellowship")
        elseif answer == "leaders" then
            say("\"To inform you that The Fellowship is directed by two winged brethren. To be called Runeb and Quan.\"")
            _AddAnswer({"Quan", "Runeb"})
            _RemoveAnswer("leaders")
        elseif answer == "Runeb" then
            say("\"To mean, in your language, `Red Mist'. To have been given that name because that is all he leaves behind of an adversary in battle. Before his conversion by The Fellowship, to have been known as a particularly cruel and dangerous gargoyle.\"")
            local2 = callis_0037(callis_001B(-184))
            if not local2 then
                say("\"To be gone -- dead -- now.\"")
            end
            _RemoveAnswer("Runeb")
        elseif answer == "Quan" then
            say("\"Ah, to be an interesting one. To be a strong, powerful personality, to be from one of the families most able to claim noble lineage in our society. To have been always most self-serving, striving only to gain status and wealth for himself. To have certainly changed his tune since joining The Fellowship. To have my doubts, however, that his goals have changed as well.\"")
            _RemoveAnswer("Quan")
        elseif answer == "bye" then
            say("\"To bid farewell, old friend. To not be hesitating to return if there is aught else I can do for you. To be lonely here now for an old gargoyle dedicated to the ancient ways...\"*")
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