--- Best guess: Manages dialogue with Brita, who runs the Fellowship shelter in Paws, covering her role, Feridwyn’s dedication, and the venom theft involving her son Garritt.
function func_04A8(eventid, objectref, arg1)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 1 then
        start_conversation()
        switch_talk_to(0, 168) --- Guess: Switches dialogue target
        var_0000 = get_lord_or_lady() --- External call to get lord or lady title
        add_answer({"bye", "job", "name"}) --- Guess: Adds dialogue options
        if get_flag(532) and not get_flag(536) then
            add_answer("thief") --- Guess: Adds dialogue option
        end
        if not get_flag(536) then
            add_answer("venom found") --- Guess: Adds dialogue option
        end
        var_0001 = check_object_conditions(1, 359, 649, 1, 357) --- External call to check item conditions
        if var_0001 then
            add_answer("venom found") --- Guess: Adds dialogue option
        end
        if not get_flag(545) then
            add_dialogue("@A stern-looking woman stares back at you without humor.@")
            set_flag(545, true)
        else
            add_dialogue("@Greetings to thee, " .. var_0000 .. ",\" you hear Brita say.@")
        end
        while true do
            var_0003 = get_answer() --- Guess: Gets conversation answer
            if var_0003 == "name" then
                add_dialogue("@I am Brita.@")
                remove_answer("name") --- Guess: Removes dialogue option
            elseif var_0003 == "job" then
                add_dialogue("@I help mine husband Feridwyn run The Fellowship's shelter in Paws.@")
                add_answer({"Paws", "shelter", "Fellowship", "Feridwyn"}) --- Guess: Adds dialogue options
            elseif var_0003 == "Feridwyn" then
                if not get_flag(537) then
                    add_dialogue("@Mine husband is a good man who devotes himself selflessly to helping the poor of this town, something they do not appreciate. He is a good man and a dutiful Fellowship member.@")
                else
                    add_dialogue("@Mine husband is the most honorable man I have ever met in my life.@")
                    var_0002 = check_dialogue_target(167) --- Guess: Checks dialogue target
                    if var_0002 then
                        switch_talk_to(0, 167) --- Guess: Switches dialogue target
                        bark(167, "@Do not put stock in the proud boasts of wives, good Avatar. I am a simple man who only does what he can.@")
                        hide_npc(167) --- Guess: Hides NPC
                        switch_talk_to(0, 168) --- Guess: Switches dialogue target
                    end
                end
                remove_answer("Feridwyn") --- Guess: Removes dialogue option
            elseif var_0003 == "Fellowship" then
                if not get_flag(6) then
                    add_dialogue("@Thou shouldst speak to mine husband of The Fellowship. I am certain thou wilt be most impressed by what he shall have to tell thee.@")
                else
                    add_dialogue("@Seeing that thou hast joined The Fellowship only confirms what I already know. That The Fellowship is the path by which we shall lead Britannia to a wonderful new future. News that thou hast joined us is spreading far and wide!@")
                end
                remove_answer("Fellowship") --- Guess: Removes dialogue option
            elseif var_0003 == "shelter" then
                add_dialogue("@Running the shelter is hard work for mine husband and me, but it is worth the effort to ease the suffering of those less fortunate than we.@")
                remove_answer("shelter") --- Guess: Removes dialogue option
            elseif var_0003 == "Paws" then
                add_dialogue("@We hear about everything that goes on in Paws. If I do not know about it then mine husband does. Is there anyone in particular thou dost wish to know about?@")
                var_0003 = get_dialogue_choice() --- Guess: Gets dialogue choice
                if var_0003 then
                    add_dialogue("@I know about these people:@")
                    add_answer({"Polly", "Camille", "Alina"}) --- Guess: Adds dialogue options
                else
                    add_dialogue("@It is good to determine an impression of others on one's own.@")
                end
                remove_answer("Paws") --- Guess: Removes dialogue option
            elseif var_0003 == "Alina" then
                add_dialogue("@Alina lives in the shelter with her baby, poor thing. Her husband is a common thief who even now sits in prison. But we shall help her get her life straightened out once we persuade her to join The Fellowship. She is not smart enough, thou knowest, to see the advantages for herself. She must be carefully instructed.@")
                remove_answer("Alina") --- Guess: Removes dialogue option
            elseif var_0003 == "Camille" then
                add_dialogue("@Camille is a farm widow. She tends to live in the past, following the old virtues and questioning the ways of The Fellowship. These country folk are so superstitious, thou knowest. It is a fault of their low intellect. She does not even notice what a hooligan her boy, Tobias, is growing up to be! Not at all like our son, Garritt.@")
                add_answer({"Garritt", "Tobias"}) --- Guess: Adds dialogue options
                remove_answer("Camille") --- Guess: Removes dialogue option
            elseif var_0003 == "Tobias" then
                add_dialogue("@A simply wretched little urchin. Always sulking. But then, one must realize that he has no father to discipline him properly.@")
                remove_answer("Tobias") --- Guess: Removes dialogue option
            elseif var_0003 == "venom found" then
                if not get_flag(536) then
                    add_dialogue("@Thou dost say that vial of venom was found in Garritt's belongings? I do not believe it! Art thou saying my son is a liar and a thief? I wilt not believe it! Good day to thee!@")
                    abort() --- Guess: Aborts script
                else
                    add_dialogue("@So Garritt admits he stole the venom vial. I cannot believe it! I do not know what to say.@")
                    add_answer("Garritt") --- Guess: Adds dialogue option
                end
                remove_answer("venom found") --- Guess: Removes dialogue option
            elseif var_0003 == "Garritt" then
                if not get_flag(536) then
                    add_dialogue("Brita beams. \"Garritt is a wonderful son. He is being raised to follow the values of The Fellowship. His worthiness has been rewarded.\"")
                    add_answer("rewarded") --- Guess: Adds dialogue option
                else
                    add_dialogue("Brita frowns even more than before. \"If thou dost ask me, 'twas all a plot to get my little boy in trouble. If thou had not come to town, this entire incident would not have happened!\"")
                end
                remove_answer("Garritt") --- Guess: Removes dialogue option
            elseif var_0003 == "rewarded" then
                add_dialogue("@Garritt is so talented at the whistle panpipes! It is truly a gift!@")
                remove_answer("rewarded") --- Guess: Removes dialogue option
            elseif var_0003 == "Polly" then
                add_dialogue("@Polly runs the local tavern to be near people. She is a lonely soul and feels that there is simply no one who wishes for her heart. It makes me so sad to think of her. She could find all the companionship she could want if she would join The Fellowship.@")
                remove_answer("Polly") --- Guess: Removes dialogue option
            elseif var_0003 == "thief" then
                add_dialogue("@One of our members, a local merchant named Morfin, had a shipment of silver serpent venom stolen from him. Not that I care about the venom itself, but is it not shocking?@")
                set_flag(532, true)
                remove_answer("thief") --- Guess: Removes dialogue option
                add_answer("serpent venom") --- Guess: Adds dialogue option
            elseif var_0003 == "serpent venom" then
                add_dialogue("@I have never seen any myself. I have no idea what it does to someone, but it cannot possibly be good!@")
                remove_answer("serpent venom") --- Guess: Removes dialogue option
            elseif var_0003 == "bye" then
                add_dialogue("@Mayest thou walk with The Fellowship, Avatar.@")
                break
            end
        end
    elseif eventid == 0 then
        move_npc(168) --- External call to move NPC
    end
end