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

    _SwitchTalkTo(0, -177)
    local0 = call_0909H()

    if get_flag(0x0213) and not get_flag(0x0234) then
        say("\"Avatar! My son Tobias has been wrongly accused! He is no thief! And I cannot believe a vial of venom was found in his possession. I truly believe it was planted there! Please -- I beg thee! Please clear my son's name. He has done no wrong!\"")
        say("\"I know my son Tobias has suffered for not having a father. I have tried my best on mine own to raise him well, but this farm requires so much work that I fear I do not have enough time to devote to him. But I know in mine heart that my son is not a thief.\"*")
        say("\"Might I suggest that thou speak with Morfin again. He may have recognized signs of usage of this foul substance in other members of the village.\"")
        calli_001D(11, callis_001B(-177))
        set_flag(0x0234, true)
        return
    end

    _AddAnswer({"bye", "job", "name"})

    if get_flag(0x0212) then
        _AddAnswer("thief")
    end
    if get_flag(0x0213) then
        _AddAnswer("Feridwyn")
    end
    if get_flag(0x0218) then
        _AddAnswer("Tobias cleared")
        _RemoveAnswer({"thief", "Feridwyn"})
    end

    if not get_flag(0x022A) then
        say("You see a farm woman. She rubs her hands, which are covered with dirt and lines drawn by toil.")
        say("\"My dreams have become reality. Thou art the Avatar, art thou not? I recognized thee immediately!\"")
        set_flag(0x022A, true)
    else
        say("\"How art thou, ", local0, "?\" Camille asks.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"My name is Camille, Avatar. It is an honor to meet thee.\"")
            set_flag(0x022A, true)
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("\"I run a small farm here in Paws with my son, Tobias. I am a widow.\"")
            _AddAnswer({"Tobias", "Paws"})
            if not get_flag(0x021A) then
                _AddAnswer("farm")
            end
        elseif answer == "farm" then
            say("\"I grow a few crops. Especially carrots and wheat.\"")
            _AddAnswer({"wheat", "carrots"})
            _RemoveAnswer("farm")
        elseif answer == "carrots" then
            say("\"I believe my carrots are especially tasty. Wouldst thou like to purchase some? They would only cost thee one gold for three.\"")
            local1 = call_090AH()
            if local1 then
                say("\"How many dost thou desire?\"")
                local2 = call_AskNumber(3, 3, 30, 3)
                local3 = local2 / 3
                local4 = callis_002B(true, -359, -359, 644, local3)
                if local4 then
                    local5 = callis_002C(true, 18, -359, 377, local2)
                    if local5 then
                        say("\"I am sure thou wilt love them.\"")
                    else
                        say("\"Thou must first lighten thy load. Then I can give thee some delicious carrots.\"")
                        callis_002C(true, -359, -359, 644, local3)
                    end
                else
                    say("\"I am sorry, Avatar.\" She shakes her head sadly. \"Thou dost not have the gold to be able to taste them.\"")
                    local6 = callis_002C(true, 18, -359, 377, 1)
                    if local6 then
                        say("Smiling gently, she hands you a carrot.")
                    else
                        say("\"Thou art carrying too much...\" She seems truly disappointed.")
                    end
                end
            else
                say("\"If that is thy wish, Avatar, but they are quite good!\"")
            end
            _RemoveAnswer("carrots")
        elseif answer == "wheat" then
            say("\"That reminds me. This package needs to be taken to the mill today. If thou canst deliver it for me, Thurston will pay thee for it. Wilt thou?\"")
            local7 = call_090AH()
            if local7 then
                local8 = callis_002C(true, -359, -359, 677, 1)
                if local8 then
                    say("\"Be sure and take this to Thurston, the mill owner. He shall pay thee for thy trouble.\"")
                    set_flag(0x021A, true)
                else
                    say("\"Thou art carrying too much! Go put something down and I will give it to thee then.\"")
                end
            else
                say("\"I understand that thou art busy on thy quest, Avatar.\"")
            end
            _RemoveAnswer("wheat")
        elseif answer == "Paws" then
            say("\"Life is hard here in Paws. It is a town of poor people with all the ills that poverty brings. At least The Fellowship brings us some relief.\"")
            _AddAnswer({"Fellowship", "ills"})
            _RemoveAnswer("Paws")
        elseif answer == "Tobias" then
            if get_flag(0x0213) then
                say("\"I know my son. I know that he is growing up unhappy. But I cannot believe that he would steal things.\"")
            end
            say("\"He is basically a good boy. He works hard and misses his father.\"")
            _RemoveAnswer("Tobias")
        elseif answer == "Fellowship" then
            say("\"I am not sure whether I trust The Fellowship. It has undoubtedly done some good things in this world so it cannot be all bad. Or, at least, the people in it cannot be all bad.\"")
            _RemoveAnswer("Fellowship")
        elseif answer == "ills" then
            say("\"Recently, our town has been plagued by a thief.\"")
            _AddAnswer("thief")
            _RemoveAnswer("ills")
        elseif answer == "thief" then
            if not get_flag(0x0213) then
                say("\"Some silver serpent venom was stolen from the merchant Morfin who operates the slaughterhouse.\"")
                set_flag(0x0212, true)
            else
                say("\"I do not care what Feridwyn says! My son is no thief!\"")
            end
            _RemoveAnswer("thief")
        elseif answer == "Feridwyn" then
            say("\"That man Feridwyn knows that I do not trust The Fellowship, and for that he considers me his personal enemy. I do not know why he would seek to attack me through my son but he must not be allowed to succeed.\"")
            _RemoveAnswer("Feridwyn")
        elseif answer == "Tobias cleared" then
            say("You tell Camille how you discovered that Garritt was really the thief and that her son Tobias has been cleared. \"I want to thank thee for finding the thief in our town and clearing my son's name. It does mine heart good to see that the Avatar has returned to us once again and that thou dost care enough about the people of Britannia to help solve our local troubles here in Paws. Again Avatar, I thank thee.\"")
            _RemoveAnswer("Tobias cleared")
        elseif answer == "bye" then
            say("\"Pleasant journey, Avatar.\"*")
            break
        end
    end

    return
end

-- Helper functions
function say(...)
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