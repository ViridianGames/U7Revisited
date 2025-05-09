--- Best guess: Handles dialogue with Salamon, a wise Emp leader in Yew, discussing Emp dietary habits, Silverleaf tree homes, and a contract to stop a woodcutter from cutting down Silverleaf trees, with Trellek’s involvement requiring player action.
function func_0465(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009

    start_conversation()
    if eventid == 1 then
        var_0000 = unknown_0931H(359, 359, 772, 1, 357) --- Guess: Checks item in inventory
        switch_talk_to(101, 0)
        if not get_flag(340) then
            if not var_0000 then
                add_dialogue("The creature ignores you.")
                abort()
            end
            unknown_08DFH() --- Guess: Interacts with Emp leader
        end
        if not get_flag(319) then
            if not get_flag(316) then
                add_dialogue("You see a wizened female ape-like creature.")
                set_flag(316, true)
            else
                add_dialogue("You see a wizened female Emp.")
            end
            set_flag(319, true)
        else
            add_dialogue("\"You are hailed, human.\"")
        end
        if not get_flag(299) then
            add_answer("Trellek")
        end
        add_answer({"bye", "job", "name"})
        while true do
            var_0001 = get_answer()
            if var_0001 == "name" then
                add_dialogue("\"I am Salamon,\" she says.")
                remove_answer("name")
            elseif var_0001 == "job" then
                add_dialogue("\"I am without job. All Emps are without jobs. Food gathering and shelter-building are Emp jobs.\"")
                if not get_flag(305) then
                    add_dialogue("She gives you a hard look.")
                    add_dialogue("\"There is a job for Trellek.\"")
                    set_flag(337, true)
                    add_answer("Trellek")
                end
                add_answer({"shelter-building", "food-gathering"})
            elseif var_0001 == "shelter-building" then
                add_dialogue("\"Silverleaf trees are where Emp's homes can be found.\"")
                remove_answer("shelter-building")
            elseif var_0001 == "food-gathering" then
                add_dialogue("\"Only fruits, vegetables, and milk-stuffs are eaten by Emps. Bread is also eaten.\"")
                remove_answer("food-gathering")
                add_answer({"-only-?", "bread", "milk-stuffs", "fruits and vegetables"})
            elseif var_0001 == "milk-stuffs" then
                add_dialogue("\"Milk and cheese and butter are milk-stuffs.\"")
                remove_answer("milk-stuffs")
            elseif var_0001 == "bread" then
                add_dialogue("\"Bread is hard to make for Emps. No stoves or ovens are owned by Emps. But bread is well liked.\"")
                remove_answer("bread")
            elseif var_0001 == "fruits and vegetables" then
                add_dialogue("\"Fruits and vegetables are our favorites. Many are sweet.\"")
                remove_answer("fruits and vegetables")
                add_answer("sweet")
            elseif var_0001 == "sweet" then
                add_dialogue("\"Sweet things are desired by Emps. Honey is sweetest! More honey is had by you?\"")
                var_0001 = select_option()
                if var_0001 then
                    add_dialogue("Her eyes widen and her lips part around a very large and hopeful smile.")
                    add_dialogue("\"More honey will be given by you?\"")
                    var_0002 = select_option()
                    if var_0002 then
                        var_0003 = unknown_0931H(359, 359, 772, 1, 357) --- Guess: Checks item in inventory
                        if var_0003 then
                            add_dialogue("\"You are thanked,\" she says, taking the honey.")
                        else
                            add_dialogue("\"A mean trick was played by you,\" she says, frowning.")
                            abort()
                        end
                    else
                        add_dialogue("She seems surprised, but quickly recovers.")
                        add_dialogue("\"Your feelings are understood by me,\" she sighs.")
                    end
                else
                    add_dialogue("She sighs, obviously disappointed.")
                end
                remove_answer("sweet")
            elseif var_0001 == "-only-?" then
                add_dialogue("\"No dead animal flesh -- what is called `meat' by humans -- is eaten by an Emp.\"")
                add_answer({"meat", "dead animal flesh"})
                remove_answer("-only-?")
            elseif var_0001 == "meat" then
                add_dialogue("\"Meat is without a good taste,\" she shudders. \"It is not preferred!\"")
                remove_answer("meat")
            elseif var_0001 == "dead animal flesh" then
                add_dialogue("\"All violence is abhorred by Emps. No killing is desired, even for what you humans call food.\"")
                remove_answer("dead animal flesh")
            elseif var_0001 == "Trellek" then
                if get_flag(304) then
                    if not get_flag(299) then
                        var_0004 = unknown_0931H(359, 3, 797, 1, 357) --- Guess: Checks item in inventory
                        if var_0004 then
                            add_dialogue("She takes the document from you, smiling when she sees Ben's signature. \"Trellek is permitted to join you. You are wished luck and speed.\"")
                            var_0005 = unknown_002BH(false, 359, 3, 797, 1) --- Guess: Deducts item and adds item
                            set_flag(305, true)
                        else
                            add_dialogue("\"The signed contract must be seen by me.\"")
                        end
                    else
                        add_dialogue("\"Permission will be given to you later. There is a task that must be performed first.\"")
                        add_dialogue("\"There is a woodcutter who lives in the western part of the forest. Silverleaf trees are being cut down by him. Emp houses are in Silverleaf trees. Contract must be signed by woodcutter to stop.\"")
                        if not get_flag(298) then
                            add_dialogue("\"My condition is understood by you?\" Not waiting for your response, she hands you a document.")
                            var_0006 = unknown_002CH(false, 359, 3, 797, 1) --- Guess: Checks inventory space
                            if var_0006 then
                                add_dialogue("\"You are now in possession of the contract.\"")
                                set_flag(298, true)
                            else
                                add_dialogue("\"There is not enough room in your equipment for the contract.\"")
                            end
                        end
                    end
                else
                    add_dialogue("\"Trellek is another Emp. He should be spoken to by you.\"")
                    add_dialogue("\"There is much damage to the forest and the Silverleaf trees. The damage is caused by your people, human. The responsibility to reverse the damage is also yours, human.\"")
                    add_dialogue("\"Trellek should be sought by you,\" she says emphatically. \"He should be asked to join you.\"")
                end
                remove_answer("Trellek")
            elseif var_0001 == "bye" then
                break
            end
        end
        add_dialogue("\"My hope is for your welfare, human.\"")
    elseif eventid == 0 then
        var_0007 = unknown_001CH(101) --- Guess: Gets object state
        if var_0007 == 11 and var_0000 then
            var_0008 = random(1, 4)
            if var_0008 == 1 then
                var_0009 = "@You are greeted.@"
            elseif var_0008 == 2 then
                var_0009 = "@Nature is home to many.@"
            elseif var_0008 == 3 then
                var_0009 = "@A good day is hoped for you.@"
            elseif var_0008 == 4 then
                var_0009 = "@Nature is wise.@"
            end
            bark(101, var_0009)
        end
    end
end