--- Best guess: Manages Wench's dialogue in Buccaneer's Den, a worker at The Baths offering various services and revealing secrets about the area.
function npc_wench_0221(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009

    if eventid == 0 then
        return
    end
    switch_talk_to(221)
    var_0000 = get_schedule(221)
    var_0001 = get_schedule_type(get_npc_name(221))
    var_0002 = get_player_name()
    var_0003 = "Avatar"
    var_0004 = is_pc_female()
    if not get_flag(668) then
        var_0005 = var_0002
    elseif not get_flag(672) then
        var_0005 = var_0003
    end
    if var_0001 ~= 7 then
        add_dialogue("The woman looks up in surprise and says, \"I am not working at the moment and I ask thee to respect my privacy. If thou dost wish to speak with me, come to The Baths in the late evening hours.\"")
        return
    end
    start_conversation()
    add_answer({"bye", "job", "name"})
    var_0006 = get_timer(2)
    var_0007 = get_timer(3)
    var_0008 = get_timer(4)
    if get_flag(668) and var_0006 <= 2 and get_flag(670) and var_0007 <= 2 and get_flag(669) and var_0008 <= 2 then
        add_dialogue("This attractive woman looks at you with surprise and says, \"A moment! Thou didst just enjoy thyself, didst thou not? Please come back when thou art rested.\"")
        return
    end
    if not get_flag(682) then
        add_dialogue("You see a gorgeous young woman with seductive eyes.")
        if not var_0004 then
            add_dialogue("\"Hello, handsome!")
        else
            add_dialogue("\"Hello. Art thou sure thou dost not really want to speak with Roberto?\"")
            if not ask_yes_no() then
                add_dialogue("\"Fine, sweetheart. Whatever makes thy blood boil...")
            else
                add_dialogue("\"Then thou hadst best speak with Roberto! He is probably more thy type.\"")
                return
            end
        end
        add_dialogue("Who art thou?")
        var_0009 = utility_unknown_1035({var_0003, var_0002})
        if var_0009 == var_0002 then
            if not var_0004 then
                add_dialogue("\"Well, I am very pleased to meet thee, \" .. var_0002 .. \".\"")
            else
                add_dialogue("\"Hello, \" .. var_0002 .. \".\"")
            end
            var_0005 = var_0002
            set_flag(668, true)
        elseif var_0009 == var_0003 then
            add_dialogue("\"Oh ho! A real live Avatar?\"")
            if not var_0004 then
                add_dialogue("\"Say, we should get to know one another better!\"")
            else
                add_dialogue("\"And female, as well! And I thought I had seen it all...\"")
            end
            var_0005 = var_0003
            set_flag(672, true)
        end
        set_flag(682, true)
    else
        add_dialogue("\"Hello again, \" .. var_0005 .. \",\" Wench says.")
    end
    while true do
        local answer = get_answer()
        if answer == "name" then
            add_dialogue("\"Thou canst just call me... Wench.\"")
            if not var_0004 then
                add_dialogue("She blows you a kiss.")
            end
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("She laughs aloud. \"Thou must be kidding!\" She composes herself and says, \"It is my duty to see that thou art comfortable whilst at The Baths.\"")
            add_answer({"comfortable", "The Baths"})
        elseif answer == "The Baths" then
            add_dialogue("\"I have been working here since it opened. I love it. I am not exploited in the least. I make piles of gold and live a great life.\"")
            if not var_0004 then
                add_dialogue("She winks at you. \"I meet many nice men, too!\"")
            end
            remove_answer("The Baths")
        elseif answer == "comfortable" then
            add_dialogue("\"Well, we could have a swim in the spring pools, or thou couldst have a massage. Or we could just talk.\"")
            add_dialogue("\"Or... thou couldst come with me into the Community Room and I'll 'show' thee my 'job'!\"")
            remove_answer("comfortable")
            add_answer({"Community Room", "talk", "massage", "swim"})
        elseif answer == "Community Room" then
            add_dialogue("\"Thou dost want to join me in the Community Room?\"")
            if ask_yes_no() then
                add_dialogue("Wench leads you into a private room.")
                add_dialogue("\"It really isn't a Community Room at all. We shall be all alone,\" she giggles.")
                add_dialogue("\"By the way, it is a good thing thou didst choose me. Roberto and Martine enjoy stealing gold from their customers. I may have questionable morals, but I am not a thief! Now, let us get down to business, shall we?\"")
                add_dialogue("A while later, after the woman has shown you more tricks than a mage on stage, you emerge from the Community Room a much happier Avatar.")
                set_flag(669, true)
                set_timer(4)
            else
                add_dialogue("\"'Tis not a problem, \" .. var_0005 .. \".\"")
            end
            remove_answer("Community Room")
        elseif answer == "swim" then
            add_dialogue("Wench helps you with your clothing and leads you into the warm spring water. It feels terrific, and you would prefer to go to sleep, but you know you have a quest to fulfill. After a while, Wench helps you out of the water and you dress.")
            remove_answer("swim")
        elseif answer == "massage" then
            add_dialogue("Wench helps you with your clothing and leads you to a comfortable table. You lie on your stomach and the woman expertly kneads and rubs your aching muscles, slowly sending you into a state of total relaxation. After a while, Wench helps you up and you dress.")
            remove_answer("massage")
        elseif answer == "talk" then
            add_dialogue("Wench shrugs. \"Fine with me! What shall we talk about? I know! Want to know a secret?\"")
            if ask_yes_no() then
                add_dialogue("\"Didst thou know that there are secret passages in the mountains connecting the buildings on Buccaneer's Den? 'Tis true! I am fairly sure the entrance is through the House of Games, and I do know that there is a way into The Baths from the passages!\"")
            else
                add_dialogue("Wench pouts. \"Well never mind, then!\"")
            end
            add_dialogue("You and Wench speak of a number of other subjects when you realize that you are spending too much time in the spa. There is a quest to fulfill!")
            remove_answer("talk")
        elseif answer == "bye" then
            add_dialogue("\"Oh, please come again soon, \" .. var_0005 .. \"!\"")
            if not var_0004 then
                add_dialogue("Wench blows you a kiss.")
            else
                add_dialogue("Wench waves goodbye.")
            end
            break
        end
    end
    return
end