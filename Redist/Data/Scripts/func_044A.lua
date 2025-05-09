--- Best guess: Manages Rudyom’s dialogue, a senile mage discussing his failing magic, blackrock experiments, and a lost flying carpet, with flag-based spell and reagent transactions.
function func_044A(eventid, itemref)
    local var_0000, var_0001

    if eventid == 0 then
        return
    end

    start_conversation()
    switch_talk_to(0, 74)
    add_answer({"bye", "job", "name"})
    if not get_flag(101) then
        add_answer({"Moongates", "blackrock"})
    end
    if not get_flag(231) then
        add_dialogue("This elderly mage looks older and more senile than when you last saw him.")
        set_flag(231, true)
    else
        if not get_flag(3) then
            add_dialogue("\"Who art thou?\" Rudyom asks. \"Oh -- I remember.\"")
        else
            add_dialogue("\"Hello again, Avatar!\" Rudyom says, beaming.")
        end
    end
    while true do
        if cmps("name") then
            add_dialogue("\"That I know. My name is Rudyom.\"")
            remove_answer("name")
        elseif cmps("job") then
            if not get_flag(3) then
                add_dialogue("\"I am not sure anymore. I was a powerful mage at one time! Now nothing works. Magic is afoul! I suppose I could sell thee some reagents and spells if thou dost want. And mind the carpet -- it does not work!\"")
                add_answer("carpet")
            else
                add_dialogue("\"I am a powerful mage! Magic is my milieu! I can sell thee spells or reagents.\"")
            end
            add_answer({"reagents", "spells", "magic"})
        elseif cmps("magic") then
            if not get_flag(3) then
                add_dialogue("\"I do not understand what is wrong. My magic does not work so well anymore.\"")
            else
                add_dialogue("\"The ether is flowing freely! Magic is with us once again!\"")
            end
            remove_answer("magic")
        elseif cmps("carpet") then
            add_dialogue("\"The big blue carpet. 'Tis a flying carpet. It does not work like it should.\"")
            add_dialogue("Rudyom looks around and scratches his head.")
            add_dialogue("\"Funny. It was here a while ago. Oh! I remember now. Some adventurers borrowed my flying carpet a few weeks ago. When they returned they said they had lost it near Serpent's Spine. Somewhere in the vicinity of the Lost River. I suppose if thou didst want to go and find it, thou couldst keep it. It did not work very well. Perhaps thou canst make it work. I did not like the color, anyway!\"")
            remove_answer("carpet")
        elseif cmps("spells") then
            add_dialogue("\"Dost thou wish to buy some spells?\"")
            var_0000 = unknown_090AH()
            if var_0000 then
                unknown_08DBH()
            else
                add_dialogue("\"Oh. Never mind, then.\"")
            end
        elseif cmps("reagents") then
            add_dialogue("\"Dost thou wish to buy some reagents?\"")
            var_0001 = unknown_090AH()
            if var_0001 then
                unknown_08DCH()
            else
                add_dialogue("\"Oh. Never mind, then.\"")
            end
        elseif cmps("blackrock") then
            add_dialogue("\"Do not mention that foul mineral's name to me! It hast caused me much frustration! Before my mind lost me I was conducting experiments with the infernal material. But now I cannot for the life of me remember what it was I was trying to do.\"")
            add_answer("experiments")
            remove_answer("blackrock")
        elseif cmps("Moongates") then
            if not get_flag(4) then
                add_dialogue("\"They are a nuisance, are they not? I do believe that blackrock is the solution to the problem. I wish my mind had not lost me, or I could continue my work...\"")
            else
                add_dialogue("\"I understand they are gone for good. Do not blame thyself, Avatar. The disaster will only pave the way for a new era in experimentation and discovery. I hope.\"")
            end
            remove_answer("Moongates")
        elseif cmps("experiments") then
            add_dialogue("\"I wrote them all down in my notebook, which is somewhere around here. Thou art welcome to look at it. But stay away from that damned transmuter -- 'tis dangerous!\"")
            add_answer({"notebook", "transmuter"})
            remove_answer("experiments")
        elseif cmps("notebook") then
            add_dialogue("\"I used it to record mine experiments with blackrock and the blackrock transmuter.\"")
            remove_answer("notebook")
        elseif cmps("transmuter") then
            add_dialogue("\"'Tis that wand-like thing. It was supposed to magnetize and magically transmute blackrock, but it doth not work correctly. Try pointing it at a piece of blackrock and thou wilt see what I mean. But do not stand too close! Thou art welcome to take it if thou dost want a piece of garbage!\"")
            unknown_0911H(50)
            remove_answer("transmuter")
        elseif cmps("bye") then
            if not get_flag(3) then
                add_dialogue("\"Leaving so soon? Deary me. I hope I remember thee if thou dost come back.\"")
            else
                add_dialogue("\"Goodbye, Avatar.\"")
            end
            break
        end
    end
    return
end