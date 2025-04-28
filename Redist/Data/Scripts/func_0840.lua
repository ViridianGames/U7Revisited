require "U7LuaFuncs"
-- Function 0840: Sage notebook quest
function func_0840(eventid, itemref)
    local local0, local1, local2, local3

    _SaveAnswers()
    local0 = call_090BH({"I don't know", "Have Faith", "Strive for Unity", "No Answers", "Be Good"})
    if local0 == "No Answers" then
        say(itemref, "The sage smiles. \"Thou hast begun thy journey on the road to enlightenment. As thou hast heard, all is not what one has been taught by one's teachers. 'Tis a pity. Now I suppose thou dost want to borrow the notebook?\"")
        local1 = get_answer()
        if local1 then
            say(itemref, "\"Very well. Dost thou promise to return my notebook?\"")
            local2 = get_answer()
            if local2 then
                if check_gold(-359, 254, 641, -357) then
                    say(itemref, "\"Then go find it! Thou hast the key!\"")
                else
                    local3 = give_item(false, -359, 254, 641, 1)
                    if local3 then
                        say(itemref, "\"Very well. I am counting on thee to return it to me personally. No telling what misfortune may befall thee if thou dost fail to do so. And as further incentive, I just might give thee something else which will help thee in thy quest if thou dost return it to me safely.~~\"Here is the key to my storeroom, the first building to the south of here.\" He grins slyly. \"Thou must determine how to find the notebook thyself!\"")
                    else
                        say(itemref, "\"Thou hast not enough room to take my key! Unload thy belongings and we shall try all of this again!\"*")
                    end
                end
            else
                say(itemref, "\"Then I cannot let thee borrow the notebook!\"")
            end
        else
            say(itemref, "\"Oh. Very well, then.\"*")
        end
    else
        say(itemref, "The sage frowns. \"That is not correct. Go and seek the true answer.\"*")
    end
    _RestoreAnswers()
    return
end