-- Function 0862: Chuckles dialogue
function func_0862(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6

    local0 = call_08F7H(-1)
    local1 = false
    local2 = false
    local3 = false
    local4 = false
    add_dialogue(itemref, "\"Then prove it. Talk to me.\"")
    call_0009H()
    local5 = call_090BH({"Hi, Chuck", "Hi, Chuckles", "Hello, Fool", "Hello, Chuckles"})
    if local5 == "Hi, Chuck" then
        add_dialogue(itemref, "\"Hi there! What is on thy mind?\"")
        local1 = true
        call_0009H()
    else
        call_0861H()
    end
    if local1 then
        local5 = call_090BH({"I need answers", "many problems", "too much", "trouble"})
        if local5 == "too much" then
            add_dialogue(itemref, "\"Ah, I do know what thou dost mean! Thou dost need help, yes?\"")
            local2 = true
            call_0009H()
        else
            call_0861H()
        end
    end
    if local2 then
        local5 = call_090BH({"Most assuredly", "Canst thou help?", "Absolutely", "Yes, I do"})
        if local5 == "Yes, I do" or local5 == "Canst thou help?" then
            add_dialogue(itemref, "\"Hmmm. I might could give thee a clue.\"")
            if not local0 then
                switch_talk_to(1, 0)
                add_dialogue(itemref, "\"I would like to give Chuckles a black eye!\"")
                _HideNPC(-1)
                switch_talk_to(25, 0)
            end
            local3 = true
            call_0009H()
        else
            call_0861H()
        end
    end
    if local3 then
        local5 = call_090BH({"I wish thou wouldst", "That would be worthwhile", "I need it immediately", "That would be big of thee"})
        if local5 == "That would be big of thee" or local5 == "I wish thou wouldst" then
            add_dialogue(itemref, "\"What wilt thou give me for a clue?\"")
            local4 = true
            call_0009H()
        else
            call_0861H()
        end
    end
    if local4 then
        local5 = call_090BH({"nothing", "a smile", "my friendship", "gold", "I shan't murder thee"})
        if local5 == "gold" then
            add_dialogue(itemref, "\"Chuckles holds his hand up. \"'Tis not right. I give thee a clue for free. 'Tis here in this scroll.\"")
            local6 = give_item(false, -359, 1, 797, 1)
            if local6 then
                set_flag(111, true)
                call_0911H(50)
                call_0009H()
                add_dialogue(itemref, "\"So long, my friend! Do not forg... I mean, do not lose how to play The Game!\"*")
                return
            else
                add_dialogue(itemref, "\"Oh! Thou dost not have room for the scroll! Put down thy things and I shall give it to thee!\"*")
                return
            end
        elseif local5 == "a smile" then
            add_dialogue(itemref, "\"How nice! All right! I shall give thee a clue. 'Tis here in this scroll.\"")
            local6 = give_item(false, -359, 1, 797, 1)
            if local6 then
                set_flag(111, true)
                call_0911H(50)
                call_0009H()
                add_dialogue(itemref, "\"So long, my friend! Do not forg... I mean, do not lose how to play The Game!\"*")
                return
            else
                add_dialogue(itemref, "\"Oh! Thou dost not have room for the scroll! Put down some of thy things and I can give it to thee!\"*")
                return
            end
        elseif local5 == "I shan't murder thee" or local5 == "my friendship" or local5 == "nothing" then
            call_0861H()
        end
    end
    return
end