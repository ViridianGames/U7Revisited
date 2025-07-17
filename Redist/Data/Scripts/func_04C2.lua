--- Best guess: Manages Lady Jehanne’s dialogue in Serpent’s Hold, a provisioner selling a ship and revealing Sir Pendaran’s statue defacement.
function func_04C2(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C

    if eventid == 1 then
        switch_talk_to(0, 194)
        var_0000 = get_player_name()
        var_0001 = get_lord_or_lady()
        var_0002 = false
        start_conversation()
        add_answer({"bye", "job", "name"})
        if not get_flag(619) then
            add_dialogue("The woman greets you with a curtsey.")
            set_flag(619, true)
        else
            add_dialogue("\"Good day, \" .. var_0001 .. \",\" says Lady Jehanne.")
        end
        if get_flag(604) and not get_flag(605) then
            add_answer("commons")
            var_0002 = true
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"I am the Lady Jehanne, \" .. var_0001 .. \".\"")
                set_flag(636, true)
                remove_answer("name")
                if get_flag(604) and not get_flag(605) and not var_0002 then
                    add_answer("commons")
                end
            elseif answer == "job" then
                add_dialogue("\"I am the provisioner of Serpent's Hold.\"")
                if not get_flag(628) then
                    add_dialogue("\"And,\" she adds, \"I also have a ship for sale shouldst thou be interested in that.\"")
                    add_answer("ship")
                end
                add_answer({"provisions", "Serpent's Hold"})
            elseif answer == "ship" then
                add_dialogue("\"Well, it was once the magnificent `Constellation.' However, 'twas destroyed by the ship's captain, himself, to prevent it from falling into the hands of attacking pirates. What little remained was rebuilt into an even finer ship, `The Dragon's Breath?' Art thou interested in purchasing it for 600 gold?\"")
                var_0003 = ask_yes_no()
                if var_0003 then
                    var_0004 = get_party_gold()
                    if var_0004 >= 600 then
                        var_0005 = unknown_002CH(false, 359, 19, 797, 1)
                        if var_0005 then
                            add_dialogue("\"Here is thy deed.\"")
                            var_0006 = unknown_002BH(true, 359, 359, 644, 600)
                            set_flag(628, true)
                        else
                            add_dialogue("\"Sadly, \" .. var_0001 .. \", thou hast not the room for this deed.\"")
                        end
                    else
                        add_dialogue("\"I understand, \" .. var_0001 .. \", thou hast not the funds at this time.\"")
                    end
                else
                    add_dialogue("\"Perhaps sometime in the future, \" .. var_0001 .. \".\"")
                end
                remove_answer("ship")
            elseif answer == "Serpent's Hold" then
                add_dialogue("\"Most of us here are knights, noble warriors sworn to protect Britannia and Lord British. Mine own lord,\" she beams with pride, \"is such a knight -- Sir Pendaran.\"")
                remove_answer("Serpent's Hold")
                add_answer({"knights", "Sir Pendaran"})
            elseif answer == "Sir Pendaran" then
                add_dialogue("\"We met three years ago. He's quite brave and strong. I just love to watch him fight.\" She smiles.")
                add_dialogue("\"I am not really sure he will mix well with the rest of The Fellowship, though.\"")
                remove_answer("Sir Pendaran")
                add_answer({"Fellowship", "fight"})
            elseif answer == "fight" then
                add_dialogue("\"He and Menion used to spar together, after their exercises. 'Twas a beautiful... sight, \" .. var_0001 .. \",\" she says, blushing.")
                remove_answer("fight")
                add_answer("used to")
            elseif answer == "used to" then
                add_dialogue("\"At the time, Pendaran was the only man who could keep up with Menion. Now that Menion has begun instructing others, he no longer has the time to practice with my Lord.\"")
                remove_answer("used to")
            elseif answer == "Fellowship" then
                var_0007 = is_player_wearing_fellowship_medallion()
                if var_0007 then
                    add_dialogue("\"Well, er, I mean, he would not have mixed well -before- he joined, that is,\" she stammers.")
                else
                    add_dialogue("\"It's nothing really. He was just a little bit more... individualistic before he joined. I do not think there's anything wrong with The Fellowship, necessarily; but I did not expect it to be something that would capture Pendaran's interest.\"")
                end
                remove_answer("Fellowship")
            elseif answer == "knights" then
                add_dialogue("With but a few exceptions, myself included, all of the warriors here in the Hold are knights. Thou mayest wish to speak with Lord John-Paul. He is in charge of Serpent's Hold and might be better able to show thee around.")
                remove_answer("knights")
            elseif answer == "provisions" then
                var_0008 = unknown_001CH(get_npc_name(194))
                if var_0008 == 7 then
                    add_dialogue("\"Thou wishest to buy something?\"")
                    var_0009 = ask_yes_no()
                    if var_0009 then
                        unknown_08A1H()
                    else
                        add_dialogue("\"Well, perhaps next time, \" .. var_0001 .. \".\"")
                    end
                else
                    add_dialogue("\"A better time to buy would be when my shop is open.\"")
                end
                remove_answer("provisions")
            elseif answer == "commons" then
                add_dialogue("For an instant, you see indecisiveness in her expression, then she suddenly gives in, her words coming out in a torrent of information.")
                add_dialogue("\"I am afraid to speak, but knowing thou wouldst see through any facade, I can no longer silence the truth. My Lord, Sir Pendaran, has not been the same gentle soul since he joined the Fellowship.\"")
                add_dialogue("\"'Twas not too long ago that my Pendaran was a noble knight, one a lady could be proud of. But now,\" she shakes her head, \"in protest of a wrong he perceives in Britannia's government, he has defaced the statue of our beloved Lord British.\" She begins to sob.")
                add_dialogue("\"And, he has battled and wounded a fellow knight who chanced upon him during his hour of misdeed. He came to me,\" she tries to choke back her tears, \"with another's blood on his sword!\"")
                add_dialogue("After a few moments of your comforting, she regains her composure.")
                add_dialogue("\"Please do not be too harsh with him,\" she begs.")
                set_flag(605, true)
                remove_answer("commons")
                add_answer("another")
            elseif answer == "another" then
                add_dialogue("\"I know not who, \" .. var_0001 .. \", and Pendaran would not say!\"")
                remove_answer("another")
            elseif answer == "bye" then
                add_dialogue("\"May fortune follow thee, \" .. var_0001 .. \".\"")
                return
            end
        end
    elseif eventid == 0 then
        var_000A = get_schedule()
        var_0008 = unknown_001CH(get_npc_name(194))
        var_000B = random(4, 1)
        if var_0008 == 7 then
            if var_000B == 1 then
                var_000C = "@Provisions!@"
            elseif var_000B == 2 then
                var_000C = "@Buy in advance!@"
            elseif var_000B == 3 then
                var_000C = "@Best provisions in town!@"
            elseif var_000B == 4 then
                var_000C = "@Be equipped!@"
            end
        elseif var_0008 == 26 then
            if var_000B == 1 then
                var_000C = "@Wondrous fine food!@"
            elseif var_000B == 2 then
                var_000C = "@Fine drink!@"
            elseif var_000B == 3 then
                var_000C = "@Mmmmm...@"
            elseif var_000B == 4 then
                var_000C = "@I am full.@"
            end
        end
        bark(var_000C, 194)
    end
    return
end