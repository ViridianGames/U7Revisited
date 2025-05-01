-- Handles Fellowship quest dialogue, managing membership and test prompts.
function func_084D()
    local local0, local1, local2

    local0 = external_003BH() -- Unmapped intrinsic
    if get_flag(150) and get_flag(151) then
        add_dialogue("\"Well, thou didst certainly attempt to complete the quest. I cannot understand why the chest in Destard was empty. But we shall forget it, shall we?\"")
        add_dialogue("\"Now that thou hast worked a little for The Fellowship, and hast learned what we stand for, dost thou still wish to join?\"")
        local1 = external_090AH() -- Unmapped intrinsic
        if not local1 then
            set_flag(141, true)
            add_dialogue("\"Then thou art most welcome to The Fellowship. \"")
            if local0 ~= 7 then
                add_dialogue("\"Thou wilt officially be inducted during our nightly meeting this evening. Please come, and thou shalt receive thy medallion then. Once again, we thank thee, Avatar.\"*")
                abort()
            else
                add_dialogue("\"The Ceremony shall begin.\"")
                external_084FH() -- Unmapped intrinsic
            end
            remove_answer("join") -- Unmapped intrinsic
        else
            add_dialogue("\"I can see that thou art not yet ready to take such a courageous step in thy thinking and in thy life. But do remember what we spoke of today, my friend! Perhaps in time thou wilt become ready.\"*")
            abort()
        end
    else
        add_dialogue("\"Ah, but first things first. I recommend that thou takest our Examination to determine if thou art truly in need of The Fellowship's teachings. Dost thou want to take the test?\"")
        local2 = external_090AH() -- Unmapped intrinsic
        if not local2 then
            save_answers() -- Unmapped intrinsic
            external_084EH() -- Unmapped intrinsic
            restore_answers() -- Unmapped intrinsic
        else
            add_dialogue("\"Perhaps another time, then.\"*")
            abort()
        end
    end
    return
end