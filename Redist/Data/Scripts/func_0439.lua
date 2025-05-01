-- Manages Clint's dialogue in Britain, covering ship and sextant sales, sailing past, and opinions on the Fellowship and Crown Jewel.
function func_0439(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11

    if eventid == 1 then
        switch_talk_to(57, 0)
        local0 = get_party_size()
        local1 = switch_talk_to(57)
        local2 = get_player_name()
        local3 = get_item_type()

        add_answer({"bye", "job", "name"})

        if not get_flag(74) and not get_flag(64) then
            add_answer("Crown Jewel")
        end

        if not get_flag(186) then
            add_dialogue("Before you stands an old sailing man whose determined face appears to have weathered many a storm.")
            set_flag(186, true)
        else
            add_dialogue("\"And what be thy business with me this time, " .. local2 .. "?\" says Clint.")
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"I be Clint.\"")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"In my youth I was a sailor who sailed across the sea in tall ships. Now I must content myself solely with selling ships and sextants to others.\"")
                add_answer({"buy", "sailor"})
            elseif answer == "sailor" then
                add_dialogue("\"Of course this was in the day when it took mighty men to be a sailor. Nowadays those who set out to sea would not have lasted a day. But I suppose it is the nature of the universe that everything slowly becomes more tame.\"")
                remove_answer("sailor")
                add_answer("tame")
            elseif answer == "tame" then
                add_dialogue("\"Soon all the monsters will die off and the whole world will join together in trust and worthiness and unity like all those Fellowship people say. Bah! The world was a better place when everybody fought everybody else, I say.\"")
                remove_answer("tame")
                add_answer("Fellowship")
            elseif answer == "Fellowship" then
                if local3 then
                    add_dialogue("\"No offense intended, of course. I did not realize that thou art a member.\" Clint reacts as if he has just touched a leper.")
                    remove_answer("Fellowship")
                else
                    add_dialogue("\"It is always the best thing to make thine own way in the world and not listen to what thou art told to believe. Thou hast better remember that!\"")
                    remove_answer("Fellowship")
                end
            elseif answer == "buy" then
                if local1 == 7 then
                    add_dialogue("\"If thou art in need of a ship I hold the deed to a fine one. Thou wilt also need a sextant to help steer her true.\"")
                    add_answer({"buy sextant", "buy ship deed"})
                else
                    add_dialogue("\"My business is now closed. Return another time and I will be happy to serve thee, " .. local2 .. ".\"")
                end
                remove_answer("buy")
            elseif answer == "buy ship deed" then
                if get_flag(210) then
                    add_dialogue("\"I do believe I sold thee the deed to 'The Beast'! What happened to it? Hast thou lost the ship? If so, then thou must find another shipwright!\"")
                else
                    add_dialogue("\"The deed to the ship 'The Beast' costs eight hundred gold pieces. Dost thou wish to purchase her?\"")
                    local4 = get_answer()
                    if local4 then
                        local5 = remove_gold(-359, -359, 644, 800) -- Unmapped intrinsic
                        if local5 then
                            local6 = add_item(-359, 15, 797, 1) -- Unmapped intrinsic
                            if local6 then
                                add_dialogue("\"Here is thy deed, " .. local2 .. ".\"")
                                set_flag(210, true)
                            else
                                add_dialogue("\"I would give thee thy deed but thou art carrying too much to take it from me!\"")
                            end
                        else
                            add_dialogue("\"Thou dost not have enough gold to buy a ship!\"")
                        end
                    else
                        add_dialogue("\"If thou dost need a ship be sure to come back here.\"")
                    end
                end
                remove_answer("buy ship deed")
            elseif answer == "buy sextant" then
                add_dialogue("\"A sextant costs one hundred gold pieces. Does thou wish to buy one?\"")
                local7 = get_answer()
                if local7 then
                    local8 = remove_gold(-359, -359, 644, 100) -- Unmapped intrinsic
                    if local8 then
                        local9 = add_item(-359, -359, 650, 1) -- Unmapped intrinsic
                        if local9 then
                            add_dialogue("\"Here is thy sextant. She shall steer thee true, to be sure.\"")
                        else
                            add_dialogue("\"I would give thee thy sextant, but thou art carrying too much to take it from me.\"")
                        end
                    else
                        add_dialogue("\"Thou dost not have enough money to buy a sextant!\"")
                    end
                else
                    add_dialogue("\"If thou shouldst ever need a sextant be sure to come back.\"")
                end
                remove_answer("buy sextant")
            elseif answer == "Crown Jewel" then
                if not get_flag(134) then
                    add_dialogue("\"The Crown Jewel came to Britain? Not anytime recently. Most certainly not. I remember the Crown Jewel and it has not been to Britain for a long time.\"")
                    set_flag(134, true)
                else
                    add_dialogue("\"As I have told thee before, the Crown Jewel has not been here in a long time.\"")
                end
                remove_answer("Crown Jewel")
            elseif answer == "bye" then
                add_dialogue("\"May thy travels do well.\"*")
                break
            end
        end
    elseif eventid == 0 then
        local0 = get_party_size()
        local1 = switch_talk_to(57)
        local10 = random(1, 4)
        local11 = ""

        if local1 == 7 then
            if local10 == 1 then
                local11 = "@Where's that spanner?@"
            elseif local10 == 2 then
                local11 = "@Where's mine hammer?@"
            elseif local10 == 3 then
                local11 = "@Ahh, smell that sea breeze...@"
            elseif local10 == 4 then
                local11 = "@Need a ship or sextant?@"
            end
            bark(57, local11)
        else
            switch_talk_to(57)
        end
    end
    return
end