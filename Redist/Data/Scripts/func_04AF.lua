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
                bark(175, "@A coin for some food?@")
            elseif local8 == 2 then
                bark(175, "@Please aid a poor beggar!@")
            elseif local8 == 3 then
                bark(175, "@Show some generosity!@")
            elseif local8 == 4 then
                bark(175, "@Help one less fortunate!@")
            end
        else
            call_092EH(-175)
        end
        return
    elseif eventid ~= 1 then
        return
    end

    switch_talk_to(175, 0)
    local0 = call_0909H()
    add_answer({"bye", "job", "name"})

    if get_flag(0x0212) then
        add_answer("thief")
    end

    if not get_flag(0x0228) then
        add_dialogue("You see a beggar. You cannot tell from the look on his face whether he is about to laugh or cry.")
        set_flag(0x0228, true)
    else
        add_dialogue("\"Beg thy pardon, ", local0, ",\" Fenn says.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"My name is Fenn, ", local0, ".\"")
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("He looks away from you shamefully. \"I have none, ", local0, ".\"")
            add_answer({"none", "give"})
        elseif answer == "none" then
            add_dialogue("\"I used to be a farmer in more prosperous times. I used to work with Komor and Merrick.\"")
            add_answer({"Komor", "Merrick"})
            remove_answer("none")
        elseif answer == "thief" then
            if get_flag(0x0218) then
                add_dialogue("After you tell him about finding the venom vial, he says, \"Thou didst our town a service when thou didst uncover that no good brat Garritt as the thief! Perhaps now some people will start to realize the hypocrisy of The Fellowship!\"")
            elseif get_flag(0x0213) then
                add_dialogue("\"I know that boy Tobias is innocent of any wrong doing, no matter what Feridwyn and his Fellowship says.\"")
            else
                add_dialogue("\"Be wary for there is a thief in this town! Some silver serpent venom was stolen from the merchant Morfin, who runs the slaughterhouse.\"")
                set_flag(0x0212, true)
            end
            remove_answer("thief")
        elseif answer == "Komor" then
            add_dialogue("\"He is my best friend and the bravest man I know.\"")
            local1 = call_08F7H(-174)
            if local1 then
                switch_talk_to(174, 0)
                add_dialogue("\"Oh, please! Thou art making mine eyes leak!\"*")
                _HideNPC(-174)
                switch_talk_to(175, 0)
            end
            remove_answer("Komor")
        elseif answer == "Merrick" then
            add_dialogue("\"Merrick joined The Fellowship so he could live in their shelter, the poor sod.\"")
            add_answer({"Fellowship", "shelter"})
            remove_answer("Merrick")
        elseif answer == "Fellowship" then
            add_dialogue("\"If The Fellowship truly wants to help people, why would they let us starve just because we do not want to join? They cannot answer that one!\"")
            add_answer("starve")
            remove_answer("Fellowship")
        elseif answer == "shelter" then
            add_dialogue("\"Hmf! If thou art so unfortunate as to want to live there, thou wouldst do better on the corner with Komor and I.\"")
            add_answer("corner")
            remove_answer("shelter")
        elseif answer == "corner" then
            add_dialogue("\"Even when pockets are light, there is still some mercy left in this world. Begging for money is not a proud profession, but there are worse ones.\"")
            add_answer("worse")
            remove_answer("corner")
        elseif answer == "worse" then
            add_dialogue("\"At least we do not have to do what Merrick does. He recruits for The Fellowship.\"")
            remove_answer("worse")
        elseif answer == "starve" then
            add_dialogue("\"Do not worry. We shall not starve. Camille sends her son Tobias with food and clothing for us every so often.\"")
            add_answer({"Camille", "Tobias"})
            remove_answer("starve")
        elseif answer == "Camille" then
            add_dialogue("\"Camille is a good woman. She lives at the farm bordering the dairy.\"")
            remove_answer("Camille")
        elseif answer == "Tobias" then
            add_dialogue("\"He is a fine lad, always willing to give us a hand. Unlike that rude urchin, Garritt.\"")
            if get_flag(0x0213) then
                add_answer("venom")
            end
            add_answer("Garritt")
            remove_answer("Tobias")
        elseif answer == "venom" then
            add_dialogue("\"Tobias would not become involved with that sort of affair. I know for certain he is no thief.\"")
            add_answer("involved")
            remove_answer("venom")
        elseif answer == "involved" then
            add_dialogue("\"If thou art seeking out this venom thief, thou wouldst do well to ask Andrew about it.\"")
            add_answer("Andrew")
            remove_answer("involved")
        elseif answer == "Andrew" then
            add_dialogue("\"Andrew owns the dairy and lives across from Camille's farm and the slaughterhouse. He might have seen something.\"")
            remove_answer("Andrew")
        elseif answer == "Garritt" then
            add_dialogue("\"He is the son of Feridwyn and Brita, who run the shelter. Garritt crosses the road to avoid us.\"")
            local1 = call_08F7H(-174)
            if local1 then
                switch_talk_to(174, 0)
                add_dialogue("\"We would not want the likes of him walking down our side of the road anyway!\"*")
                _HideNPC(-174)
                switch_talk_to(175, 0)
            end
            remove_answer("Garritt")
        elseif answer == "give" then
            add_dialogue("\"Wilt thou give me a bit of money?\"")
            local2 = call_090AH()
            if local2 then
                add_dialogue("How much?")
                _SaveAnswers()
                local3 = call_090BH({"5", "4", "3", "2", "1", "0"})
                local4 = callis_0028(-359, -359, 644, -357)
                if local4 >= local3 and local3 ~= "0" then
                    local5 = callis_002B(true, -359, -359, 644, local3)
                    if local5 then
                        add_dialogue("\"Thank thee, ", local0, ".\"")
                    end
                elseif local4 == 0 then
                    add_dialogue("\"It appears thou dost not have any money either!\"")
                else
                    add_dialogue("\"I am truly sorry if I have bothered thee, ", local0, ".\"")
                end
                _RestoreAnswers()
            else
                add_dialogue("Fenn hangs his head low.")
            end
            remove_answer("give")
        elseif answer == "bye" then
            add_dialogue("\"Good fortune to ye, ", local0, ".\"*")
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