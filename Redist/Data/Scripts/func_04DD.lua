-- Function 04DD: Wench's hostess dialogue and secret passage hint
function func_04DD(eventid, itemref)
    -- Local variables (10 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9

    if eventid == 0 then
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(221, 0)
    local0 = callis_003B()
    local1 = callis_001C(callis_001B(-221))
    local2 = call_0908H()
    local3 = "Avatar"
    local4 = callisis_player_female()
    add_answer({"bye", "job", "name"})

    if not get_flag(0x029F) then
        local5 = local2
    elseif not get_flag(0x02A0) then
        local5 = local3
    end

    if local1 == 7 and not (get_flag(0x029C) and callis_0065(2) < 2 or get_flag(0x029E) and callis_0065(3) < 2 or get_flag(0x029D) and callis_0065(4) < 2) then
        add_dialogue("This attractive woman looks at you with surprise and says, \"A moment! Thou didst just enjoy thyself, didst thou not? Please come back when thou art rested.\"*")
        return
    end

    if not get_flag(0x02AA) then
        add_dialogue("You see a gorgeous young woman with seductive eyes.")
        if not local4 then
            add_dialogue("\"Hello, handsome!\"")
        else
            add_dialogue("\"Hello. Art thou sure thou dost not really want to speak with Roberto?\"")
            local6 = call_090AH()
            if local6 then
                add_dialogue("\"Fine, sweetheart. Whatever makes thy blood boil...\"")
            else
                add_dialogue("\"Then thou hadst best speak with Roberto! He is probably more thy type.\"*")
                return
            end
        end
        add_dialogue("Who art thou?\"")
        local9 = call_090BH({local3, local2})
        if local9 == local2 then
            if not local4 then
                add_dialogue("\"Well, I am very pleased to meet thee, ", local2, ".\"")
            else
                add_dialogue("\"Hello, ", local2, ".\"")
            end
            local5 = local2
            set_flag(0x029F, true)
        elseif local9 == local3 then
            add_dialogue("\"Oh ho! A real live Avatar?\"")
            if not local4 then
                add_dialogue("\"Say, we should get to know one another better!\"")
            else
                add_dialogue("\"And female, as well! And I thought I had seen it all...\"")
            end
            local5 = local3
            set_flag(0x02A0, true)
        end
        set_flag(0x02AA, true)
    else
        add_dialogue("\"Hello again, ", local5, ",\" Wench says.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"Thou canst just call me... Wench.\"")
            if not local4 then
                add_dialogue("She blows you a kiss.")
            end
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("She laughs aloud. \"Thou must be kidding!\" She composes herself and says, \"It is my duty to see that thou art comfortable whilst at The Baths.\"")
            add_answer({"comfortable", "The Baths"})
        elseif answer == "The Baths" then
            add_dialogue("\"I have been working here since it opened. I love it. I am not exploited in the least. I make piles of gold and live a great life.\"")
            if not local4 then
                add_dialogue("She winks at you. \"I meet many nice men, too!\"")
            end
            remove_answer("The Baths")
        elseif answer == "comfortable" then
            add_dialogue("\"Well, we could have a swim in the spring pools, or thou couldst have a massage. Or we could just talk.~~\"Or... thou couldst come with me into the Community Room and I'll 'show' thee my 'job'!\"")
            add_answer({"Community Room", "talk", "massage", "swim"})
            remove_answer("comfortable")
        elseif answer == "Community Room" then
            add_dialogue("\"Thou dost want to join me in the Community Room?\"")
            local7 = call_090AH()
            if local7 then
                add_dialogue("Wench leads you into a private room.~~\"It really isn't a Community Room at all. We shall be all alone,\" she giggles. ~~\"By the way, it is a good thing thou didst choose me. Roberto and Martine enjoy stealing gold from their customers. I may have questionable morals, but I am not a thief! Now, let us get down to business, shall we?\"")
                add_dialogue("A while later, after the woman has shown you more tricks than a mage on stage, you emerge from the Community Room a much happier Avatar.")
                set_flag(0x029D, true)
                calli_0066(4)
            else
                add_dialogue("\"'Tis not a problem, ", local5, ".\"")
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
            local8 = call_090AH()
            if local8 then
                add_dialogue("\"Didst thou know that there are secret passages in the mountains connecting the buildings on Buccaneer's Den? 'Tis true! I am fairly sure the entrance is through the House of Games, and I do know that there is a way into The Baths from the passages!\"")
            else
                add_dialogue("Wench pouts. \"Well never mind, then!\"")
            end
            add_dialogue("You and Wench speak of a number of other subjects when you realize that you are spending too much time in the spa. There is a quest to fulfill!")
            remove_answer("talk")
        elseif answer == "bye" then
            add_dialogue("\"Oh, please come again soon, ", local5, "!\"")
            if not local4 then
                add_dialogue("Wench blows you a kiss.*")
            else
                add_dialogue("Wench waves goodbye.*")
            end
            return
        end
    end

    return
end

-- Helper functions
function add_dialogue(...)
    print(table.concat({...}))
end

function wait_for_answer()
    return "bye" -- Placeholder
end

function get_flag(flag)
    return false -- Placeholder
end

function set_flag(flag, value)
    -- Placeholder
end