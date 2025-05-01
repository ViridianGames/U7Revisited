-- Manages Gargan's dialogue in Trinsic, covering shipwright services, Crown Jewel and Hook knowledge, and Fellowship dismissal.
function func_0415(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8

    if eventid == 1 then
        switch_talk_to(21, 0)
        local0 = get_schedule()
        local1 = switch_talk_to(21)
        local2 = false

        add_answer({"bye", "murder", "job", "name"})
        if not get_flag(64) then
            add_answer("Crown Jewel")
        end
        if not get_flag(63) then
            add_answer("Fellowship")
        end
        if not get_flag(67) then
            add_answer("Hook")
        end

        if not get_flag(85) then
            add_dialogue("You see a salty old sailor who reeks of tobacco.")
            set_flag(85, true)
        else
            add_dialogue("\"Yes, matey?\" Gargan asks, coughing.")
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"My name is Gargan.\" He sniffs loudly.")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"I am the Trinsic shipwright. If thou wouldst like to know about a ship or a sextant, just say so.\"")
                add_dialogue("Gargan coughs.")
                add_answer({"sextant", "ship"})
            elseif answer == "ship" then
                add_dialogue("\"Thou dost want to buy a ship?\" the old man asks, smiling. (Apparently not too many folks buy ships these days.)")
                add_dialogue("\"My ships are sturdy and well built. They may not be built by Owen, but they are fine vessels! But thou must first purchase a deed.\"")
                add_dialogue("Gargan wipes his runny nose on his sleeve.")
                remove_answer("ship")
                add_answer({"deed", "Owen"})
            elseif answer == "sextant" then
                if local1 ~= 30 then
                    add_dialogue("\"Well, ye'll have to come to the shop when it is open.\"")
                else
                    add_dialogue("\"I sell sextants for 80 gold. Want one?\" Gargan clears his throat.")
                    if get_answer() then
                        local3 = get_gold()
                        if local3 >= 80 then
                            local4 = add_item(-359, -359, 650, 1, -357) -- Unmapped intrinsic 002C
                            if not local4 then
                                add_dialogue("\"Here ye are!\"")
                            else
                                add_dialogue("\"Thine arms are too full to carry the sextant!\" Gargan sneezes.")
                            end
                        else
                            add_dialogue("\"Thou dost not have enough gold, sailor.\" Gargan sneezes.")
                        end
                    else
                        add_dialogue("\"Suit thyself.\" Gargan sneezes.")
                    end
                end
                remove_answer("sextant")
            elseif answer == "Owen" then
                add_dialogue("\"Thou hast not heard of Owen? Finest shipwright in the land. He lives in Minoc.\" Gargan coughs.")
                remove_answer("Owen")
            elseif answer == "deed" then
                if local1 ~= 30 then
                    add_dialogue("\"Well, ye'll have to come to the shop when it is open.\"")
                else
                    if get_flag(88) then
                        add_dialogue("\"I already sold thee the deed to 'The Scaly Eel'! It was the only ship I had!\"")
                        add_dialogue("Gargan coughs loudly.")
                    else
                        add_dialogue("\"The deed I can sell thee is for the ship 'The Scaly Eel.' It goes for 600 gold. Interested?\"")
                        if get_answer() then
                            local5 = get_gold()
                            if local5 >= 600 then
                                local6 = add_item(-359, 14, 797, 1) -- Unmapped intrinsic 002C
                                if not local6 then
                                    add_dialogue("\"All right, then!\" the sailor replies. He hands you the deed and takes your gold. Gargan sneezes.")
                                    spend_gold(-359, -359, 644, 600) -- Unmapped intrinsic 002B
                                    set_flag(88, true)
                                else
                                    add_dialogue("\"Thou'rt already carrying enough to sink a galleon, Avatar! If thou wilt leave something behind, mayhaps thou wilt be able to sail, and I will be glad, indeed, to sell thee the deed.\" Gargan sneezes.")
                                end
                            else
                                add_dialogue("\"Sorry, matey,\" Gargan says. \"Thou dost not have enough gold!\" Gargan sneezes.")
                            end
                        else
                            add_dialogue("\"Some other time, then,\" the sailor shrugs, disappointed. Gargan sneezes.")
                        end
                    end
                end
                remove_answer("deed")
            elseif answer == "murder" then
                add_dialogue("\"I heard about that. Terrible thing to happen. Can't say I saw or heard anything, though.\" Gargan coughs, clears his throat loudly, then spits.")
                local7 = get_item_type(-2)
                if local7 then
                    switch_talk_to(2, 0)
                    add_dialogue("\"Ooooh, yuck!\"")
                    hide_npc(2)
                    switch_talk_to(21, 0)
                end
                remove_answer("murder")
            elseif answer == "Crown Jewel" then
                add_dialogue("\"Yes, that ship was docked overnight.\" He consults his log. \"She sailed for Britain at sunrise. I do not recall seeing anyone get on or off.\" Gargan snorts and coughs a couple of times.")
                remove_answer("Crown Jewel")
            elseif answer == "Hook" then
                add_dialogue("\"Matey, I have always seen pirates and sailors with peglegs and hooks. If thou hast seen one, thou hast seen another.\" But the man suddenly frowns. \"Hmm. Now that thou dost mention it, I -did- see a man with a hook late last night after sundown. I was leaving the shop and saw him outside. There was a wingless gargoyle with him. They were walking east.\"")
                add_dialogue("Gargan sneezes, then coughs a couple of times.")
                local8 = get_item_type(-2)
                if local8 then
                    switch_talk_to(2, 0)
                    add_dialogue("\"I told thee! It was him!\"")
                    hide_npc(2)
                    switch_talk_to(21, 0)
                end
                remove_answer("Hook")
            elseif answer == "Fellowship" then
                add_dialogue("\"I am too old to pay attention to them.\" Gargan wipes his runny nose on his sleeve.")
                remove_answer("Fellowship")
            elseif answer == "bye" then
                add_dialogue("\"May thy day have smooth sailing,\" the sailor starts to say, but a coughing spasm interrupts him.*")
                break
            end
            local2 = local2 + 1
            if local2 >= 6 then
                apply_effect() -- Unmapped intrinsic 088D
            end
        end
    elseif eventid == 0 then
        switch_talk_to(21)
    end
    return
end