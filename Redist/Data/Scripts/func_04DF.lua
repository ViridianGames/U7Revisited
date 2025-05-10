--- Best guess: Manages Martine’s dialogue in Buccaneer’s Den, a worker at The Baths offering various services and revealing secret passages.
function func_04DF(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A

    if eventid == 0 then
        return
    end
    switch_talk_to(0, 223)
    var_0000 = unknown_003BH()
    var_0001 = unknown_001CH(unknown_001BH(223))
    var_0002 = unknown_0908H()
    var_0003 = "Avatar"
    var_0004 = unknown_005AH()
    if not get_flag(666) then
        var_0005 = var_0002
    elseif not get_flag(667) then
        var_0005 = var_0003
    end
    if var_0001 ~= 7 then
        add_dialogue("The woman looks up in surprise and says, \"I am not working at the moment and I ask thee to respect my privacy. If thou dost wish to speak with me, come to The Baths in the late evening hours.\"")
        return
    end
    start_conversation()
    add_answer({"bye", "job", "name"})
    var_0006 = unknown_0065H(4)
    var_0007 = unknown_0065H(3)
    var_0008 = unknown_0065H(2)
    if get_flag(669) and var_0006 <= 2 and get_flag(670) and var_0007 <= 2 and get_flag(668) and var_0008 <= 2 then
        add_dialogue("This attractive woman looks at you with surprise and says, \"Honey, thou just enjoyed thyself, didst thou not? Please come back when thou art rested.\"")
        return
    end
    if not get_flag(684) then
        add_dialogue("You see a beautiful young woman with a tropical air.")
        if not var_0004 then
            add_dialogue("\"Hello, handsome!\"")
        else
            add_dialogue("\"Hello, dear. Art thou sure thou dost not want to speak with Roberto?\"")
            if not unknown_090AH() then
                add_dialogue("\"All right, honey. Whatever heats thy blood...\"")
            else
                add_dialogue("\"Then thou had best speak with him! He is probably more to thy liking.\"")
                return
            end
        end
        add_dialogue("\"What is thy name?\"")
        var_0009 = unknown_090BH({var_0003, var_0002})
        if var_0009 == var_0002 then
            if not var_0004 then
                add_dialogue("\"How art thou, \" .. var_0002 .. \"? I am so happy to meet thee!\"")
            else
                add_dialogue("\"Hello, \" .. var_0002 .. \".\"")
            end
            var_0005 = var_0002
            set_flag(666, true)
        elseif var_0009 == var_0003 then
            add_dialogue("\"Oh please! Not another Avatar!\"")
            if not var_0004 then
                add_dialogue("Martine takes a deep breath, then smiles.")
                add_dialogue("\"Well, honey, it does not matter who thou art. We shalt have a good time anyway.\"")
            end
            var_0005 = var_0003
            set_flag(667, true)
        end
        set_flag(684, true)
    else
        add_dialogue("\"Hello again, \" .. var_0005 .. \",\" Martine says.")
    end
    while true do
        local answer = get_answer()
        if answer == "name" then
            add_dialogue("\"The name I use here is Martine. Thou dost understand...\" She winks at you.")
            remove_answer("name")
        elseif answer == "job" then
            if not var_0004 then
                add_dialogue("\"Honey, my job is to make thee happy.\"")
            else
                add_dialogue("\"My dear, my job is to serve thee.\"")
            end
            add_dialogue("\"'Tis important that thou art comfortable whilst visiting The Baths.\"")
            add_answer({"comfortable", "The Baths"})
        elseif answer == "The Baths" then
            add_dialogue("\"'Tis a fabulous place to work. I absolutely love it. I would not work anywhere else. I have more gold than I could possibly spend.\"")
            if not var_0004 then
                add_dialogue("Martine blows a kiss at you. \"I meet many kinds of interesting people, too!\"")
            end
            remove_answer("The Baths")
        elseif answer == "comfortable" then
            add_dialogue("\"Thou dost have many choices. We could take a swim in our spring pools. Or I could perform a massage on thee. Or we could simply talk.\"")
            add_dialogue("\"But if thou dost want to really get to know me better, we should visit the Community Room...\"")
            remove_answer("comfortable")
            add_answer({"Community Room", "talk", "massage", "swim"})
        elseif answer == "Community Room" then
            add_dialogue("\"Thou dost want to join me in the Community Room?\"")
            if unknown_090AH() then
                add_dialogue("Martine leads you into a private room.")
                add_dialogue("\"It really is not a Community Room at all. We shall be all alone!\"")
                add_dialogue("A while later, after the woman has shown you more tricks than a crooked street mage, you emerge from the Community Room a much happier Avatar.")
                set_flag(668, true)
                unknown_0066H(2)
                var_000A = unknown_002BH(true, 359, 359, 644, 50)
            else
                add_dialogue("\"That's all right, honey.\"")
            end
            remove_answer("Community Room")
        elseif answer == "swim" then
            add_dialogue("Martine helps you with your clothing and leads you into the warm spring water. It feels fabulous, and you would love to go to sleep; but you know you have a quest to finish. After a while, Martine helps you out of the water and you dress.")
            remove_answer("swim")
        elseif answer == "massage" then
            add_dialogue("Martine helps you with your clothing and leads you to a comfortable table. You lie on your stomach and the woman expertly kneads and rubs your aching muscles, slowly sending you into a state of oblivion. After a while, Martine helps you up and you dress.")
            remove_answer("massage")
        elseif answer == "talk" then
            add_dialogue("Martine smiles. \"That is just fine with me, honey. I would wager thou hast many stories to tell about adventuring, yes? Say! Hast thou been in the secret passages in the mountains? Didst thou know they are all connected? I know that there is a secret door that leads right into the back of this building!\" She whispers, \"I believe the entrance is through the House of Games.\"")
            add_dialogue("You and Martine speak of a number of other subjects until you realize you have spent too much time in the spa. There is a quest to finish!")
            remove_answer("talk")
        elseif answer == "bye" then
            add_dialogue("\"I hope to see thee again soon, honey!\"")
            if not var_0004 then
                add_dialogue("Martine blows you a kiss.")
            else
                add_dialogue("Martine waves goodbye.")
            end
            break
        end
    end
    return
end