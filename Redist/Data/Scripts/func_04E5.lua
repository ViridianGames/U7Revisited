-- Function 04E5: Budo's provisioner dialogue and ship deed sale
function func_04E5(eventid, itemref)
    -- Local variables (13 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12

    if eventid == 0 then
        local0 = callis_003B()
        local1 = callis_001C(callis_001B(-229))
        local11 = callis_Random2(4, 1)
        if local1 == 7 then
            if local11 == 1 then
                local12 = "@Weapons? Armour?@"
            elseif local11 == 2 then
                local12 = "@Provisions here!@"
            elseif local11 == 3 then
                local12 = "@Budo's is open for business!@"
            elseif local11 == 4 then
                local12 = "@Step right in! We're open!@"
            end
            _ItemSay(local12, -229)
        else
            call_092EH(-229)
        end
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(229, 0)
    local0 = callis_003B()
    local1 = callis_001C(callis_001B(-229))
    local2 = call_0931H(1, -359, 981, 1, -357)
    _AddAnswer({"bye", "job", "name"})

    if get_flag(0x0135) or get_flag(0x0104) then
        _AddAnswer("Crown Jewel")
    end

    if not get_flag(0x02B2) then
        say("You see a fat, cheerful-looking merchant.")
        if local1 == 7 then
            say("\"Hello, hello my friend! Thou dost look like thou needest to spend money!\"*")
            local3 = call_08F7H(-3)
            if not local3 then
                switch_talk_to(3, 0)
                say("\"This place looks quite well-off.\"*")
                _HideNPC(-3)
                local4 = call_08F7H(-1)
                if not local4 then
                    switch_talk_to(1, 0)
                    say("\"The entire island is very opulent. It is not the same island we once knew.\"*")
                    _HideNPC(-1)
                end
                switch_talk_to(229, 0)
            end
        else
            say("\"Hello! How art thou, my friend?\"")
        end
        set_flag(0x02B2, true)
    else
        say("\"How may I help thee?\" Budo asks.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"Budo the Fourth at thy service! 'Tis a fine day today, is it not?\"")
            _RemoveAnswer("name")
        elseif answer == "job" then
            if local1 == 7 then
                local5 = "thou hast come to the right place!@"
                local6 = ""
                local7 = ""
                _AddAnswer({"ship deed", "provisions", "armour", "weapons"})
            else
                local5 = "thou shouldst come to my shoppe when "
                local6 = "it is open! I would be so pleased to "
                local7 = "help thee then.@"
            end
            say("\"I am a provisioner, like my father before me, and like his father before him, and like his father before him. Budo's is an island tradition! Just as The Fellowship will be someday!~~\"If thou art interested in weapons, armour, provisions, or a ship deed, ", local5, local6, local7)
            _AddAnswer("Fellowship")
        elseif answer == "armour" then
            say("\"Budo's carries nothing but the finest quality armour in all Britannia. I have all the best types of equipment available.\"")
            call_0859H()
        elseif answer == "weapons" then
            say("\"Budo's offers thee excellent weaponry with superb craftsmanship. Thou wilt not find a better buy for thy money anywhere else!\"")
            call_0858H()
        elseif answer == "provisions" then
            say("\"Budo's also carries a variety of useful things for thy convenience.\"")
            call_085AH()
        elseif answer == "ship deed" then
            if get_flag(0x02B6) then
                say("\"But I have already sold thee the deed to 'The Lusty Wench'! She was the only ship I had at this particular time! I am sorry!\"")
            else
                say("\"I can sell thee the deed to my ship 'The Lusty Wench.' She is beautiful, my friend. She is guaranteed to last and is the sleekest vessel on the seas! She goes for 800 gold. Want her?\"")
                if call_090AH() then
                    local8 = callis_0028(-359, -359, 644, -357)
                    if local8 >= 800 then
                        local9 = callis_002C(false, 2, 18, 797, 1)
                        if local9 then
                            say("\"A wise move. A magnificent ship for thee!\" He takes your gold.")
                            callis_002B(true, -359, -359, 644, 800)
                            set_flag(0x02B6, true)
                        else
                            say("\"Thou art carrying too much, my friend! Unload thyself of some of thy belongings and I will sell thee the deed to this beautiful ship.\"")
                        end
                    else
                        say("\"But thou dost not have enough gold! Perhaps thou shouldst visit the House of Games and increase the bulges in thy pockets!\"")
                    end
                else
                    say("\"But thou wilt never see a ship like this one anywhere in the world! Too bad!\"")
                end
            end
            _RemoveAnswer("ship deed")
        elseif answer == "Fellowship" then
            say("\"The Fellowship has helped me to become a very rich man! Although the business is an inherited enterprise, I owe everything to The Fellowship!\"")
            _RemoveAnswer("Fellowship")
            _AddAnswer({"everything", "inherited", "rich man"})
        elseif answer == "rich man" then
            say("\"My great-grandfather started this business many, many years ago. He was moderately successful, thanks to the Thieves' Guild. But that era has passed.\"")
            _AddAnswer("Thieves' Guild")
            _RemoveAnswer("rich man")
        elseif answer == "inherited" then
            say("\"My great-grandfather passed the shoppe on to his son, and so forth, down to me. We are born merchants! That is why I know why thou hast come to Budo's! Thou wantest to become a part of the great Budo Legacy! Thou dost need to buy something!\"")
            _RemoveAnswer("inherited")
        elseif answer == "everything" then
            say("\"There was a period shortly after my father died, just as I had inherited the shoppe, when business was poor. There was a danger that I would not be able to keep the shoppe open. But The Fellowship convinced me that I should join them. I proved my worthiness and The Fellowship helped me financially.\"")
            _RemoveAnswer("everything")
            _AddAnswer("worthiness")
        elseif answer == "worthiness" then
            say("\"I do not mind telling thee. The Fellowship shares in one half of my profit.\"")
            _RemoveAnswer("worthiness")
        elseif answer == "Thieves' Guild" then
            say("\"It is no more. They dwindled away during my grandfather's time. By the time The Fellowship arrived, when I was a boy, there was no trace of them except in family mementos. Even the pirates are different.\"")
            _RemoveAnswer("Thieves' Guild")
        elseif answer == "Crown Jewel" then
            if local2 then
                say("The cube vibrates a moment.~~\"That ship sails here frequently. I know it makes regular runs to the mainland, stops here, then moves on to the Isle of the Avatar the next morning. Then it repeats the trip, going the other direction.\"")
            else
                say("\"It stops here regularly. Don't know much more about it. The crew is very secretive.\" Budo looks away, obviously not wanting to talk about the ship.")
            end
            _RemoveAnswer("Crown Jewel")
        elseif answer == "bye" then
            say("\"I hope I can help thee again some time, my friend!\"*")
            return
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