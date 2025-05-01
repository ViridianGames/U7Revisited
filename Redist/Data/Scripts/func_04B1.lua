-- Function 04B1: Camille's farm dialogue and Tobias defense
function func_04B1(eventid, itemref)
    -- Local variables (10 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9

    if eventid == 0 then
        call_092EH(-177)
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(177, 0)
    local0 = call_0909H()

    if get_flag(0x0213) and not get_flag(0x0234) then
        add_dialogue("\"Avatar! My son Tobias has been wrongly accused! He is no thief! And I cannot believe a vial of venom was found in his possession. I truly believe it was planted there! Please -- I beg thee! Please clear my son's name. He has done no wrong!\"")
        add_dialogue("\"I know my son Tobias has suffered for not having a father. I have tried my best on mine own to raise him well, but this farm requires so much work that I fear I do not have enough time to devote to him. But I know in mine heart that my son is not a thief.\"*")
        add_dialogue("\"Might I suggest that thou speak with Morfin again. He may have recognized signs of usage of this foul substance in other members of the village.\"")
        calli_001D(11, callis_001B(-177))
        set_flag(0x0234, true)
        return
    end

    add_answer({"bye", "job", "name"})

    if get_flag(0x0212) then
        add_answer("thief")
    end
    if get_flag(0x0213) then
        add_answer("Feridwyn")
    end
    if get_flag(0x0218) then
        add_answer("Tobias cleared")
        remove_answer({"thief", "Feridwyn"})
    end

    if not get_flag(0x022A) then
        add_dialogue("You see a farm woman. She rubs her hands, which are covered with dirt and lines drawn by toil.")
        add_dialogue("\"My dreams have become reality. Thou art the Avatar, art thou not? I recognized thee immediately!\"")
        set_flag(0x022A, true)
    else
        add_dialogue("\"How art thou, ", local0, "?\" Camille asks.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"My name is Camille, Avatar. It is an honor to meet thee.\"")
            set_flag(0x022A, true)
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("\"I run a small farm here in Paws with my son, Tobias. I am a widow.\"")
            add_answer({"Tobias", "Paws"})
            if not get_flag(0x021A) then
                add_answer("farm")
            end
        elseif answer == "farm" then
            add_dialogue("\"I grow a few crops. Especially carrots and wheat.\"")
            add_answer({"wheat", "carrots"})
            remove_answer("farm")
        elseif answer == "carrots" then
            add_dialogue("\"I believe my carrots are especially tasty. Wouldst thou like to purchase some? They would only cost thee one gold for three.\"")
            local1 = call_090AH()
            if local1 then
                add_dialogue("\"How many dost thou desire?\"")
                local2 = call_AskNumber(3, 3, 30, 3)
                local3 = local2 / 3
                local4 = callis_002B(true, -359, -359, 644, local3)
                if local4 then
                    local5 = callis_002C(true, 18, -359, 377, local2)
                    if local5 then
                        add_dialogue("\"I am sure thou wilt love them.\"")
                    else
                        add_dialogue("\"Thou must first lighten thy load. Then I can give thee some delicious carrots.\"")
                        callis_002C(true, -359, -359, 644, local3)
                    end
                else
                    add_dialogue("\"I am sorry, Avatar.\" She shakes her head sadly. \"Thou dost not have the gold to be able to taste them.\"")
                    local6 = callis_002C(true, 18, -359, 377, 1)
                    if local6 then
                        add_dialogue("Smiling gently, she hands you a carrot.")
                    else
                        add_dialogue("\"Thou art carrying too much...\" She seems truly disappointed.")
                    end
                end
            else
                add_dialogue("\"If that is thy wish, Avatar, but they are quite good!\"")
            end
            remove_answer("carrots")
        elseif answer == "wheat" then
            add_dialogue("\"That reminds me. This package needs to be taken to the mill today. If thou canst deliver it for me, Thurston will pay thee for it. Wilt thou?\"")
            local7 = call_090AH()
            if local7 then
                local8 = callis_002C(true, -359, -359, 677, 1)
                if local8 then
                    add_dialogue("\"Be sure and take this to Thurston, the mill owner. He shall pay thee for thy trouble.\"")
                    set_flag(0x021A, true)
                else
                    add_dialogue("\"Thou art carrying too much! Go put something down and I will give it to thee then.\"")
                end
            else
                add_dialogue("\"I understand that thou art busy on thy quest, Avatar.\"")
            end
            remove_answer("wheat")
        elseif answer == "Paws" then
            add_dialogue("\"Life is hard here in Paws. It is a town of poor people with all the ills that poverty brings. At least The Fellowship brings us some relief.\"")
            add_answer({"Fellowship", "ills"})
            remove_answer("Paws")
        elseif answer == "Tobias" then
            if get_flag(0x0213) then
                add_dialogue("\"I know my son. I know that he is growing up unhappy. But I cannot believe that he would steal things.\"")
            end
            add_dialogue("\"He is basically a good boy. He works hard and misses his father.\"")
            remove_answer("Tobias")
        elseif answer == "Fellowship" then
            add_dialogue("\"I am not sure whether I trust The Fellowship. It has undoubtedly done some good things in this world so it cannot be all bad. Or, at least, the people in it cannot be all bad.\"")
            remove_answer("Fellowship")
        elseif answer == "ills" then
            add_dialogue("\"Recently, our town has been plagued by a thief.\"")
            add_answer("thief")
            remove_answer("ills")
        elseif answer == "thief" then
            if not get_flag(0x0213) then
                add_dialogue("\"Some silver serpent venom was stolen from the merchant Morfin who operates the slaughterhouse.\"")
                set_flag(0x0212, true)
            else
                add_dialogue("\"I do not care what Feridwyn says! My son is no thief!\"")
            end
            remove_answer("thief")
        elseif answer == "Feridwyn" then
            add_dialogue("\"That man Feridwyn knows that I do not trust The Fellowship, and for that he considers me his personal enemy. I do not know why he would seek to attack me through my son but he must not be allowed to succeed.\"")
            remove_answer("Feridwyn")
        elseif answer == "Tobias cleared" then
            add_dialogue("You tell Camille how you discovered that Garritt was really the thief and that her son Tobias has been cleared. \"I want to thank thee for finding the thief in our town and clearing my son's name. It does mine heart good to see that the Avatar has returned to us once again and that thou dost care enough about the people of Britannia to help solve our local troubles here in Paws. Again Avatar, I thank thee.\"")
            remove_answer("Tobias cleared")
        elseif answer == "bye" then
            add_dialogue("\"Pleasant journey, Avatar.\"*")
            break
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