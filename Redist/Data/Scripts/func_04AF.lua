-- Function 04AF: Fenn's beggar dialogue and venom theft defense
function func_04AF(eventid, itemref)
    -- Local variables (9 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8

    if eventid == 0 then
        local5 = callis_003B()
        local6 = callis_001B(-175)
        local7 = callis_001C(local6)
        if local7 == 11 then
            local8 = callis_Random2(4, 1)
            if local8 == 1 then
                _ItemSay("@A coin for some food?@", -175)
            elseif local8 == 2 then
                _ItemSay("@Please aid a poor beggar!@", -175)
            elseif local8 == 3 then
                _ItemSay("@Show some generosity!@", -175)
            elseif local8 == 4 then
                _ItemSay("@Help one less fortunate!@", -175)
            end
        else
            call_092EH(-175)
        end
        return
    elseif eventid ~= 1 then
        return
    end

    _SwitchTalkTo(0, -175)
    local0 = call_0909H()
    _AddAnswer({"bye", "job", "name"})

    if get_flag(0x0212) then
        _AddAnswer("thief")
    end

    if not get_flag(0x0228) then
        say("You see a beggar. You cannot tell from the look on his face whether he is about to laugh or cry.")
        set_flag(0x0228, true)
    else
        say("\"Beg thy pardon, ", local0, ",\" Fenn says.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"My name is Fenn, ", local0, ".\"")
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("He looks away from you shamefully. \"I have none, ", local0, ".\"")
            _AddAnswer({"none", "give"})
        elseif answer == "none" then
            say("\"I used to be a farmer in more prosperous times. I used to work with Komor and Merrick.\"")
            _AddAnswer({"Komor", "Merrick"})
            _RemoveAnswer("none")
        elseif answer == "thief" then
            if get_flag(0x0218) then
                say("After you tell him about finding the venom vial, he says, \"Thou didst our town a service when thou didst uncover that no good brat Garritt as the thief! Perhaps now some people will start to realize the hypocrisy of The Fellowship!\"")
            elseif get_flag(0x0213) then
                say("\"I know that boy Tobias is innocent of any wrong doing, no matter what Feridwyn and his Fellowship says.\"")
            else
                say("\"Be wary for there is a thief in this town! Some silver serpent venom was stolen from the merchant Morfin, who runs the slaughterhouse.\"")
                set_flag(0x0212, true)
            end
            _RemoveAnswer("thief")
        elseif answer == "Komor" then
            say("\"He is my best friend and the bravest man I know.\"")
            local1 = call_08F7H(-174)
            if local1 then
                _SwitchTalkTo(0, -174)
                say("\"Oh, please! Thou art making mine eyes leak!\"*")
                _HideNPC(-174)
                _SwitchTalkTo(0, -175)
            end
            _RemoveAnswer("Komor")
        elseif answer == "Merrick" then
            say("\"Merrick joined The Fellowship so he could live in their shelter, the poor sod.\"")
            _AddAnswer({"Fellowship", "shelter"})
            _RemoveAnswer("Merrick")
        elseif answer == "Fellowship" then
            say("\"If The Fellowship truly wants to help people, why would they let us starve just because we do not want to join? They cannot answer that one!\"")
            _AddAnswer("starve")
            _RemoveAnswer("Fellowship")
        elseif answer == "shelter" then
            say("\"Hmf! If thou art so unfortunate as to want to live there, thou wouldst do better on the corner with Komor and I.\"")
            _AddAnswer("corner")
            _RemoveAnswer("shelter")
        elseif answer == "corner" then
            say("\"Even when pockets are light, there is still some mercy left in this world. Begging for money is not a proud profession, but there are worse ones.\"")
            _AddAnswer("worse")
            _RemoveAnswer("corner")
        elseif answer == "worse" then
            say("\"At least we do not have to do what Merrick does. He recruits for The Fellowship.\"")
            _RemoveAnswer("worse")
        elseif answer == "starve" then
            say("\"Do not worry. We shall not starve. Camille sends her son Tobias with food and clothing for us every so often.\"")
            _AddAnswer({"Camille", "Tobias"})
            _RemoveAnswer("starve")
        elseif answer == "Camille" then
            say("\"Camille is a good woman. She lives at the farm bordering the dairy.\"")
            _RemoveAnswer("Camille")
        elseif answer == "Tobias" then
            say("\"He is a fine lad, always willing to give us a hand. Unlike that rude urchin, Garritt.\"")
            if get_flag(0x0213) then
                _AddAnswer("venom")
            end
            _AddAnswer("Garritt")
            _RemoveAnswer("Tobias")
        elseif answer == "venom" then
            say("\"Tobias would not become involved with that sort of affair. I know for certain he is no thief.\"")
            _AddAnswer("involved")
            _RemoveAnswer("venom")
        elseif answer == "involved" then
            say("\"If thou art seeking out this venom thief, thou wouldst do well to ask Andrew about it.\"")
            _AddAnswer("Andrew")
            _RemoveAnswer("involved")
        elseif answer == "Andrew" then
            say("\"Andrew owns the dairy and lives across from Camille's farm and the slaughterhouse. He might have seen something.\"")
            _RemoveAnswer("Andrew")
        elseif answer == "Garritt" then
            say("\"He is the son of Feridwyn and Brita, who run the shelter. Garritt crosses the road to avoid us.\"")
            local1 = call_08F7H(-174)
            if local1 then
                _SwitchTalkTo(0, -174)
                say("\"We would not want the likes of him walking down our side of the road anyway!\"*")
                _HideNPC(-174)
                _SwitchTalkTo(0, -175)
            end
            _RemoveAnswer("Garritt")
        elseif answer == "give" then
            say("\"Wilt thou give me a bit of money?\"")
            local2 = call_090AH()
            if local2 then
                say("How much?")
                _SaveAnswers()
                local3 = call_090BH({"5", "4", "3", "2", "1", "0"})
                local4 = callis_0028(-359, -359, 644, -357)
                if local4 >= local3 and local3 ~= "0" then
                    local5 = callis_002B(true, -359, -359, 644, local3)
                    if local5 then
                        say("\"Thank thee, ", local0, ".\"")
                    end
                elseif local4 == 0 then
                    say("\"It appears thou dost not have any money either!\"")
                else
                    say("\"I am truly sorry if I have bothered thee, ", local0, ".\"")
                end
                _RestoreAnswers()
            else
                say("Fenn hangs his head low.")
            end
            _RemoveAnswer("give")
        elseif answer == "bye" then
            say("\"Good fortune to ye, ", local0, ".\"*")
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