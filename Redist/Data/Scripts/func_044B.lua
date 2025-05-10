--- Best guess: Manages Nastassia’s dialogue, a woman tending the Shrine of Compassion, discussing her family history, her parents’ tragic past, and a romantic subplot with the Avatar, with flag-based progression and gender-specific interactions.
function func_044B(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    if eventid == 0 then
        return
    end
    if eventid == 1 then
        local arr = {7969, 1099, 17493, 7937, 1, 26, 17492, 7715}
        var_0000 = unknown_0001H(arr, itemref)
    end

    start_conversation()
    switch_talk_to(0, 75)
    var_0001 = false
    var_0002 = false
    var_0003 = false
    var_0004 = is_player_female()
    var_0005 = unknown_0908H()
    add_answer({"bye", "job", "name"})
    if not get_flag(224) and not get_flag(226) then
        add_answer({"Yew", "Nadia", "Julius", "Ariana"})
    end
    if get_flag(297) then
        add_answer("News of your father")
    end
    if not var_0004 and not get_flag(230) then
        add_answer("kiss")
    end
    if not get_flag(232) then
        if var_0004 then
            add_dialogue("This is an attractive young woman who seems sad.")
        else
            add_dialogue("Emotion immediately grips your heart to see such a beautiful young woman seem so sad.")
            add_dialogue("She looks up as you introduce yourself.")
        end
        set_flag(232, true)
    else
        add_dialogue("\"Hello again, " .. var_0005 .. "!\" Nastassia says.")
    end
    while true do
        if cmps("name") then
            add_dialogue("\"I am Nastassia.\"")
            remove_answer("name")
        elseif cmps("job") then
            add_dialogue("She thinks a moment. \"I suppose my job is to keep the Shrine of Compassion pristine, though it is not an official position.\"")
            add_answer("Shrine")
        elseif cmps("Shrine") then
            add_dialogue("\"The Shrine of Compassion has been here for many generations, as have all the shrines in Britannia. My great-great-grandmother Ariana made a request in her will that her family line take care of this particular shrine.\"")
            add_answer({"take care", "all shrines"})
            remove_answer("Shrine")
        elseif cmps("all shrines") then
            add_dialogue("\"Many of the shrines have fallen into disuse or have been overgrown to the point of being lost. It is sad.\"")
            remove_answer("all shrines")
        elseif cmps("take care") then
            add_dialogue("\"I am afraid that thou mightest find the other shrines in poor condition. I keep this one... well, nice. And I do it not only to keep alive my great-great-grandmother's tradition, but... for other reasons, too.\"")
            remove_answer("take care")
            add_answer({"reasons", "tradition"})
        elseif cmps("tradition") then
            add_dialogue("\"Some people may think it odd that a young person would cling to the old ways so. But it is something that gives me great comfort. It gives me the feeling that there is something in this world that I belong to.\"")
            remove_answer("tradition")
        elseif cmps("reasons") then
            if not get_flag(224) then
                add_dialogue("\"I... I'd rather not say. Please do not ask.\"")
            else
                add_dialogue("\"Thou dost know the reasons.\"")
            end
            remove_answer("reasons")
        elseif cmps("Ariana") then
            if var_0004 then
                var_0006 = "she"
            else
                var_0006 = "he"
            end
            add_dialogue("\"Yes, she was my great-great-grandmother. I understand that she actually met the Avatar and " .. var_0006 .. " made a profound impact on her life.~~\"It is odd, but thou dost resemble the portraits I have seen of the Avatar.\"")
            remove_answer("Ariana")
            add_answer("I am the Avatar")
        elseif cmps("Julius") then
            add_dialogue("\"Thou dost know of my father? I suppose the townsfolk have been talking again. I wish I had known him. There is something within me that yearns for some news of him. Anything at all.\"")
            remove_answer("Julius")
            set_flag(225, true)
        elseif cmps("Nadia") then
            add_dialogue("\"My mother. She died horribly, and by her own hand. That is the true reason I pay homage to this Shrine. I hope someday to provide her with the means to rest in peace.\"")
            remove_answer("Nadia")
        elseif cmps("Yew") then
            add_dialogue("\"My father died in the Great Forest there. Some wild animal or something killed him. Art thou perhaps travelling to Yew?\"")
            var_0007 = unknown_090AH()
            if var_0007 then
                add_dialogue("\"Oh, " .. var_0005 .. ", I do wish thou wouldst try to find out something about my father. How did he die? What happened? Please! Wilt thou search for the truth and come back and tell me?\"")
                var_0008 = unknown_090AH()
                if var_0008 then
                    add_dialogue("\"Bless thee! I shall be waiting here for thee.\"")
                    if var_0004 then
                        add_dialogue("\"I know we have a strong kinship now. We shall be like sisters.\"")
                    else
                        add_dialogue("Unexpectedly, Nastassia pulls your head down to hers and kisses you on the mouth.")
                        add_answer("kiss")
                    end
                    set_flag(226, true)
                else
                    add_dialogue("Nastassia turns away and looks as if she might cry. \"Very well. Please leave me alone.\"")
                    var_0000 = unknown_0001H({0, 26, 17492, 7715}, itemref)
                    return
                end
            else
                add_dialogue("\"No? Well, let me know if thou art in the future. Perhaps thou couldst help me.\"")
            end
            remove_answer("Yew")
        elseif cmps("kiss") then
            if get_flag(230) and var_0003 then
                add_dialogue("You kiss Nastassia and she moans.")
            elseif get_flag(230) and not var_0003 then
                add_dialogue("The two of you rush into each other's arms and your mouths meet. You had forgotten how good her lips felt against yours.")
                var_0003 = true
            elseif not get_flag(230) and not var_0001 then
                add_dialogue("You kiss Nastassia's lovely mouth again. She responds.~~\"No man hath done that as well as thee.\"~~ She looks at you with wide eyes.~~\"Do it again, milord.\"")
                var_0001 = true
                remove_answer("kiss")
                add_answer("kiss again")
            end
        elseif cmps("kiss again") then
            if not var_0002 then
                add_dialogue("You kiss Nastassia yet again. This time your bodies press together tightly, and you know this promises to be more than a fleeting fling with some tavern wench.")
                var_0002 = true
                set_flag(230, true)
            else
                add_dialogue("You kiss Nastassia and she moans.")
            end
        elseif cmps("I am the Avatar") then
            add_dialogue("Nastassia studies your features.~~\"Somehow I knew it. It hath been said that thou wouldst return.\"")
            remove_answer("I am the Avatar")
        elseif cmps("News of your father") then
            add_dialogue("You tell Nastassia what you learned from Trellek. She closes her eyes and it seems a great weight has lifted from her shoulders.~~The woman raises her arms to the sky and cries out, \"Didst thou hear that, mother? Thine husband was only trying to provide for his family! And he died... a hero! He was not a vagabond! Dost thou hear? Thou canst rest thy tortured soul now. Please, mother, forgive him. Do so, so that I can now forgive thee.\"~~She wipes the tears from her face and looks at you.")
            if var_0004 then
                add_dialogue("\"I thank thee, " .. var_0005 .. ". Thou hast made me very happy. I shall always remember thee.\"")
            else
                add_dialogue("She kisses you once lightly. \"Thank thee, " .. var_0005 .. ". Thou hast made me very happy. Shouldst thou become weary of adventuring, I shall be waiting here for thee. Thou art welcome to live and share thy life with me. Go now. Finish the job thou must needs do. But keep me in thy thoughts.\"")
            end
            unknown_0911H(50)
            remove_answer("News of your father")
        elseif cmps("bye") then
            if not var_0004 then
                if var_0002 then
                    add_dialogue("\"Goodbye.\" She kisses you again, and then turns so that she will not see you leave.")
                else
                    add_dialogue("\"Goodbye, " .. var_0005 .. ".\"")
                end
            else
                add_dialogue("\"Goodbye, " .. var_0005 .. ".\"")
            end
            var_0000 = unknown_0001H({0, 26, 17492, 7715}, itemref)
            break
        end
    end
    return
end