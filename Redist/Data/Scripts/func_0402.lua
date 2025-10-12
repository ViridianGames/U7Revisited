--- Best guess: Handles dialogue with Spark in Trinsic, discussing his father’s murder, clues, and his desire to join the party to seek justice.
function func_0402(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011, var_0012

    start_conversation()
    if eventid == 1 then
        var_0000 = get_player_name()
        var_0001 = "Avatar"
        var_0002 = get_party_members()
        var_0003 = is_player_female()
        var_0004 = get_npc_name_from_id(2) --- Guess: Retrieves object reference from ID
        var_0005 = false
        var_0006 = false
        var_0007 = false
        if not get_flag(21) then
            switch_talk_to(2, 1)
        elseif npc_id_in_party(2) then
            switch_talk_to(2, 0)
        else
            switch_talk_to(2, 1)
        end
        if get_flag(70) then
            var_0008 = var_0000
        end
        if get_flag(71) then
            var_0008 = var_0001
        end
        var_0009 = get_lord_or_lady()
        if not get_flag(21) then
            add_dialogue("You see a boy who appears to be a young teen. He is dirty and unkempt.")
            add_dialogue("He looks as if he has been crying, but he sits up straight and looks sharp when he sees you.")
            add_dialogue("\"Who art thou and what dost thou want?\" You realize the boy has a sling in hand.")
            var_000A = ask_multiple_choice({"You face the boy and tell him who you are.", var_0001, var_0000})
            if var_000A == var_0000 then
                add_dialogue("\"So? What makes thee so special?\"")
                var_0008 = var_0000
                set_flag(70, true)
            else
                add_dialogue("\"The last time I heard -that- one I fell off a prehistoric creature from Eodon!\"")
                var_0008 = var_0001
                set_flag(71, true)
            end
            var_000B = npc_id_in_party(1)
            if var_000B then
                second_speaker(1, 0, "\"Boy, this is the Avatar! ")
                second_speaker(1, 0, var_0003 and "Upon my word she is! She has come to help thee!\"" or "Upon my word he is! He has come to help thee!\"")
            end
            add_dialogue("Then the boy narrows his eyes, studying you. He slowly lowers his weapon, ready to act in case it's a trap. You admire the boy's obvious experience in dealing with strangers.")
            add_dialogue("You and Spark stare at each other. He is not sure what to do. Finally, he nods his head. \"All right. I believe thee. Thou dost look like paintings I have seen. I am sorry, " .. var_0009 .. ".\"")
            set_flag(21, true)
        else
            add_dialogue("\"Yes, " .. var_0008 .. "?\" Spark asks. \"What dost thou want?\"")
        end
        add_answer({"bye", "murder", "job", "name"})
        if get_flag(72) then
            add_answer("key")
        end
        if get_flag(62) then
            remove_answer("key")
        end
        if npc_id_in_party(2) then
            add_answer("leave")
        end
        if get_flag(73) and not npc_id_in_party(2) then
            add_answer("join")
        end
        if get_flag(62) and not get_flag(100) then
            add_answer({"scroll", "medallion", "gold"})
        end
        while true do
            coroutine.yield()
            var_000C = get_answer()
            if var_000C == "name" then
                add_dialogue("\"I have always been called Spark.\"")
                remove_answer("name")
            elseif var_000C == "job" then
                add_dialogue("\"I have no job. I am only fourteen, so I am just learning how to best help Father in the smithy,\" he says, proudly.")
                add_dialogue("But then he suddenly realizes something which terrifies him. \"And now that Father is dead, I am an orphan!\"")
                add_answer({"orphan", "Father", "smithy"})
            elseif var_000C == "smithy" then
                add_dialogue("\"Father was the best blacksmith in Britannia. People were always coming from everywhere to get him to make this and that.\"")
                remove_answer("smithy")
            elseif var_000C == "orphan" then
                add_dialogue("\"My mother died a long time ago. I can just barely remember her.\"")
                remove_answer("orphan")
            elseif var_000C == "murder" then
                if not get_flag(67) then
                    add_dialogue("\"I cannot believe Father is dead. And poor Inamo, too. It is so strange. I -dreamed- it was happening. Well, in a way.")
                    add_dialogue("\"Last night I was having a nightmare about Father. I dreamed that he screamed, and it woke me up.")
                    add_dialogue("I looked around the house, but he was not in his bed. I was wide awake, so I went out to find him.\"")
                    add_answer({"find", "nightmare", "Inamo"})
                else
                    add_dialogue("\"I am sure thou canst find the man who killed Father!\"")
                    add_dialogue("\"Dost thou want me to repeat everything I know about the murder?\"")
                    if ask_yes_no() then
                        ask_multple_choice("\"What dost thou want to know about?\"", {"chest", "key", "my story"})
                    else
                        add_dialogue("\"All right.\"")
                    end
                end
                remove_answer("murder")
            elseif var_000C == "chest" then
                if get_flag(62) then
                    add_dialogue("\"I am not sure if it's the same one, but I think I saw Father with a scroll just like the one in the chest one or two days ago. I know he was making something special for someone. I am fairly certain it was at his shop. As for the medallion, he usually wore it. I do not know why it was in the chest. And the gold-- I have never seen so much gold in my life. I cannot imagine why father had it.\"")
                else
                    add_dialogue("\"Thou shouldst try opening the chest.\"")
                end
                remove_answer("chest")
            elseif var_000C == "my story" then
                add_dialogue("\"It is so strange. I -dreamed- it was happening. Well, in a way.")
                add_dialogue("\"Last night I was having a nightmare about Father. I dreamed that he screamed, and it woke me up. I looked around the house, but he was not in his bed. I was wide awake, so I went out to find him.\"")
                remove_answer("my story")
                add_answer({"nightmare", "find"})
            elseif var_000C == "nightmare" then
                add_dialogue("\"I know it sounds witless, but... I dreamed that a big red-faced man was watching down on everything and... He looked down... And he noticed Father... That is all I remember.\"")
                remove_answer("nightmare")
            elseif var_000C == "find" then
                add_dialogue("\"No, I did not find him. At least, not right away. But I did see something.\"")
                add_answer("something")
                remove_answer("find")
            elseif var_000C == "something" then
                add_dialogue("\"I was in front of the stables. I saw a man and a wingless gargoyle running from behind the building. They ran toward the dock.")
                add_dialogue("Then I went inside and found... Father.\"")
                add_dialogue("Spark's voice falters, and he begins to sob a little.")
                add_answer({"gargoyle", "man"})
                remove_answer("something")
            elseif var_000C == "man" then
                add_dialogue("\"All I saw of him was that the man had a hook for a right hand.\"")
                add_answer("hook")
                remove_answer("man")
            elseif var_000C == "gargoyle" then
                add_dialogue("\"I cannot tell one gargoyle from another. I could not identify him, except that he had no wings.\"")
                remove_answer("gargoyle")
            elseif var_000C == "hook" then
                if not get_flag(67) then
                    if not npc_id_in_party(2) then
                        add_dialogue("\"Wilt thou go find the Man with the Hook? Let me help thee!\" the boy pleads. His tears cease, and his face takes on a determined, forceful look.")
                        set_flag(67, true)
                        add_dialogue("\"Take me with thee! Please! I must avenge Father's death! If thou dost not take me with thee, I will follow thee anyway!\"")
                        add_dialogue("The boy is all excited now. \"I am an expert with a slingshot! I can strike sewer rats with almost every shot! And I am small -- I do not eat much! Please take me! Please ask me to join thee!\"")
                        var_000B = npc_id_in_party(1)
                        if var_000B then
                            second_speaker(1, 0, "Iolo whispers to you. \"I do not know about taking a child on the road with us, " .. var_0009 .. ".\"")
                            add_dialogue("Suddenly, Spark lets his sling fly. His target, a small fly hovering above Iolo's head, is smacked out of the air.")
                            add_dialogue("You laugh as Iolo yelps, jumps away, curses and runs his fingers through his hair.")
                            --unknown_000FH(1) -- Plays a sound effect
                        else
                            add_dialogue("Suddenly, Spark lets his sling fly. His target, a small fly hovering above your head, is smacked out of the air.")
                        end
                        var_000C = ask_yes_no("\"I told thee I am good! May I join?\"")
                        if var_000C then
                            switch_talk_to(2, 0)
                            add_dialogue("\"Hooray!\" the boy leaps with delight.")
                            add_answer("leave")
                            add_to_party(2)
                        else
                            add_dialogue("\"Fine.\" The boy looks angry. \"But I'll follow thee anyway.\"")
                            add_to_party(2)
                            add_answer("leave")
                        end
                        set_flag(73, true)
                    else
                        add_dialogue("\"I know thou wilt find that man.\"")
                    end
                else
                    add_dialogue("\"I know thou wilt find that man.\"")
                end
                remove_answer("hook")
            elseif var_000C == "join" then
                add_dialogue("\"'Tis about time thou didst ask again!\"")
                var_000D = 0
                for var_000E = 1, 8 do
                    var_000D = var_000D + 1
                end
                if var_000D < 8 then
                    add_dialogue("\"Well, on second thought, it looks like too big of a crowd. I do not like crowds.\"")
                else
                    hide_npc(2)
                    switch_talk_to(2, 0)
                    add_dialogue("\"Hooray!\"")
                    remove_answer("join")
                    add_answer("leave")
                    unknown_001EH(2) --- Guess: Removes object from game
                end
            elseif var_000C == "leave" then
                var_0011 = ask_yes_no("\"Don't make me go!\" Spark cries. \"Dost thou really want me to go?\" He looks at you with puppy-dog eyes.")
                if var_0011 then
                    hide_npc(2)
                    switch_talk_to(2, 1)
                    add_dialogue("\"Well, should I just wait here or dost thou want me to go home to Trinsic?\"")
                    save_answers()
                    var_000A = ask_answer({"go home", "wait here"})
                    if var_000A == "wait here" then
                        add_dialogue("\"All right. I shall wait here until thou dost return and ask me to rejoin.\"")
                        unknown_001FH(2) --- Guess: Sets object state (e.g., active/inactive)
                        unknown_001DH(15, 2) --- Guess: Sets a generic object property
                        abort()
                    else
                        add_dialogue("Spark bows his head and murmurs, \"Goodbye, then.\"")
                        unknown_001FH(2) --- Guess: Sets object state (e.g., active/inactive)
                        unknown_001DH(11, 2) --- Guess: Sets a generic object property
                        abort()
                    end
                else
                    add_dialogue("\"Thou wilt not be sorry!\"")
                end
            elseif var_000C == "Father" then
                add_dialogue("\"Father was the blacksmith. I cannot believe that he has been murdered! He had no enemies that I know of. Unless it was The Fellowship.\"")
                add_answer("Fellowship")
                remove_answer("Father")
            elseif var_000C == "Fellowship" then
                add_dialogue("\"Well, at first they harassed Father and me when they came around asking us to join. I suppose they do good things. Many people like them. Father eventually joined the group after he went to Britain and took one of their tests.\"")
                add_answer("tests")
                set_flag(63, true)
                remove_answer("Fellowship")
            elseif var_000C == "tests" then
                add_dialogue("\"I do not know anything about them. I never took one. Maybe thou shouldst ask the man at the Fellowship Branch. Klog.\"")
                add_answer({"Klog", "branch"})
                remove_answer("tests")
            elseif var_000C == "branch" then
                add_dialogue("\"The Fellowship has branches all over Britannia.\"")
                remove_answer("branch")
            elseif var_000C == "Klog" then
                add_dialogue("\"He is the head of the Fellowship Branch here in Trinsic. He and Father got into an argument a week ago when Klog and two of his friends came over to talk with Father.\"")
                add_answer({"friends", "argument"})
                remove_answer("Klog")
            elseif var_000C == "argument" then
                add_dialogue("\"I don't know what it was about. Perhaps thou shouldst ask Klog.\"")
                remove_answer("argument")
            elseif var_000C == "friends" then
                add_dialogue("\"I do not remember what they look like. I did not recognize them. They were most likely some other members of The Fellowship.\"")
                remove_answer("friends")
            elseif var_000C == "key" then
                if get_flag(62) then
                    add_dialogue("\"That key opened my Father's chest, did it not?\"")
                else
                    var_0012 = is_object_in_npc_inventory(0, 641, 0, 253)
                    if var_0012 then
                        add_dialogue("\"That looks like the key to Father's chest. I wondered where it was!\"")
                    else
                        add_dialogue("\"What key? Dost thou have the key to Father's chest? Where is it?\"")
                    end
                end
                remove_answer("key")
            elseif var_000C == "gold" then
                add_dialogue("The boy's eyes widen. \"I had no idea that Father had that much money hidden away!\"")
                add_dialogue("\"I suppose I could give it to thee if thou art going to look for those who killed my Father!\"")
                remove_answer("gold")
                var_0006 = true
            elseif var_000C == "medallion" then
                add_dialogue("\"Father was a member of The Fellowship. I don't know why the medallion was in the chest -- he usually wore it.\"")
                remove_answer("medallion")
                var_0007 = true
            elseif var_000C == "scroll" then
                add_dialogue("\"I am not sure if it's the same one, but I think I saw Father with a scroll just like that one or two days ago. I know he was making something special for someone. I am fairly certain it was at his shop.\"")
                add_answer("shop")
                remove_answer("scroll")
                var_0005 = true
            elseif var_000C == "shop" then
                add_dialogue("\"It's in the southwest corner of town.\"")
                remove_answer("shop")
            elseif var_000C == "Inamo" then
                add_dialogue("\"He was a very nice gargoyle. He helped Father a lot and did tasks in the stables. I cannot think why anyone would want to kill him!\"")
                remove_answer("Inamo")
            elseif var_000C == "bye" then
                clear_answers()
                break
            end
        end
        add_dialogue("\"All right, I will speak with thee later.\"")
        if var_0005 and var_0006 and var_0007 then
            set_flag(100, true)
        end
    elseif eventid == 0 then
        abort()
    end
end