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

    _SwitchTalkTo(0, -166)
    local0 = call_0909H()
    local1 = callis_003B()
    local2 = callis_001B(-166)
    local3 = callis_0067()
    _AddAnswer({"bye", "job", "name"})

    if get_flag(0x0212) and not get_flag(0x0218) then
        _AddAnswer("thief")
    end
    if not get_flag(0x021A) and not get_flag(0x021D) then
        _AddAnswer("delivery")
    end
    if not get_flag(0x021B) then
        _AddAnswer("Polly")
    end

    if not get_flag(0x021F) then
        say("You see a man covered in the sweat of a hard day's work.")
        set_flag(0x021F, true)
    else
        say("\"Greetings, ", local0, ",\" says Thurston.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"I am Thurston.\"")
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("\"I operate the mill here in Paws.\"")
            _AddAnswer({"Paws", "mill"})
        elseif answer == "mill" then
            say("\"The local economy depends upon the mill for flour. So I ensure that the mill runs. Sometimes, I feel that keeping the wheels turning is the only reason to live.\"")
            _AddAnswer({"reason to live", "flour"})
            _RemoveAnswer("mill")
        elseif answer == "flour" then
            if local2 == 7 then
                say("\"A sack will cost thee 12 gold. Art thou interested in purchasing some?\"")
                local4 = call_090AH()
                if local4 then
                    local5 = callis_0028(-359, -359, 644, -357)
                    if local5 >= 12 then
                        local6 = callis_002C(true, 14, -359, 863, 1)
                        if local6 then
                            local7 = callis_002B(true, -359, -359, 644, 12)
                            if local7 then
                                say("\"Here it is,\" he says, handing you the sack. \"Wouldst thou wish another?\"*")
                                local8 = call_090AH()
                                if not local8 then
                                    break
                                end
                            else
                                say("\"Thou hast not the gold for this, ", local0, ". Perhaps some other time.\"")
                            end
                        else
                            say("\"Thou hast not the room for this sack.\"")
                        end
                    else
                        say("\"Perhaps next time, ", local0, ".\"")
                    end
                else
                    say("\"Perhaps next time, ", local0, ".\"")
                end
            else
                say("\"The mill is closed at present. If thou wouldst please return when it is open again I would gladly sell thee all the flour thou canst carry.\"")
            end
            _RemoveAnswer("flour")
        elseif answer == "Paws" then
            say("\"In case thou hadst not noticed, the people who live here are not so well off as their cousins who live in Britain. In fact, we have even had a theft recently.\"")
            _RemoveAnswer("Paws")
            if not get_flag(0x0218) then
                _AddAnswer("theft")
            end
        elseif answer == "theft" or answer == "thief" then
            say("\"Indeed, thou shouldst be wary, ", local0, ". There is a thief in this town! Morfin, a merchant, had several vials of valuable silver snake venom stolen.\"")
            set_flag(0x0212, true)
            _RemoveAnswer({"thief", "theft"})
            _AddAnswer("snake venom")
        elseif answer == "snake venom" then
            say("\"It is procured from the Silver Serpent. I believe Gargoyles used it habitually in the old days. I am not so sure what it might do to a human. Perhaps Morfin can tell thee more.\"")
            _RemoveAnswer("snake venom")
        elseif answer == "delivery" then
            if get_flag(0x021D) then
                say("\"I have paid thee once for thy delivery. I shall not do so again.\"")
            else
                local8 = callis_002B(true, -359, -359, 677, 1)
                if local8 then
                    say("You give the sack over to Thurston. He opens it and reaches inside. His hand comes back out filled with wheat. He sifts through it with his fingers. \"I know Camille is oft quite busy running her farm. Thanks to thee for making the delivery.\"")
                    local9 = callis_002C(true, -359, -359, 644, 10)
                    if local9 then
                        say("\"This should compensate thee for thy trouble.\" He hands you ten gold pieces.")
                        set_flag(0x021D, true)
                    end
                else
                    say("\"'Tis a puzzlement! Camille promised to make a delivery of wheat to me sometime today and it is late. I wonder where it could be.\"")
                end
            end
            _RemoveAnswer("delivery")
        elseif answer == "reason to live" then
            say("\"I have no wife or family. I have thought about joining The Fellowship, but I refuse. I have nothing but my work, and a drink at the Salty Dog now and then.\"")
            _RemoveAnswer("reason to live")
            _AddAnswer({"Salty Dog", "Fellowship"})
        elseif answer == "Fellowship" then
            say("\"I know they do good work here in town, but there is just something about them that makes me uncomfortable.\"")
            if local3 then
                say("He notices your Fellowship medallion and hurriedly clears his throat. \"No offense intended, ", local0, ".\"")
            end
            _RemoveAnswer("Fellowship")
        elseif answer == "Salty Dog" then
            if not get_flag(0x0216) then
                say("\"In truth, I go there more to be near Polly, the innkeeper, than for the wine. But she is always busy tending bar and has no time for me, I am sure.\"")
                set_flag(0x0216, true)
            else
                say("\"I should go to the Salty Dog and see Polly.\" Thurston stares off into space for a few moments, his eyes are big and he has a moony expression on his face. Suddenly, he snaps back to reality. \"Excuse me, thou wert saying something?\"")
            end
            _RemoveAnswer("Salty Dog")
        elseif answer == "Polly" then
            if not get_flag(0x0231) then
                say("You relate to Thurston what Polly had said about him. He looks at you with joyous surprise. \"Did Polly really say these things?! It is ridiculous that she believes I am too good for her!\" Suddenly he forgets his work and starts hurrying around in excitement. \"For years I have loved this woman from afar. I will begin courting her immediately!\"")
                set_flag(0x0231, true)
            else
                say("\"I want to thank thee for telling me the truth about Polly's feelings about me. I can be such a stick in the mud running this bloody mill all of the time that I would never have noticed it if she were wearing a sign on her back! This is just what I needed to help me start enjoying my life!\"")
            end
            _RemoveAnswer("Polly")
        elseif answer == "bye" then
            say("\"Good day to thee, ", local0, ".\"*")
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