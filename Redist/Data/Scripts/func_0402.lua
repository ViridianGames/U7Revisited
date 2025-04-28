require "U7LuaFuncs"
-- Manages Spark's dialogue in Trinsic, covering his father's murder, chest contents, and joining the Avatar to seek vengeance.

-- Global variables for answer handling, similar to erethian_inline.lua
answers = answers or {}
answer = answer or nil

function func_0402(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9
    local local10, local11, local12, local13, local14, local15, local16, local17, local18

    if eventid == 1 then
        local0 = get_player_name()
        local1 = "Avatar"
        local2 = get_party_members()
        local3 = is_player_female()
        local4 = switch_talk_to(-2)
        local5 = false
        local6 = false
        local7 = false

        if not get_flag(21) then
            switch_talk_to(-2, 1)
        elseif is_party_member(local4, local2) then
            switch_talk_to(-2, 0)
        else
            switch_talk_to(-2, 1)
        end

        if not get_flag(70) then
            local8 = local0
        end
        if not get_flag(71) then
            local8 = local1
        end
        local9 = get_player_name()

        if not get_flag(21) then
            -- Initial dialogue
            if not answer then
                say("You see a boy who appears to be a young teen. He is dirty and unkempt. He looks as if he has been crying, but he sits up straight and looks sharp when he sees you.")
                say("\"Who art thou and what dost thou want?\" You realize the boy has a sling in hand.")
                say("You face the boy and tell him who you are.")
                add_answer({local1, local0});
                answer = get_answer(answers)
                return
            elseif answer == local0 then
                say("\"So? What makes thee so special?\"*")
                local8 = local0
                set_flag(70, true)
            elseif answer == local1 then
                say("\"The last time I heard -that- one I fell off a prehistoric creature from Eodon!\"")
                local8 = local1
                set_flag(71, true)
            else
                -- Invalid answer, reset and return
                answers = {}
                answer = nil
                return
            end
            local11 = get_item_type(-1)
            if local11 then
                switch_talk_to(-1, 0)
                say("\"Boy, this is the Avatar! " .. (local3 and "Upon my word she is! She has come to help thee!\"*" or "Upon my word he is! He has come to help thee!\"*"))
                hide_npc(-1)
                switch_talk_to(-2, 1)
            end
            say("Then the boy narrows his eyes, studying you. He slows his weapon, ready to act in case it's a trap. You admire the boy's obvious experience in dealing with strangers.")
            say("You and Spark stare at each other. He is not sure what to do. Finally, he nods his head. \"All right. I believe thee. Thou dost look like paintings I have seen. I am sorry, " .. local9 .. ".\"")
            set_flag(21, true)
        else
            -- Subsequent dialogue
            if not answer then
                say("\"Yes, " .. local8 .. "?\" Spark asks. \"What dost thou want?\"")
                answers = {}
                add_answer({"bye", "murder", "job", "name"})
                if not get_flag(72) then
                    add_answer("key")
                end
                if not get_flag(62) then
                    remove_answer("key")
                end
                if is_party_member(local4, local2) then
                    add_answer("leave")
                end
                if not get_flag(73) and not is_party_member(local4, local2) then
                    add_answer("join")
                end
                if not get_flag(62) and not get_flag(100) then
                    add_answer({"scroll", "medallion", "gold"})
                end
                answer = get_answer()
                return
            end
        end

        -- Process answer in a single pass, like erethian_inline.lua
        if answer == "name" then
            say("\"I have always been called Spark.\"")
            remove_answer("name")
        elseif answer == "job" then
            say("\"I have no job. I am only fourteen, so I am just learning how to best help Father in the smithy,\" he says, proudly. But then he suddenly realizes something which terrifies him. \"And now that Father is dead, I am an orphan!\"")
            add_answer({"orphan", "Father", "smithy"})
        elseif answer == "smithy" then
            say("\"Father was the best blacksmith in Britannia. People were always coming from everywhere to get him to make this and that.\"")
            remove_answer("smithy")
        elseif answer == "orphan" then
            say("\"My mother died a long time ago. I can just barely remember her.\"")
            remove_answer("orphan")
        elseif answer == "murder" then
            if not get_flag(67) then
                say("\"I cannot believe Father is dead. And poor Inamo, too. It is so strange. I -dreamed- it was happening. Well, in a way.~~\"Last night I was having a nightmare about Father. I dreamed that he screamed, and it woke me up. I looked around the house, but he was not in his bed. I was wide awake, so I went out to find him.\"")
                add_answer({"find", "nightmare", "Inamo"})
            else
                say("\"I am sure thou canst find the man who killed Father!\"")
                say("\"Dost thou want me to repeat everything I know about the murder?\"")
                if not get_item_type() then
                    say("\"What dost thou want to know about?\"")
                    add_answer({"chest", "key", "my story"})
                else
                    say("\"All right.\"")
                end
            end
            remove_answer("murder")
        elseif answer == "chest" then
            if not get_flag(62) then
                say("\"I am not sure if it's the same one, but I think I saw Father with a scroll just like the one in the chest one or two days ago. I know he was making something special for someone. I am fairly certain it was at his shop. As for the medallion, he usually wore it. I do not know why it was in the chest. And the gold-- I have never seen so much gold in my life. I cannot imagine why father had it.\"")
            else
                say("\"Thou shouldst try opening the chest.\"")
            end
            remove_answer("chest")
        elseif answer == "my story" then
            say("\"It is so strange. I -dreamed- it was happening. Well, in a way.~~\"Last night I was having a nightmare about Father. I dreamed that he screamed, and it woke me up. I looked around the house, but he was not in his bed. I was wide awake, so I went out to find him.\"")
            remove_answer("my story")
            add_answer({"nightmare", "find"})
        elseif answer == "nightmare" then
            say("\"I know it sounds witless, but... I dreamed that a big red-faced man was watching down on everything and... He looked down... And he noticed Father... That is all I remember.\"")
            remove_answer("nightmare")
        elseif answer == "find" then
            say("\"No, I did not find him. At least, not right away. But I did see something.\"")
            add_answer("something")
            remove_answer("find")
        elseif answer == "something" then
            say("\"I was in front of the stables. I saw a man and a wingless gargoyle running from behind the building. They ran toward the dock. Then I went inside and found... Father.\"~~Spark's voice falters, and he begins to sob a little.")
            add_answer({"gargoyle", "man"})
            remove_answer("something")
        elseif answer == "man" then
            say("\"All I saw of him was that the man had a hook for a right hand.\"")
            add_answer("hook")
            remove_answer("man")
        elseif answer == "gargoyle" then
            say("\"I cannot tell one gargoyle from another. I could not identify him, except that he had no wings.\"")
            remove_answer("gargoyle")
        elseif answer == "hook" then
            if not get_flag(67) then
                if not is_party_member(local4, local2) then
                    say("\"Wilt thou go find the Man with the Hook? Let me help thee!\" the boy pleads. His tears cease, and his face takes on a determined, forceful look.")
                    set_flag(67, true)
                    say("\"Take me with thee! Please! I must avenge Father's death! If thou dost not take me with thee, I will follow thee anyway!\"")
                    say("The boy is all excited now. \"I am an expert with a slingshot! I can strike sewer rats with almost every shot! And I am small -- I do not eat much! Please take me! Please ask me to join thee!\"*")
                    local11 = get_item_type(-1)
                    if local11 then
                        switch_talk_to(-1, 0)
                        say("Iolo whispers to you. \"I do not know about taking a child on the road with us, " .. local9 .. ".\"*")
                        hide_npc(-1)
                        switch_talk_to(-2, 1)
                        say("Suddenly, Spark lets his sling fly. His target, a small fly hovering above Iolo's head, is smacked out of the air. You laugh as Iolo yelps, jumps away, curses and runs his fingers through his hair.")
                        apply_effect(1) -- Unmapped intrinsic 000F
                    else
                        say("Suddenly, Spark lets his sling fly. His target, a small fly hovering above your head, is smacked out of the air.")
                    end
                    say("\"I told thee I am good! May I join?\"")
                    local12 = get_item_type()
                    if local12 then
                        hide_npc(-2)
                        switch_talk_to(-2, 0)
                        say("\"Hooray!\" the boy leaps with delight.")
                        add_answer("leave")
                        switch_talk_to(-2)
                    else
                        say("\"Fine.\" The boy looks angry. \"But I'll follow thee anyway.\"")
                        add_answer("leave")
                        switch_talk_to(-2)
                    end
                    set_flag(73, true)
                else
                    say("\"I know thou wilt find that man.\"")
                end
            else
                say("\"I know thou wilt find that man.\"")
            end
            remove_answer("hook")
        elseif answer == "join" then
            say("\"'Tis about time thou didst ask again!\"")
            local13 = 0
            while local13 < 8 do
                local13 = local13 + 1
            end
            if local13 >= 8 then
                hide_npc(-2)
                switch_talk_to(-2, 0)
                say("\"Hooray!\"")
            else
                say("\"Well, on second thought, it looks like too big of a crowd. I do not like crowds.\"")
            end
            remove_answer("join")
            add_answer("leave")
        elseif answer == "leave" then
            say("\"Don't make me go!\" Spark cries. \"Dost thou really want me to go?\" He looks at you with puppy-dog eyes.")
            local17 = get_item_type()
            if local17 then
                hide_npc(-2)
                switch_talk_to(-2, 1)
                say("\"Well, should I just wait here or dost thou want me to go home to Trinsic?\"")
                answers = {"go home", "wait here"}
                answer = nil
                return
            else
                say("\"Thou wilt not be sorry!\"")
            end
        elseif answer == "go home" then
            say("Spark bows his head and murmurs, \"Goodbye, then.\"*")
            switch_talk_to(-2, 11)
            answers = {}
            answer = nil
            return
        elseif answer == "wait here" then
            say("\"All right. I shall wait here until thou dost return and ask me to rejoin.\"*")
            switch_talk_to(-2, 15)
            answers = {}
            answer = nil
            return
        elseif answer == "Father" then
            say("\"Father was the blacksmith. I cannot believe that he has been murdered! He had no enemies that I know of. Unless it was The Fellowship.\"")
            add_answer("Fellowship")
            remove_answer("Father")
        elseif answer == "Fellowship" then
            say("\"Well, at first they harassed Father and me when they came around asking us to join. I suppose they do good things. Many people like them. Father eventually joined the group after he went to Britain and took one of their tests.\"")
            add_answer("tests")
            set_flag(63, true)
            remove_answer("Fellowship")
        elseif answer == "tests" then
            say("\"I do not know anything about them. I never took one. Maybe thou shouldst ask the man at the Fellowship Branch. Klog.\"")
            add_answer({"Klog", "branch"})
            remove_answer("tests")
        elseif answer == "branch" then
            say("\"The Fellowship has branches all over Britannia.\"")
            remove_answer("branch")
        elseif answer == "Klog" then
            say("\"He is the head of the Fellowship Branch here in Trinsic. He and Father got into an argument a week ago when Klog and two of his friends came over to talk with Father.\"")
            add_answer({"friends", "argument"})
            remove_answer("Klog")
        elseif answer == "argument" then
            say("\"I don't know what it was about. Perhaps thou shouldst ask Klog.\"")
            remove_answer("argument")
        elseif answer == "friends" then
            say("\"I do not remember what they look like. I did not recognize them. They were most likely some other members of The Fellowship.\"")
            remove_answer("friends")
        elseif answer == "key" then
            if not get_flag(62) then
                say("\"That key opened my Father's chest, did it not?\"")
            elseif has_item(-359, 253, 641, 1, -357) then
                say("\"That looks like the key to Father's chest. I wondered where it was!\"")
            else
                say("\"What key? Dost thou have the key to Father's chest? Where is it?\"")
            end
            remove_answer("key")
        elseif answer == "gold" then
            say("The boy's eyes widen. \"I had no idea that Father had that much money hidden away!\"")
            say("\"I suppose I could give it to thee if thou art going to look for those who killed my Father!\"")
            remove_answer("gold")
            local6 = true
        elseif answer == "medallion" then
            say("\"Father was a member of The Fellowship. I don't know why the medallion was in the chest -- he usually wore it.\"")
            remove_answer("medallion")
            local7 = true
        elseif answer == "scroll" then
            say("\"I am not sure if it's the same one, but I think I saw Father with a scroll just like that one or two days ago. I know he was making something special for someone. I am fairly certain it was at his shop.\"")
            add_answer("shop")
            remove_answer("scroll")
            local5 = true
        elseif answer == "shop" then
            say("\"It's in the southwest corner of town.\"")
            remove_answer("shop")
        elseif answer == "Inamo" then
            say("\"He was a very nice gargoyle. He helped Father a lot and did tasks in the stables. I cannot think why anyone would want to kill him!\"")
            remove_answer("Inamo")
        elseif answer == "bye" then
            say("\"All right, I will speak with thee later.\"*")
            answers = {}
            answer = nil
            return
        end

        -- Update flag 100 if all chest items discussed
        if local5 and local6 and local7 then
            set_flag(100, true)
        end

        -- Clear answer if not handled, allow next call to prompt again
        answer = nil
        return
    end

    if eventid == 0 then
        answers = {}
        answer = nil
        return
    end
    return
end