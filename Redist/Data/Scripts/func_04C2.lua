require "U7LuaFuncs"
-- Function 04C2: Jehanne's provisioner dialogue, ship sale, and Pendaran's misdeeds
function func_04C2(eventid, itemref)
    -- Local variables (13 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6
    local local7, local8, local9, local10, local11, local12

    if eventid == 0 then
        local10 = callis_003B()
        local8 = callis_001C(callis_001B(-194))
        local11 = callis_Random2(4, 1)
        if local8 == 7 then
            if local11 == 1 then
                _ItemSay("@Provisions!@", -194)
            elseif local11 == 2 then
                _ItemSay("@Buy in advance!@", -194)
            elseif local11 == 3 then
                _ItemSay("@Best provisions in town!@", -194)
            elseif local11 == 4 then
                _ItemSay("@Be equipped!@", -194)
            end
        elseif local8 == 26 then
            if local11 == 1 then
                _ItemSay("@Wondrous fine food!@", -194)
            elseif local11 == 2 then
                _ItemSay("@Fine drink!@", -194)
            elseif local11 == 3 then
                _ItemSay("@Mmmmm...@", -194)
            elseif local11 == 4 then
                _ItemSay("@I am full.@", -194)
            end
        end
        return
    elseif eventid ~= 1 then
        return
    end

    _SwitchTalkTo(0, -194)
    local0 = call_0908H()
    local1 = call_0909H()
    local2 = false
    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x026B) then
        say("The woman greets you with a curtsey.")
        set_flag(0x026B, true)
    else
        say("\"Good day, ", local1, ",\" says Lady Jehanne.")
    end

    if not get_flag(0x027C) and get_flag(0x025C) and not get_flag(0x025D) then
        _AddAnswer("commons")
        local2 = true
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"I am the Lady Jehanne, ", local1, ".\"")
            set_flag(0x027C, true)
            _RemoveAnswer("name")
            if get_flag(0x025C) and not get_flag(0x025D) and not local2 then
                _AddAnswer("commons")
            end
        elseif answer == "job" then
            say("\"I am the provisioner of Serpent's Hold.\"")
            if not get_flag(0x0274) then
                say("\"And,\" she adds, \"I also have a ship for sale shouldst thou be interested in that.\"")
                _AddAnswer("ship")
            end
            _AddAnswer({"provisions", "Serpent's Hold"})
        elseif answer == "ship" then
            say("\"Well, it was once the magnificent `Constellation.' However, 'twas destroyed by the ship's captain, himself, to prevent it from falling into the hands of attacking pirates. What little remained was rebuilt into an even finer ship, `The Dragon's Breath?' Art thou interested in purchasing it for 600 gold?\"")
            local3 = call_090AH()
            if local3 then
                local4 = callis_0028(-359, -359, 644, -357)
                if local4 >= 600 then
                    local5 = callis_002C(false, -359, 19, 797, 1)
                    if local5 then
                        say("\"Here is thy deed.\"")
                        local6 = callis_002B(true, -359, -359, 644, 600)
                        set_flag(0x0274, true)
                    else
                        say("\"Sadly, ", local1, ", thou hast not the room for this deed.\"")
                    end
                else
                    say("\"I understand, ", local1, ", thou hast not the funds at this time.\"")
                end
            else
                say("\"Perhaps sometime in the future, ", local1, ".\"")
            end
            _RemoveAnswer("ship")
        elseif answer == "Serpent's Hold" then
            say("\"Most of us here are knights, noble warriors sworn to protect Britannia and Lord British. Mine own lord,\" she beams with pride, \"is such a knight -- Sir Pendaran.\"")
            _AddAnswer({"knights", "Sir Pendaran"})
            _RemoveAnswer("Serpent's Hold")
        elseif answer == "Sir Pendaran" then
            say("\"We met three years ago. He's quite brave and strong. I just love to watch him fight.\" She smiles.~~\"I am not really sure he will mix well with the rest of The Fellowship, though.\"")
            _AddAnswer({"Fellowship", "fight"})
            _RemoveAnswer("Sir Pendaran")
        elseif answer == "fight" then
            say("\"He and Menion used to spar together, after their exercises. 'Twas a beautiful... sight, ", local1, ",\" she says, blushing.")
            _AddAnswer("used to")
            _RemoveAnswer("fight")
        elseif answer == "used to" then
            say("\"At the time, Pendaran was the only man who could keep up with Menion. Now that Menion has begun instructing others, he no longer has the time to practice with my Lord.\"")
            _RemoveAnswer("used to")
        elseif answer == "Fellowship" then
            local7 = callis_0067()
            if local7 then
                say("\"Well, er, I mean, he would not have mixed well -before- he joined, that is,\" she stammers.")
            else
                say("\"It's nothing really. He was just a little bit more... individualistic before he joined. I do not think there's anything wrong with The Fellowship, necessarily; but I did not expect it to be something that would capture Pendaran's interest.\"")
            end
            _RemoveAnswer("Fellowship")
        elseif answer == "knights" then
            say("With but a few exceptions, myself included, all of the warriors here in the Hold are knights. Thou mayest wish to speak with Lord John-Paul. He is in charge of Serpent's Hold and might be better able to show thee around.")
            _RemoveAnswer("knights")
        elseif answer == "provisions" then
            local8 = callis_001C(callis_001B(-194))
            if local8 == 7 then
                say("\"Thou wishest to buy something?\"")
                local9 = call_090AH()
                if local9 then
                    call_08A1H()
                else
                    say("\"Well, perhaps next time, ", local1, ".\"")
                end
            else
                say("\"A better time to buy would be when my shop is open.\"")
            end
            _RemoveAnswer("provisions")
        elseif answer == "commons" then
            say("For an instant, you see indecisiveness in her expression, then she suddenly gives in, her words coming out in a torrent of information.~~\"I am afraid to speak, but knowing thou wouldst see through any facade, I can no longer silence the truth. My Lord, Sir Pendaran, has not been the same gentle soul since he joined the Fellowship.~~\"'Twas not too long ago that my Pendaran was a noble knight, one a lady could be proud of. But now,\" she shakes her head, \"in protest of a wrong he perceives in Britannia's government, he has defaced the statue of our beloved Lord British.\" She begins to sob.~~\"And, he has battled and wounded a fellow knight who chanced upon him during his hour of misdeed. He came to me,\" she tries to choke back her tears, \"with another's blood on his sword!\"~~After a few moments of your comforting, she regains her composure.~~\"Please do not be too harsh with him,\" she begs.")
            set_flag(0x025D, true)
            _RemoveAnswer("commons")
            _AddAnswer("another")
        elseif answer == "another" then
            say("\"I know not who, ", local1, ", and Pendaran would not say!\"")
            _RemoveAnswer("another")
        elseif answer == "bye" then
            say("\"May fortune follow thee, ", local1, ".\"*")
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