-- Function 04A6: Thurston's miller dialogue and wheat delivery
function func_04A6(eventid, itemref)
    -- Local variables (10 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9

    if eventid == 0 then
        call_092EH(-166)
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(166, 0)
    local0 = call_0909H()
    local1 = callis_003B()
    local2 = callis_001B(-166)
    local3 = callis_0067()
    add_answer({"bye", "job", "name"})

    if get_flag(0x0212) and not get_flag(0x0218) then
        add_answer("thief")
    end
    if not get_flag(0x021A) and not get_flag(0x021D) then
        add_answer("delivery")
    end
    if not get_flag(0x021B) then
        add_answer("Polly")
    end

    if not get_flag(0x021F) then
        add_dialogue("You see a man covered in the sweat of a hard day's work.")
        set_flag(0x021F, true)
    else
        add_dialogue("\"Greetings, ", local0, ",\" says Thurston.")
    end

    while true do
        local answer = wait_for_answer()

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
            if local2 == 7 then
                add_dialogue("\"A sack will cost thee 12 gold. Art thou interested in purchasing some?\"")
                local4 = call_090AH()
                if local4 then
                    local5 = callis_0028(-359, -359, 644, -357)
                    if local5 >= 12 then
                        local6 = callis_002C(true, 14, -359, 863, 1)
                        if local6 then
                            local7 = callis_002B(true, -359, -359, 644, 12)
                            if local7 then
                                add_dialogue("\"Here it is,\" he says, handing you the sack. \"Wouldst thou wish another?\"*")
                                local8 = call_090AH()
                                if not local8 then
                                    break
                                end
                            else
                                add_dialogue("\"Thou hast not the gold for this, ", local0, ". Perhaps some other time.\"")
                            end
                        else
                            add_dialogue("\"Thou hast not the room for this sack.\"")
                        end
                    else
                        add_dialogue("\"Perhaps next time, ", local0, ".\"")
                    end
                else
                    add_dialogue("\"Perhaps next time, ", local0, ".\"")
                end
            else
                add_dialogue("\"The mill is closed at present. If thou wouldst please return when it is open again I would gladly sell thee all the flour thou canst carry.\"")
            end
            remove_answer("flour")
        elseif answer == "Paws" then
            add_dialogue("\"In case thou hadst not noticed, the people who live here are not so well off as their cousins who live in Britain. In fact, we have even had a theft recently.\"")
            remove_answer("Paws")
            if not get_flag(0x0218) then
                add_answer("theft")
            end
        elseif answer == "theft" or answer == "thief" then
            add_dialogue("\"Indeed, thou shouldst be wary, ", local0, ". There is a thief in this town! Morfin, a merchant, had several vials of valuable silver snake venom stolen.\"")
            set_flag(0x0212, true)
            remove_answer({"thief", "theft"})
            add_answer("snake venom")
        elseif answer == "snake venom" then
            add_dialogue("\"It is procured from the Silver Serpent. I believe Gargoyles used it habitually in the old days. I am not so sure what it might do to a human. Perhaps Morfin can tell thee more.\"")
            remove_answer("snake venom")
        elseif answer == "delivery" then
            if get_flag(0x021D) then
                add_dialogue("\"I have paid thee once for thy delivery. I shall not do so again.\"")
            else
                local8 = callis_002B(true, -359, -359, 677, 1)
                if local8 then
                    add_dialogue("You give the sack over to Thurston. He opens it and reaches inside. His hand comes back out filled with wheat. He sifts through it with his fingers. \"I know Camille is oft quite busy running her farm. Thanks to thee for making the delivery.\"")
                    local9 = callis_002C(true, -359, -359, 644, 10)
                    if local9 then
                        add_dialogue("\"This should compensate thee for thy trouble.\" He hands you ten gold pieces.")
                        set_flag(0x021D, true)
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
            if local3 then
                add_dialogue("He notices your Fellowship medallion and hurriedly clears his throat. \"No offense intended, ", local0, ".\"")
            end
            remove_answer("Fellowship")
        elseif answer == "Salty Dog" then
            if not get_flag(0x0216) then
                add_dialogue("\"In truth, I go there more to be near Polly, the innkeeper, than for the wine. But she is always busy tending bar and has no time for me, I am sure.\"")
                set_flag(0x0216, true)
            else
                add_dialogue("\"I should go to the Salty Dog and see Polly.\" Thurston stares off into space for a few moments, his eyes are big and he has a moony expression on his face. Suddenly, he snaps back to reality. \"Excuse me, thou wert saying something?\"")
            end
            remove_answer("Salty Dog")
        elseif answer == "Polly" then
            if not get_flag(0x0231) then
                add_dialogue("You relate to Thurston what Polly had said about him. He looks at you with joyous surprise. \"Did Polly really say these things?! It is ridiculous that she believes I am too good for her!\" Suddenly he forgets his work and starts hurrying around in excitement. \"For years I have loved this woman from afar. I will begin courting her immediately!\"")
                set_flag(0x0231, true)
            else
                add_dialogue("\"I want to thank thee for telling me the truth about Polly's feelings about me. I can be such a stick in the mud running this bloody mill all of the time that I would never have noticed it if she were wearing a sign on her back! This is just what I needed to help me start enjoying my life!\"")
            end
            remove_answer("Polly")
        elseif answer == "bye" then
            add_dialogue("\"Good day to thee, ", local0, ".\"*")
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