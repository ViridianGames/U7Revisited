--- Best guess: Manages Roberto's dialogue in Buccaneer's Den, a worker at The Baths offering services and revealing secret passages, with gender-specific interactions.
function npc_roberto_0224(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B

    if eventid == 0 then
        return
    end
    switch_talk_to(224)
    var_0000 = get_schedule()
    var_0001 = get_schedule_type(get_npc_name(224))
    var_0002 = get_player_name()
    var_0003 = "Avatar"
    var_0004 = is_pc_female()
    if not get_flag(673) then
        var_0005 = var_0002
    elseif not get_flag(674) then
        var_0005 = var_0003
    end
    if var_0001 ~= 7 then
        add_dialogue("The man looks up in surprise and says, \"I am not working at the moment and I ask thee to respect my privacy. If thou dost wish to speak with me, come to The Baths in the late evening hours.\"")
        return
    end
    start_conversation()
    add_answer({"bye", "job", "name"})
    var_0006 = get_timer(4)
    var_0007 = get_timer(2)
    var_0008 = get_timer(3)
    if get_flag(668) and var_0007 <= 2 and get_flag(669) and var_0006 <= 2 and get_flag(670) and var_0008 <= 2 then
        add_dialogue("The man looks at you with surprise and says, \"Hold, \" .. var_0004 .. \"! Thou didst just enjoy thyself, didst thou not? Please come back when thou art rested!\"")
        return
    end
    if not get_flag(685) then
        add_dialogue("You see a strikingly handsome man with eyes that pierce your soul.")
        if var_0004 then
            add_dialogue("\"Hello, gorgeous!\"")
        else
            add_dialogue("\"Hello. Uhm, art thou sure thou dost not really want to speak with Wench or Martine?\"")
            if not ask_yes_no() then
                add_dialogue("\"Fine, sailor, whatever makes thy blood boil...\"")
            else
                add_dialogue("\"Then thou hadst best speak with one of them. They are probably more to thy liking!\"")
                return
            end
        end
        add_dialogue("\"What is thy name?\"")
        var_0009 = utility_unknown_1035({var_0003, var_0002})
        if var_0009 == var_0002 then
            if var_0004 then
                add_dialogue("\"Well, I am very pleased to meet thee, \" .. var_0002 .. \".\"")
            else
                add_dialogue("\"Hello, \" .. var_0002 .. \".\"")
            end
            var_0005 = var_0002
            set_flag(673, true)
        elseif var_0009 == var_0003 then
            add_dialogue("Roberto does a double-take. \"The Avatar, eh? And I thought I had heard it all...\"")
            var_0005 = var_0003
            set_flag(674, true)
        end
        set_flag(685, true)
    else
        add_dialogue("\"Hello again, \" .. var_0005 .. \",\" Roberto says.")
    end
    while true do
        local answer = get_answer()
        if answer == "name" then
            add_dialogue("\"I am known in these parts as Roberto.\"")
            if var_0004 then
                add_dialogue("Roberto takes your hand and says, \"And thou art the most beautiful woman I have ever laid eyes upon!\"")
            end
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("Roberto smiles broadly. \"Thou dost not really want to know that, dost thou?\" He shakes his head, suppressing a laugh. \"Very well -- it is my task to see that thou art truly comfortable whilst at The Baths.\"")
            add_answer({"comfortable", "The Baths"})
        elseif answer == "The Baths" then
            if var_0004 then
                var_000A = "beautiful women"
            else
                var_000A = "handsome men"
            end
            add_dialogue("\"Nice place, is it not? I certainly enjoy working here! It brings me much wealth, and I have many opportunities to meet \" .. var_000A .. \" such as thyself!\"")
            remove_answer("The Baths")
        elseif answer == "comfortable" then
            add_dialogue("\"What would suit thee? We could swim in the spring pools, or I could give thee a massage. If thou dost prefer to converse, we could simply talk. Or if thou wouldst like, we could wander into the Community Room and... communicate!\"")
            remove_answer("comfortable")
            add_answer({"Community Room", "talk", "massage", "swim"})
        elseif answer == "Community Room" then
            add_dialogue("\"Thou dost want to join me in the Community Room?\"")
            if ask_yes_no() then
                add_dialogue("Roberto leads you into a private room.")
                add_dialogue("\"It really isn't a Community Room at all. We shall be all alone!\"")
                add_dialogue("A while later, after you have received the man's full attention, you emerge from the Community Room a much happier Avatar.")
                set_flag(670, true)
                set_timer(3)
                var_000B = remove_party_items(true, 359, 359, 644, 50)
            else
                add_dialogue("\"Do not worry about it, \" .. var_0005 .. \". We can do something else.\"")
            end
            remove_answer("Community Room")
        elseif answer == "swim" then
            add_dialogue("Roberto helps you with your clothing and leads you into the warm spring water. It feels terrific, and you feel like going to sleep, but you know you have a quest to complete. After a while, Roberto helps you out of the water and you dress.")
            remove_answer("swim")
        elseif answer == "massage" then
            add_dialogue("Roberto helps you with your clothing and leads you to a comfortable table. You lie face down and the man expertly kneads and rubs your aching muscles, slowly sending you over the edge into a state of total relaxation. After a while, Roberto helps you up and you dress.")
            remove_answer("massage")
        elseif answer == "talk" then
            add_dialogue("Roberto smiles. \"That is all right. What shall we talk about? Adventuring? Secret passages and dungeons?\"")
            add_dialogue("Roberto leans closer and whispers, \"Didst thou know that there are secret passages connecting the buildings on Buccaneer's Den? 'Tis true! I am fairly sure the entrance is through the House of Games, and I am quite sure there is a way into The Baths.\"")
            add_dialogue("You and Roberto speak of a number of other subjects until you realize that you are spending far too much time in the spa. There is a quest to fulfill!")
            remove_answer("talk")
        elseif answer == "bye" then
            add_dialogue("\"I hope to see thee again, \" .. var_0005 .. \".\"")
            break
        end
    end
    return
end