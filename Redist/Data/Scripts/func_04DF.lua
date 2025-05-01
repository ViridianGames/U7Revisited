-- Function 04DF: Martine's hostess dialogue and secret passage hint
function func_04DF(eventid, itemref)
    -- Local variables (11 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10

    if eventid == 0 then
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(223, 0)
    local0 = callis_003B()
    local1 = callis_001C(callis_001B(-223))
    local2 = call_0908H()
    local3 = "Avatar"
    local4 = callis_IsPlayerFemale()
    add_answer({"bye", "job", "name"})

    if not get_flag(0x029A) then
        local5 = local2
    elseif not get_flag(0x029B) then
        local5 = local3
    end

    if local1 == 7 and not (get_flag(0x029D) and callis_0065(4) < 2 or get_flag(0x029E) and callis_0065(3) < 2 or get_flag(0x029C) and callis_0065(2) < 2) then
        add_dialogue("This attractive woman looks at you with surprise and says, \"Honey, thou just enjoyed thyself, didst thou not? Please come back when thou art rested.\"*")
        return
    end

    if not get_flag(0x02AC) then
        add_dialogue("You see a beautiful young woman with a tropical air.")
        if not local4 then
            add_dialogue("\"Hello, handsome!\"")
        else
            add_dialogue("\"Hello, dear. Art thou sure thou dost not want to speak with Roberto?\"")
            local6 = call_090AH()
            if local6 then
                add_dialogue("\"All right, honey. Whatever heats thy blood...\"")
            else
                add_dialogue("\"Then thou had best speak with him! He is probably more to thy liking.\"*")
                return
            end
        end
        add_dialogue("\"What is thy name?\"")
        local9 = call_090BH({local3, local2})
        if local9 == local2 then
            if not local4 then
                add_dialogue("\"How art thou, ", local2, "? I am so happy to meet thee!\"")
            else
                add_dialogue("\"Hello, ", local2, ".\"")
            end
            local5 = local2
            set_flag(0x029A, true)
        elseif local9 == local3 then
            add_dialogue("\"Oh please! Not another Avatar!\"")
            if not local4 then
                add_dialogue("Martine takes a deep breath, then smiles.")
                add_dialogue("\"Well, honey, it does not matter who thou art. We shalt have a good time anyway.\"")
            end
            local5 = local3
            set_flag(0x029B, true)
        end
        set_flag(0x02AC, true)
    else
        add_dialogue("\"Hello again, ", local5, ",\" Martine says.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"The name I use here is Martine. Thou dost understand...\" She winks at you.")
            remove_answer("name")
        elseif answer == "job" then
            if not local4 then
                add_dialogue("\"Honey, my job is to make thee happy.\"")
            else
                add_dialogue("\"My dear, my job is to serve thee.\"")
            end
            add_dialogue("\"'Tis important that thou art comfortable whilst visiting The Baths.\"")
            add_answer({"comfortable", "The Baths"})
        elseif answer == "The Baths" then
            add_dialogue("\"'Tis a fabulous place to work. I absolutely love it. I would not work anywhere else. I have more gold than I could possibly spend.\"")
            if not local4 then
                add_dialogue("Martine blows a kiss at you. \"I meet many kinds of interesting people, too!\"")
            end
            remove_answer("The Baths")
        elseif answer == "comfortable" then
            add_dialogue("\"Thou dost have many choices. We could take a swim in our spring pools. Or I could perform a massage on thee. Or we could simply talk.~~\"But if thou dost want to really get to know me better, we should visit the Community Room...\"")
            add_answer({"Community Room", "talk", "massage", "swim"})
            remove_answer("comfortable")
        elseif answer == "Community Room" then
            add_dialogue("\"Thou dost want to join me in the Community Room?\"")
            local7 = call_090AH()
            if local7 then
                add_dialogue("Martine leads you into a private room.~~\"It really is not a Community Room at all. We shall be all alone!\"~~ A while later, after the woman has shown you more tricks than a crooked street mage, you emerge from the Community Room a much happier Avatar.")
                set_flag(0x029C, true)
                calli_0066(2)
                local10 = callis_002B(true, -359, -359, 644, 50)
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
            add_dialogue("Martine smiles. \"That is just fine with me, honey. I would wager thou hast many stories to tell about adventuring, yes? Say! Hast thou been in the secret passages in the mountains? Didst thou know they are all connected? I know that there is a secret door that leads right into the back of this building!\" She whispers, \"I believe the entrance is through the House of Games.\"~~You and Martine speak of a number of other subjects until you realize you have spent too much time in the spa. There is a quest to finish!")
            remove_answer("talk")
        elseif answer == "bye" then
            add_dialogue("\"I hope to see thee again soon, honey!\"")
            if not local4 then
                add_dialogue("Martine blows you a kiss.*")
            else
                add_dialogue("Martine waves goodbye.*")
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