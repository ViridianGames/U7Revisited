--- Best guess: Manages Gorn’s dialogue, a warrior from Balema in a cave searching for Brom, guided by a voice in his head, with flag-based interactions involving Iriale and Fellowship-like philosophy, potentially ending in distrust.
function func_048A(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006

    if eventid == 0 then
        return
    end

    start_conversation()
    switch_talk_to(0, 138)
    var_0000 = unknown_0908H()
    var_0001 = get_lord_or_lady()
    var_0002 = unknown_08F7H(-1)
    var_0003 = unknown_08F7H(-3)
    var_0004 = unknown_08F7H(-4)
    var_0005 = unknown_0067H()
    if not get_flag(715) then
        add_answer("Iriale")
    end
    if not get_flag(699) then
        add_dialogue("You see a familiar face, a stern-looking bearded warrior whom you have met on one of your previous journeys to Britannia.")
        set_flag(699, true)
    else
        add_dialogue("\"Ho, Avatar!\" says Gorn. \"Thou dost vish to speak mit me?\"")
    end
    if get_flag(722) then
        add_dialogue("\"De voice ov Brom has told me not to trust thee, Avatar,\" says Gorn. \"I tought dat ve vere friends and I do not vish to cause thee harm. But I varn thee, do not speak mit me anymore!\"")
        return
    end
    add_answer({"bye", "job", "name"})
    while true do
        if cmps("name") then
            add_dialogue("The warrior's eyes narrow. \"I am Gorn, as if thou didst not remember! It is good to see thee again.\" He laughs and slaps you on the shoulder.")
            remove_answer("name")
        elseif cmps("job") then
            add_dialogue("\"My job is a never-ending qvest of high adventure. Ever since I vas a child und vas taken from mine homeland of Balema, I haf spent my life in search of heroic deeds to perform.\"")
            add_answer({"heroic deeds", "Balema"})
        elseif cmps("Balema") then
            add_dialogue("\"Yah, Balema is vere I vas born. I vas a child dere. It is a vonderland ov snow-covered mountains und dark forests. It vas not an easy life, but it vas a place dat made young boys into strong heroic men. Dat vas long before I came to Britannia.\"")
            remove_answer("Balema")
            add_answer("Britannia")
        elseif cmps("Britannia") then
            add_dialogue("\"Yah! I came to Britannia t'rough vone ov de Moongates, de same as thee. Dat vas many, many years ago.\"")
            remove_answer("Britannia")
        elseif cmps("heroic deeds") then
            add_dialogue("\"I perform heroic deeds in honor ov Brom. Everyting I do is in service to him.\"")
            remove_answer("heroic deeds")
            add_answer("Brom")
        elseif cmps("Brom") then
            add_dialogue("\"He is my master, und de master ov all ov de people ov Balema. Brom is all powerful und if I am strong he vill aid me. Sometimes I hear de voice ov Brom inside ov mine head.\"")
            remove_answer("Brom")
            add_answer({"voice", "master"})
        elseif cmps("master") then
            add_dialogue("\"Ya! Brom he is my master. If he vishes me to do someting, I must do it! If he does not vant me to do someting, I must not do it!\"")
            remove_answer("master")
        elseif cmps("voice") then
            add_dialogue("\"Ya! Only recently I haf begun to hear his voice in mine head. His voice tells me vat to do! As I came tovard dis cave de voice ov Brom became clearer.\"")
            remove_answer("voice")
            add_answer({"clearer", "cave", "what to do"})
        elseif cmps("what to do") then
            add_dialogue("\"Vhen I first heard de voice ov Brom, he told me dat I should follow him. But how does one follow de voice ov someone dat thou cannot see vhen de voice is coming from inside ov thine head?\"")
            remove_answer("what to do")
            add_answer("follow")
        elseif cmps("follow") then
            add_dialogue("\"Dis vas very, very difficult for me but after a vhile I vas able to figure out how to do it. Vhen I came nearer to da camp surrounding dis cave da voice vould get louder. Vhen I vould move avay de voice vould be qvieter.\"")
            remove_answer("follow")
            add_answer("camp")
        elseif cmps("camp") then
            add_dialogue("\"It vas very simple for a trained varrior like myself to slip into de camp ov dose who are holding Brom prisoner. Dey posed no threat vatsoever. So dat means dat de danger must be vaiting down here. But I cannot find it!\"")
            if var_0005 then
                add_dialogue("\"I can see by dat medallion thou dost vear dat thou hast snuck into dis place by disguising thyself as vone of dem. Very clever, Avatar!\"")
            end
            if var_0002 then
                switch_talk_to(0, -1)
                add_dialogue("Iolo whispers to you, \"This fellow is quite sharp, is he not?\"")
                hide_npc1)
                switch_talk_to(0, 138)
            end
            remove_answer("camp")
            add_answer("danger")
        elseif cmps("danger") then
            add_dialogue("\"Zo far de only danger I haf found down here has been a female fighter. She vas beautiful. Vhen I vent to talk to her she hit me over de head mit her svord. Vhen I voke up she vas gone. I bet she tought she had killed me but mine head is harder dan dat. I vas not even vounded.\"")
            if var_0003 then
                switch_talk_to(0, -3)
                add_dialogue("Shamino whispers to you. \"Luckily, Gorn was hit in the one spot where he has no feeling whatsoever -- his head!\"")
                switch_talk_to(0, 138)
                add_dialogue("\"Hey, vhat are you vhispering about over dere?\"")
                switch_talk_to(0, -3)
                add_dialogue("\"Oh, nothing. Nothing at all.\"")
                hide_npc3)
                switch_talk_to(0, 138)
            end
            remove_answer("danger")
        elseif cmps("cave") then
            add_dialogue("\"I know dat Brom is somevhere down in dis cave, und I vill not leave dis place until I find him!\"")
            remove_answer("cave")
            add_answer("find Brom")
        elseif cmps("clearer") then
            add_dialogue("\"The nearer I haf come to dis cave, the more times I haf been hearing de voice ov Brom. But lately he has been saying tings to me dat are very, very strange!\"")
            remove_answer("clearer")
            add_answer("strange")
        elseif cmps("strange") then
            add_dialogue("\"De first strange ting dat he says to me is \"Strive For Unity\". I say, yah, dat is vhy I am performing mine heroic deeds. Den Brom says someting else dat is strange.\"")
            remove_answer("strange")
            add_answer("something else strange")
        elseif cmps("something else strange") then
            add_dialogue("\"Next de voice ov Brom says to me \"Trust My Brothers\". Dis is strange because all ov my brothers are back in Balema, und I vould never trust dem anyvays. Dey vere all bigger den me and vere alvays beating me. But even dat vas not as strange as da next strange ting.\"")
            remove_answer("something else strange")
            add_answer("next strange thing")
        elseif cmps("next strange thing") then
            add_dialogue("\"De voice ov Brom tells me dat \"Worldliness Receives Avard\". I haf been tinking about dat von for a long time und I still haf not figured it out. But I vill not give up until I find Brom.\"")
            if var_0004 then
                switch_talk_to(0, -4)
                add_dialogue("\"A mysterious voice speaking inside someone's head, suggesting the philosophy of The Fellowship. Does this sound familiar, " .. var_0000 .. "?\"")
                hide_npc4)
                switch_talk_to(0, 138)
            end
            remove_answer("next strange thing")
            add_answer("find Brom")
        elseif cmps("find Brom") then
            add_dialogue("\"Wouldst thou help me find Brom?\"")
            var_0006 = unknown_090AH()
            if var_0006 then
                add_dialogue("Gorn seems distracted for a moment. He places his hand to his ear as if he is listening to something. He looks back at you and there is a shocked look on his face. \"I haf just heard de voice ov Brom and he has told me not to trust thee! Go avay from me, Avatar! I tought dat thou vert my friend! I do not vish to speak vith thee anymore!\"")
                set_flag(722, true)
                return
            else
                add_dialogue("Gorn has a confused look on his face. \"Vhy vill thou not help me find Brom? Dost thou tink dat dis is all some kind ov trick, or should I go on looking for Brom by myself?\"")
                add_answer({"it's a trick", "look for Brom"})
            end
            remove_answer("find Brom")
        elseif cmps("look for Brom") then
            add_dialogue("\"If dat is how thou vants it. Den I shall go on searching for Brom mit no vone else but myself. Good luck in vhatever qvest thou art on, Avatar. Farewell to thee!\"")
            unknown_001DH(unknown_001BH(138), 12)
            return
        elseif cmps("it's a trick") then
            add_dialogue("Gorn seems distracted for a moment. He puts his hand to his ear as if he is listening to something. He looks back at you with a shocked expression on his face. \"I haf just heard de voice ov Brom and he says dat I should not trust thee! I tought dat thou vert my friend, Avatar! Go avay! I do not vish to speak vith thee again!\"")
            set_flag(722, true)
            return
        elseif cmps("Iriale") then
            add_dialogue("\"Dat is de name ov de female fighter who has been guarding dis place. I haf fought her vonce already. She is a strong fighter! I haf to find her so I can make her to tell me vhere is Brom!\"")
            remove_answer("Iriale")
        elseif cmps("bye") then
            break
        end
    end
    add_dialogue("\"Until ve meet again, Avatar.\"")
end