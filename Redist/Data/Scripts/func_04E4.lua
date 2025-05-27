--- Best guess: Manages Lucky’s dialogue in Buccaneer’s Den, a charismatic rogue offering training in deception and sharing insights on his worldly experiences.
function func_04E4(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 1 then
        switch_talk_to(0, 228)
        var_0000 = get_schedule()
        var_0001 = unknown_001CH(get_npc_name(228))
        start_conversation()
        add_answer({"bye", "job", "name"})
        if not get_flag(689) then
            add_dialogue("You see a man whose sinewy body is like steel. The glint in his eye tells you that he is no fool.")
            set_flag(689, true)
        else
            add_dialogue("\"What dost thou want with Lucky?\" the pirate asks.")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"I am Lucky... in all things.\"")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"I make my living off the world! It gives... and I take!\" The pirate laughs boisterously. \"I am a worldly gentleman, friends -- that is my 'job'! Oh, and I train initiates for a bit of pocket change.\"")
                add_answer({"train", "world"})
            elseif answer == "world" then
                add_dialogue("\"The ways of the world, is what I mean. I am a man of the road; I am a seasoned traveller. I travel through the world as a hundred different men.\"")
                add_answer({"different", "traveller"})
                remove_answer("world")
            elseif answer == "traveller" then
                add_dialogue("\"In truth there are few places where I have not been and little that I have not done.\"")
                remove_answer("traveller")
            elseif answer == "different" then
                add_dialogue("\"Thou canst be a different person just by assumption. 'Tis an attitude. I am an expert in the art of charismatic communication for the purposes of deception. It gives one many skills. For example, I can walk into any shop and make a purchase. But I will walk away with much more than I bought, for I know how to fool the shopkeeper. Little things like that.\"")
                remove_answer("different")
            elseif answer == "train" then
                if var_0001 == 7 then
                    add_dialogue("\"I charge 35 gold for a training session. Doth this meet with thine approval?\"")
                    if ask_yes_no() then
                        unknown_08B6H(35, 2)
                    else
                        add_dialogue("Lucky shrugs. \"Thou wilt not find another trainer on the island!\"")
                        remove_answer("train")
                    end
                else
                    add_dialogue("\"I shall be happy to show thee my ways of the world during normal business hours at my residence -- afternoons and evenings.\"")
                    remove_answer("train")
                end
            elseif answer == "bye" then
                add_dialogue("\"Be careful, my friend.\"")
                break
            end
        end
    elseif eventid == 0 then
        var_0001 = unknown_001CH(get_npc_name(228))
        if var_0001 == 11 then
            var_0002 = random2(4, 1)
            if var_0002 == 1 then
                var_0003 = "@Har!@"
            elseif var_0002 == 2 then
                var_0003 = "@Avast!@"
            elseif var_0002 == 3 then
                var_0003 = "@Blast!@"
            elseif var_0002 == 4 then
                var_0003 = "@Damn parrot droppings...@"
            end
            bark(var_0003, 228)
        else
            unknown_092EH(228)
        end
    end
    return
end