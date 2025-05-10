--- Best guess: Manages Thurston’s dialogue in Paws, discussing the mill, a theft, and his feelings for Polly.
function func_04A6(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009

    if eventid == 1 then
        switch_talk_to(0, 166)
        var_0000 = get_lord_or_lady()
        var_0001 = unknown_003BH()
        var_0002 = unknown_001CH(unknown_001BH(166))
        var_0003 = unknown_0067H()
        start_conversation()
        add_answer({"bye", "job", "name"})
        if not get_flag(530) and not get_flag(536) then
            add_answer("thief")
        end
        if not get_flag(538) and not get_flag(541) then
            add_answer("delivery")
        end
        if not get_flag(539) then
            add_answer("Polly")
        end
        if not get_flag(543) then
            add_dialogue("You see a man covered in the sweat of a hard day's work.")
            set_flag(543, true)
        else
            add_dialogue("\"Greetings, " .. var_0000 .. ",\" says Thurston.")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"I am Thurston.\"")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"I operate the mill here in Paws.\"")
                add_answer({"Paws", "mill"})
            elseif answer == "mill" then
                add_dialogue("\"The local economy depends upon the mill for flour. So I ensure that the mill runs. Sometimes, I feel that keeping the wheels turning is the only reason to live.\"")
                add_answer({"reason to live", "flour"})
                remove_answer("mill")
            elseif answer == "flour" then
                if var_0002 == 7 then
                    add_dialogue("\"A sack will cost thee 12 gold. Art thou interested in purchasing some?\"")
                    var_0004 = unknown_090AH()
                    if var_0004 then
                        var_0005 = unknown_0028H(359, 644, 359, 357)
                        if var_0005 >= 12 then
                            var_0006 = unknown_002CH(true, 359, 863, 14, 1)
                            if var_0006 then
                                add_dialogue("\"Here it is,\" he says, handing you the sack. \"Wouldst thou wish another?\"")
                                var_0007 = unknown_090AH()
                                if var_0007 then
                                    -- Loop back to purchase another sack
                                else
                                    break
                                end
                            else
                                add_dialogue("\"Thou hast not the room for this sack.\"")
                            end
                        else
                            add_dialogue("\"Thou hast not the gold for this, " .. var_0000 .. ". Perhaps some other time.\"")
                        end
                    else
                        add_dialogue("\"Perhaps next time, " .. var_0000 .. ".\"")
                    end
                else
                    add_dialogue("\"The mill is closed at present. If thou wouldst please return when it is open again I would gladly sell thee all the flour thou canst carry.\"")
                end
                remove_answer("flour")
            elseif answer == "Paws" then
                add_dialogue("\"In case thou hadst not noticed, the people who live here are not so well off as their cousins who live in Britain. In fact, we have even had a theft recently.\"")
                remove_answer("Paws")
                if not get_flag(536) then
                    add_answer("theft")
                end
            elseif answer == "theft" or answer == "thief" then
                add_dialogue("\"Indeed, thou shouldst be wary, " .. var_0000 .. ". There is a thief in this town! Morfin, a merchant, had several vials of valuable silver snake venom stolen.\"")
                set_flag(530, true)
                remove_answer({"thief", "theft"})
                add_answer("snake venom")
            elseif answer == "snake venom" then
                add_dialogue("\"It is procured from the Silver Serpent. I believe Gargoyles used it habitually in the old days. I am not so sure what it might do to a human. Perhaps Morfin can tell thee more.\"")
                remove_answer("snake venom")
            elseif answer == "delivery" then
                if get_flag(541) then
                    add_dialogue("\"I have paid thee once for thy delivery. I shall not do so again.\"")
                else
                    var_0008 = unknown_002BH(true, 359, 677, 359, 1)
                    if var_0008 then
                        add_dialogue("You give the sack over to Thurston. He opens it and reaches inside. His hand comes back out filled with wheat. He sifts through it with his fingers. \"I know Camille is oft quite busy running her farm. Thanks to thee for making the delivery.\"")
                        var_0009 = unknown_002CH(true, 359, 644, 359, 10)
                        if var_0009 then
                            add_dialogue("\"This should compensate thee for thy trouble.\" He hands you ten gold pieces.")
                            set_flag(541, true)
                        end
                    else
                        add_dialogue("\"'Tis a puzzlement! Camille promised to make a delivery of wheat to me sometime today and it is late. I wonder where it could be.\"")
                    end
                end
                remove_answer("delivery")
            elseif answer == "reason to live" then
                add_dialogue("\"I have no wife or family. I have thought about joining The Fellowship, but I refuse. I have nothing but my work, and a drink at the Salty Dog now and then.\"")
                remove_answer("reason to live")
                add_answer({"Salty Dog", "Fellowship"})
            elseif answer == "Fellowship" then
                add_dialogue("\"I know they do good work here in town, but there is just something about them that makes me uncomfortable.\"")
                if var_0003 then
                    add_dialogue("He notices your Fellowship medallion and hurriedly clears his throat. \"No offense intended, " .. var_0000 .. ".\"")
                end
                remove_answer("Fellowship")
            elseif answer == "Salty Dog" then
                if not get_flag(534) then
                    add_dialogue("\"In truth, I go there more to be near Polly, the innkeeper, than for the wine. But she is always busy tending bar and has no time for me, I am sure.\"")
                    set_flag(534, true)
                else
                    add_dialogue("\"I should go to the Salty Dog and see Polly.\" Thurston stares off into space for a few moments, his eyes are big and he has a moony expression on his face. Suddenly, he snaps back to reality. \"Excuse me, thou wert saying something?\"")
                end
                remove_answer("Salty Dog")
            elseif answer == "Polly" then
                if not get_flag(561) then
                    add_dialogue("You relate to Thurston what Polly had said about him. He looks at you with joyous surprise. \"Did Polly really say these things?! It is ridiculous that she believes I am too good for her!\" Suddenly he forgets his work and starts hurrying around in excitement. \"For years I have loved this woman from afar. I will begin courting her immediately!\"")
                    set_flag(561, true)
                else
                    add_dialogue("\"I want to thank thee for telling me the truth about Polly's feelings about me. I can be such a stick in the mud running this bloody mill all of the time that I would never have noticed it if she were wearing a sign on her back! This is just what I needed to help me start enjoying my life!\"")
                end
                remove_answer("Polly")
            elseif answer == "bye" then
                add_dialogue("\"Good day to thee, " .. var_0000 .. ".\"")
                break
            end
        end
    elseif eventid == 0 then
        unknown_092EH(166)
    end
    return
end