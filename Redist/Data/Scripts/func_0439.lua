--- Best guess: Handles dialogue with Clint, a former sailor and shipwright in Britain, selling ship deeds and sextants, expressing disdain for the Fellowship and a tamed world.
function func_0439(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B

    start_conversation()
    if eventid == 1 then
        switch_talk_to(57, 0)
        var_0000 = unknown_003BH() --- Guess: Checks game state or timer
        var_0001 = unknown_001CH(57) --- Guess: Gets object state
        var_0002 = get_lord_or_lady()
        var_0003 = unknown_0067H() --- Guess: Checks Fellowship membership
        add_answer({"bye", "job", "name"})
        if not get_flag(74) or not get_flag(64) then
            add_answer("Crown Jewel")
        end
        if not get_flag(186) then
            add_dialogue("Before you stands an old sailing man whose determined face appears to have weathered many a storm.")
            set_flag(186, true)
        else
            add_dialogue("\"And what be thy business with me this time, " .. var_0002 .. "?\" says Clint.")
        end
        while true do
            var_0004 = get_answer()
            if var_0004 == "name" then
                add_dialogue("\"I be Clint.\"")
                remove_answer("name")
            elseif var_0004 == "job" then
                add_dialogue("\"In my youth I was a sailor who sailed across the sea in tall ships. Now I must content myself solely with selling ships and sextants to others.\"")
                add_answer({"buy", "sailor"})
            elseif var_0004 == "sailor" then
                add_dialogue("\"Of course this was in the day when it took mighty men to be a sailor. Nowadays those who set out to sea would not have lasted a day. But I suppose it is the nature of the universe that everything slowly becomes more tame.\"")
                remove_answer("sailor")
                add_answer("tame")
            elseif var_0004 == "tame" then
                add_dialogue("\"Soon all the monsters will die off and the whole world will join together in trust and worthiness and unity like all those Fellowship people say. Bah! The world was a better place when everybody fought everybody else, I say.\"")
                remove_answer("tame")
                add_answer("Fellowship")
            elseif var_0004 == "Fellowship" then
                if var_0003 then
                    add_dialogue("\"No offense intended, of course. I did not realize that thou art a member.\" Clint reacts as if he has just touched a leper.")
                    remove_answer("Fellowship")
                else
                    add_dialogue("\"It is always the best thing to make thine own way in the world and not listen to what thou art told to believe. Thou hast better remember that!\"")
                    remove_answer("Fellowship")
                end
            elseif var_0004 == "buy" then
                if var_0001 == 7 then
                    add_dialogue("\"If thou art in need of a ship I hold the deed to a fine one. Thou wilt also need a sextant to help steer her true.\"")
                    add_answer({"buy sextant", "buy ship deed"})
                else
                    add_dialogue("\"My business is now closed. Return another time and I will be happy to serve thee, " .. var_0002 .. ".\"")
                end
                remove_answer("buy")
            elseif var_0004 == "buy ship deed" then
                if get_flag(210) then
                    add_dialogue("\"I do believe I sold thee the deed to 'The Beast'! What happened to it? Hast thou lost the ship? If so, then thou must find another shipwright!\"")
                else
                    add_dialogue("\"The deed to the ship 'The Beast' costs eight hundred gold pieces. Dost thou wish to purchase her?\"")
                    var_0004 = select_option()
                    if var_0004 then
                        var_0005 = unknown_002B(true, 359, 359, 644, 800) --- Guess: Deducts gold and adds item
                        if var_0005 then
                            var_0006 = unknown_002C(false, 359, 15, 797, 1) --- Guess: Checks inventory space
                            if var_0006 then
                                add_dialogue("\"Here is thy deed, " .. var_0002 .. ".\"")
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
            elseif var_0004 == "buy sextant" then
                add_dialogue("\"A sextant costs one hundred gold pieces. Does thou wish to buy one?\"")
                var_0007 = select_option()
                if var_0007 then
                    var_0008 = unknown_002B(true, 359, 359, 644, 100) --- Guess: Deducts gold and adds item
                    if var_0008 then
                        var_0009 = unknown_002C(false, 359, 359, 650, 1) --- Guess: Checks inventory space
                        if var_0009 then
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
            elseif var_0004 == "Crown Jewel" then
                if not get_flag(134) then
                    add_dialogue("\"The Crown Jewel came to Britain? Not anytime recently. Most certainly not. I remember the Crown Jewel and it has not been to Britain for a long time.\"")
                    set_flag(134, true)
                else
                    add_dialogue("\"As I have told thee before, the Crown Jewel has not been here in a long time.\"")
                    remove_answer("Crown Jewel")
                end
                remove_answer("Crown Jewel")
            elseif var_0004 == "bye" then
                break
            end
        end
        add_dialogue("\"May thy travels do well.\"")
    elseif eventid == 0 then
        var_0001 = unknown_001CH(57) --- Guess: Gets object state
        if var_0001 == 7 then
            var_000A = random(1, 4)
            if var_000A == 1 then
                var_000B = "@Where's that spanner?@"
            elseif var_000A == 2 then
                var_000B = "@Where's mine hammer?@"
            elseif var_000A == 3 then
                var_000B = "@Ahh, smell that sea breeze...@"
            elseif var_000A == 4 then
                var_000B = "@Need a ship or sextant?@"
            end
            bark(57, var_000B)
        else
            unknown_092EH(57) --- Guess: Triggers a game event
        end
    end
end