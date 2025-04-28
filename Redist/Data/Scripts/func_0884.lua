require "U7LuaFuncs"
-- Function 0884: Mayor's investigation dialogue
function func_0884(eventid, itemref)
    local local0, local1, local2, local3, local4, local5

    local0 = call_0909H()
    call_0009H()
    if not get_flag(94) then
        say(itemref, "\"Very well. What was Christopher's occupation?\"")
        local1 = call_090BH({"barkeep", "provisioner", "blacksmith", "tailor"})
        if local1 == "blacksmith" then
            set_flag(94, true)
        else
            say(itemref, "\"That is not right. Thou shouldst do some more work.\"*")
            return
        end
    end
    if not get_flag(95) then
        call_0009H()
        say(itemref, "\"What didst thou find at the murder site?\"")
        local1 = call_090BH({"a bucket", "a key", "a body", "nothing"})
        if local1 == "a key" then
            set_flag(95, true)
        elseif local1 == "a body" then
            say(itemref, "\"I know that! What ELSE didst thou find? Thou shouldst look again, Avatar!\"*")
            return
        elseif local1 == "a bucket" then
            say(itemref, "\"Yes, obviously it is filled with poor Christopher's own blood. But surely there was something else that might point us in the direction of the killer or killers - thou shouldst look again, Avatar.\"*")
            return
        elseif local1 == "nothing" then
            say(itemref, "\"Thou shouldst look again, 'Avatar'!\"*")
            return
        end
    end
    if not get_flag(96) then
        call_0009H()
        say(itemref, "\"What did the key open?\"")
        local1 = call_090BH({"a chest", "a trap door", "a door", "a book"})
        if local1 == "a chest" then
            set_flag(96, true)
        else
            say(itemref, "\"I do not think that is correct.\"*")
            return
        end
    end
    if not get_flag(97) then
        call_0009H()
        say(itemref, "\"What didst thou find in the chest?\"")
        local1 = call_090BH({"all of these", "none of these", "a scroll", "a medallion", "gold"})
        if local1 == "all of these" then
            call_0009H()
            say(itemref, "\"Dost thou have a suspect?\"")
            if get_answer() then
                set_flag(97, true)
            else
                say(itemref, "\"Well, continue to gather information until thou dost have one.\"*")
                return
            end
        elseif local1 == "gold" or local1 == "a medallion" or local1 == "a scroll" then
            say(itemref, "\"Hmmm. I cannot believe that was all. Perhaps thou shouldst search again.\"*")
            return
        elseif local1 == "none of these" then
            say(itemref, "\"I do not believe thou hast searched properly.\"*")
            return
        end
    end
    if not get_flag(98) then
        call_0009H()
        say(itemref, "\"What dost this villain look like?\"")
        local2 = {"eyepatch", "pegleg", "scar", "I don't know"}
        if not get_flag(67) then
            table.insert(local2, "hook")
        end
        local3 = call_090BH(local2)
        if local3 == "hook" then
            set_flag(98, true)
        else
            say(itemref, "\"That is not satisfactory. Thou must needs continue thy search, Avatar.\"*")
            return
        end
    end
    if not get_flag(99) then
        call_0009H()
        say(itemref, "\"Hmmm. Any leads on finding this villain?\"")
        local2 = {"No one saw him", "Could be anywhere", "I don't know"}
        if not get_flag(64) then
            table.insert(local2, "Crown Jewel")
        end
        local4 = call_090BH(local2)
        if local4 == "Crown Jewel" then
            set_flag(99, true)
            say(itemref, "\"The Mayor is pleased.~~\"It seems that thou art pursuing thine investigation with genuine fervor. Methinks thou shouldst go to Britain and see if thou canst find this Man with a Hook.\"")
            if not get_flag(68) then
                say(itemref, "\"Here is half of thy reward money. Thou wilt receive the rest when thou dost prove that the killer hath been brought to justice!\"")
                local5 = give_item(true, -359, -359, 644, 100)
                if not local5 then
                    say(itemref, "\"Thou dost not have enough companions to carry thy reward! Thou must return to me later, and I will give thee thy gold.\"")
                    set_flag(69, true)
                else
                    say(itemref, "\"The Mayor hands you 100 gold coins.\"")
                    set_flag(68, true)
                    set_flag(69, false)
                end
            end
            say(itemref, "\"Dost thou need the password?\"")
            set_flag(66, true)
            if get_answer() then
                if call_0886H() then
                    say(itemref, "\"Excellent! I have no doubt now that thou art the one true Avatar!\"")
                    say(itemref, "\"Oh-- I almost forgot! The password to leave or enter the town is `Blackbird'!\"*")
                    set_flag(61, true)
                    call_0911H(100)
                    return
                else
                    say(itemref, "\"Hmmm. I am afraid that I still have my doubts about thou being the Avatar. My public duty disallows me to give thee the password. I am sorry.\"")
                    return
                end
            else
                say(itemref, "\"All right then. Thou dost know that thou must have the password to leave or enter our town? I ask again -- dost thou wish to know the password?\"")
                if get_answer() then
                    if call_0886H() then
                        say(itemref, "\"Excellent! I have no doubt now that thou art the one true Avatar!\"")
                        say(itemref, "\"Oh-- I almost forgot! The password to leave or enter the town is `Blackbird'!\"*")
                        set_flag(61, true)
                        call_0911H(100)
                        return
                    else
                        say(itemref, "\"Hmmm. I am afraid that I still have my doubts about thou being the Avatar. My public duty disallows me to give thee the password. I am sorry.\"")
                        return
                    end
                else
                    say(itemref, "\"All right, " .. local0 .. ". I thank thee for all thine help.\"*")
                    return
                end
            end
        else
            say(itemref, "\"Hmmm. Methinks thou shouldst continue the investigation. Be sure to talk with Gilberto and Johnson. Question them closely.\"*")
            return
        end
    end
    return
end