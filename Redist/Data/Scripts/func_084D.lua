--- Best guess: Manages a dialogue sequence for joining The Fellowship, handling quest failure, membership offer, and examination prompts.
function func_084D()
    local var_0000, var_0001, var_0002

    var_0000 = get_schedule()
    if get_flag(150) and get_flag(151) then
        add_dialogue("\"Well, thou didst certainly attempt to complete the quest. I cannot understand why the chest in Destard was empty. But we shall forget it, shall we?\"")
        add_dialogue("\"Now that thou hast worked a little for The Fellowship, and hast learned what we stand for, dost thou still wish to join?\"")
        var_0001 = unknown_090AH()
        if var_0001 then
            set_flag(141, true)
            add_dialogue("\"Then thou art most welcome to The Fellowship. ")
            if var_0000 ~= 7 then
                add_dialogue("\"Thou wilt officially be inducted during our nightly meeting this evening. Please come, and thou shalt receive thy medallion then. Once again, we thank thee, Avatar.\"")
                abort()
            else
                add_dialogue("\"The Ceremony shall begin.\"")
                unknown_084FH()
            end
            remove_answer("join")
        else
            add_dialogue("\"I can see that thou art not yet ready to take such a courageous step in thy thinking and in thy life. But do remember what we spoke of today, my friend! Perhaps in time thou wilt become ready.\"")
            abort()
        end
    else
        add_dialogue("\"Ah, but first things first. I recommend that thou takest our Examination to determine if thou art truly in need of The Fellowship's teachings. Dost thou want to take the test?\"")
        var_0002 = unknown_090AH()
        if var_0002 then
            save_answers()
            unknown_084EH()
            restore_answers()
        else
            add_dialogue("\"Perhaps another time, then.\"")
            abort()
        end
    end
end