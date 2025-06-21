--- Best guess: Handles dialogue with Karl, a reclusive mountain man near Minoc, discussing his disdain for Minoc, the Fellowship, Owen’s monument, the murders, and his brother’s death due to Owen’s faulty ship designs, offering Owen’s stolen plans to investigate with Julia.
function func_0459(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    start_conversation()
    if eventid == 0 then
        abort()
    end
    switch_talk_to(89, 0)
    var_0000 = get_lord_or_lady()
    var_0002 = is_player_wearing_fellowship_medallion() --- Guess: Checks Fellowship membership
    var_0001 = false
    if not get_flag(276) then
        add_dialogue("You see a mountain man who appears to have been in the wilderness a long time. He gives you a long look, then he snorts and looks away.")
        set_flag(276, true)
    else
        add_dialogue("\"What dost thou want? Leave me alone!\"")
    end
    add_answer({"bye", "job", "name"})
    if not get_flag(248) and get_flag(276) then
        add_answer({"brother"})
        var_0001 = true
    end
    while true do
        var_0003 = get_answer()
        if var_0003 == "name" then
            add_dialogue("\"I am not in the habit of speakin' to strangers but seein' as how thou dost not appear to be very intelligent, I shall humor thee for now. My name is Karl, formerly of Minoc.\"")
            set_flag(292, true)
            if not get_flag(248) and not var_0001 then
                add_answer({"brother"})
            end
            remove_answer("name")
            add_answer("Minoc")
        elseif var_0003 == "job" then
            add_dialogue("\"Job?! Art thou mad, " .. var_0000 .. "?! Firstly, if thou dost wish to offer me employment I have no interest in it. Secondly, if thou dost wish to hire my services for anything for any reason, then I reject thine offer most enthusiastically. Thirdly, if thou dost wonder what my job is, then wonder no more for I have not one. Fourth and lastly, if thou dost wonder why I have no job then stop it right now because it is none of thy business!\"")
            abort()
        elseif var_0003 == "Minoc" then
            add_dialogue("\"Do not ask me of Minoc, the filthy little town of Fellowship fools, casual murders and monuments to incompetence. I do not even live here and I would not if thou didst pay me!\"")
            remove_answer("Minoc")
            add_answer({"Fellowship", "monument", "murders"})
        elseif var_0003 == "murders" then
            add_dialogue("\"Hmmph. Why should that be any concern of mine? People kill each other every day. Oh, thou art investigating the crime! Well, do not let me keep thee from it. After thou dost catch the murderer thou canst build a statue of him.\"")
            remove_answer("murders")
        elseif var_0003 == "Fellowship" then
            if var_0002 then
                add_dialogue("\"Gads! Thou dost want me to join! Away from me, thou dolt!\"")
            else
                add_dialogue("\"Do I look like a member of The Fellowship to thee? I do not even know what The Fellowship is! And I do not care!\"")
            end
            abort()
        elseif var_0003 == "monument" then
            add_dialogue("\"Owen, the shipwright, dost deserve to have a monument built to him. It should be in the shape of a gallows and it should have him hanging from it.\"")
            abort()
        elseif var_0003 == "brother" then
            add_dialogue("\"My brother - mine only family in the world - served aboard a ship built by Owen. The ship was one of several that sank three years ago during the first storm it ever encountered. My brother went down with it and was never seen again.\"")
            remove_answer("brother")
            add_answer({"several ships", "Owen"})
        elseif var_0003 == "Owen" then
            add_dialogue("\"I confronted Owen with this and he denied that it had anything to do with his workmanship. I returned that night and stole the plans he had drafted, so at least no other ships would ever be built like them again. But it left me so angry at the world that I knew I could not live among people ever again. I went away to live up in the mountains. The only times I ever come back are to fetch a few supplies and maybe have a drink of Rutherford's fine ale once in a while.\"")
            remove_answer("Owen")
            add_answer({"fine ale", "plans"})
        elseif var_0003 == "several ships" then
            add_dialogue("\"Three other ships that were built from Owen's basic designs all sunk within the first year of their launch. Over a dozen lives were lost due to that vainglorious bastard!\"")
            remove_answer("several ships")
        elseif var_0003 == "fine ale" then
            add_dialogue("\"If not for Rutherford's fine ale, there would no purpose to the existence of civilization.\"")
            remove_answer("fine ale")
        elseif var_0003 == "plans" then
            add_dialogue("\"I still have those plans up in my cabin. Every once in a while I try to figure them out. I suspect no one in town, save for Owen himself, could understand them. Maybe Julia, the tinker, would be able to shed some light on them. But she would never listen to an old mountain man like me.\"")
            var_0003 = npc_id_in_party(8) --- Guess: Checks player status
            if var_0003 then
                switch_talk_to(8, 0)
                add_dialogue("\"Yes I would, Karl! Thou dost have too low opinion of thyself! Raise thy spirits, please!\"")
                hide_npc(8)
                switch_talk_to(89, 0)
            end
            set_flag(267, true)
            remove_answer("plans")
            add_answer({"mountain man", "Julia"})
        elseif var_0003 == "mountain man" then
            add_dialogue("\"Far away from the mire of present day society is where I belong. In the wilderness thou canst know what is what.\"")
            remove_answer("mountain man")
        elseif var_0003 == "Julia" then
            add_dialogue("\"If thou dost want to show Julia the plans, I will give them to thee. They are in my cabin southeast of the BMC office.\"")
            set_flag(288, true)
            remove_answer("Julia")
        elseif var_0003 == "follow" then
            add_dialogue("\"Make up thy mind! Art thou following me or not?! If thou art following me then close thy mouth, move thy feet and let us get on.\"")
            abort()
        elseif var_0003 == "bye" then
            break
        end
    end
    if get_flag(247) then
        add_dialogue("\"I know I can be a bear to get along with sometimes. I reckon it is just my nature to be an ornery bastard. But I do appreciate what few friends I have and I know that thou hast been one to me. Take good care of thyself, Avatar.\"")
    else
        add_dialogue("\"Cease thy racket then before I lose my temper!\"")
    end
end