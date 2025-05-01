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
                bark(194, "@Provisions!@")
            elseif local11 == 2 then
                bark(194, "@Buy in advance!@")
            elseif local11 == 3 then
                bark(194, "@Best provisions in town!@")
            elseif local11 == 4 then
                bark(194, "@Be equipped!@")
            end
        elseif local8 == 26 then
            if local11 == 1 then
                bark(194, "@Wondrous fine food!@")
            elseif local11 == 2 then
                bark(194, "@Fine drink!@")
            elseif local11 == 3 then
                bark(194, "@Mmmmm...@")
            elseif local11 == 4 then
                bark(194, "@I am full.@")
            end
        end
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(194, 0)
    local0 = call_0908H()
    local1 = call_0909H()
    local2 = false
    add_answer({"bye", "job", "name"})

    if not get_flag(0x026B) then
        add_dialogue("The woman greets you with a curtsey.")
        set_flag(0x026B, true)
    else
        add_dialogue("\"Good day, ", local1, ",\" says Lady Jehanne.")
    end

    if not get_flag(0x027C) and get_flag(0x025C) and not get_flag(0x025D) then
        add_answer("commons")
        local2 = true
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"I am the Lady Jehanne, ", local1, ".\"")
            set_flag(0x027C, true)
            remove_answer("name")
            if get_flag(0x025C) and not get_flag(0x025D) and not local2 then
                add_answer("commons")
            end
        elseif answer == "job" then
            add_dialogue("\"I am the provisioner of Serpent's Hold.\"")
            if not get_flag(0x0274) then
                add_dialogue("\"And,\" she adds, \"I also have a ship for sale shouldst thou be interested in that.\"")
                add_answer("ship")
            end
            add_answer({"provisions", "Serpent's Hold"})
        elseif answer == "ship" then
            add_dialogue("\"Well, it was once the magnificent `Constellation.' However, 'twas destroyed by the ship's captain, himself, to prevent it from falling into the hands of attacking pirates. What little remained was rebuilt into an even finer ship, `The Dragon's Breath?' Art thou interested in purchasing it for 600 gold?\"")
            local3 = call_090AH()
            if local3 then
                local4 = callis_0028(-359, -359, 644, -357)
                if local4 >= 600 then
                    local5 = callis_002C(false, -359, 19, 797, 1)
                    if local5 then
                        add_dialogue("\"Here is thy deed.\"")
                        local6 = callis_002B(true, -359, -359, 644, 600)
                        set_flag(0x0274, true)
                    else
                        add_dialogue("\"Sadly, ", local1, ", thou hast not the room for this deed.\"")
                    end
                else
                    add_dialogue("\"I understand, ", local1, ", thou hast not the funds at this time.\"")
                end
            else
                add_dialogue("\"Perhaps sometime in the future, ", local1, ".\"")
            end
            remove_answer("ship")
        elseif answer == "Serpent's Hold" then
            add_dialogue("\"Most of us here are knights, noble warriors sworn to protect Britannia and Lord British. Mine own lord,\" she beams with pride, \"is such a knight -- Sir Pendaran.\"")
            add_answer({"knights", "Sir Pendaran"})
            remove_answer("Serpent's Hold")
        elseif answer == "Sir Pendaran" then
            add_dialogue("\"We met three years ago. He's quite brave and strong. I just love to watch him fight.\" She smiles.~~\"I am not really sure he will mix well with the rest of The Fellowship, though.\"")
            add_answer({"Fellowship", "fight"})
            remove_answer("Sir Pendaran")
        elseif answer == "fight" then
            add_dialogue("\"He and Menion used to spar together, after their exercises. 'Twas a beautiful... sight, ", local1, ",\" she says, blushing.")
            add_answer("used to")
            remove_answer("fight")
        elseif answer == "used to" then
            add_dialogue("\"At the time, Pendaran was the only man who could keep up with Menion. Now that Menion has begun instructing others, he no longer has the time to practice with my Lord.\"")
            remove_answer("used to")
        elseif answer == "Fellowship" then
            local7 = callis_0067()
            if local7 then
                add_dialogue("\"Well, er, I mean, he would not have mixed well -before- he joined, that is,\" she stammers.")
            else
                add_dialogue("\"It's nothing really. He was just a little bit more... individualistic before he joined. I do not think there's anything wrong with The Fellowship, necessarily; but I did not expect it to be something that would capture Pendaran's interest.\"")
            end
            remove_answer("Fellowship")
        elseif answer == "knights" then
            add_dialogue("With but a few exceptions, myself included, all of the warriors here in the Hold are knights. Thou mayest wish to speak with Lord John-Paul. He is in charge of Serpent's Hold and might be better able to show thee around.")
            remove_answer("knights")
        elseif answer == "provisions" then
            local8 = callis_001C(callis_001B(-194))
            if local8 == 7 then
                add_dialogue("\"Thou wishest to buy something?\"")
                local9 = call_090AH()
                if local9 then
                    call_08A1H()
                else
                    add_dialogue("\"Well, perhaps next time, ", local1, ".\"")
                end
            else
                add_dialogue("\"A better time to buy would be when my shop is open.\"")
            end
            remove_answer("provisions")
        elseif answer == "commons" then
            add_dialogue("For an instant, you see indecisiveness in her expression, then she suddenly gives in, her words coming out in a torrent of information.~~\"I am afraid to speak, but knowing thou wouldst see through any facade, I can no longer silence the truth. My Lord, Sir Pendaran, has not been the same gentle soul since he joined the Fellowship.~~\"'Twas not too long ago that my Pendaran was a noble knight, one a lady could be proud of. But now,\" she shakes her head, \"in protest of a wrong he perceives in Britannia's government, he has defaced the statue of our beloved Lord British.\" She begins to sob.~~\"And, he has battled and wounded a fellow knight who chanced upon him during his hour of misdeed. He came to me,\" she tries to choke back her tears, \"with another's blood on his sword!\"~~After a few moments of your comforting, she regains her composure.~~\"Please do not be too harsh with him,\" she begs.")
            set_flag(0x025D, true)
            remove_answer("commons")
            add_answer("another")
        elseif answer == "another" then
            add_dialogue("\"I know not who, ", local1, ", and Pendaran would not say!\"")
            remove_answer("another")
        elseif answer == "bye" then
            add_dialogue("\"May fortune follow thee, ", local1, ".\"*")
            return
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