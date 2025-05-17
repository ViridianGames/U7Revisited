--- Best guess: Manages Finnigan’s dialogue, overseeing the Trinsic murder investigation, password, and town details, with flag-based progression.
function func_040C(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E

    if eventid ~= 1 then
        if eventid == 0 then
            var_000C = unknown_001CH(unknown_001BH(-12))
            var_000D = random2(4, 1)
            if var_000C == 11 then
                if var_000D == 1 then
                    var_000E = "@What a day...@"
                elseif var_000D == 2 then
                    var_000E = "@Another day, another gold coin...@"
                elseif var_000D == 3 then
                    var_000E = "@I shall search the area here...@"
                elseif var_000D == 4 then
                    var_000E = "@I am too old for this...@"
                end
                bark(var_000E, -12)
            else
                unknown_092EH(-12)
            end
        end
        add_dialogue("The Mayor nods his head at you and goes on about his business.")
        return
    end

    start_conversation()
    switch_talk_to(12, 0)
    var_0000 = get_lord_or_lady()
    var_0001 = get_player_name()
    var_0002 = get_flag(-1)
    var_0003 = is_player_female()
    if get_flag(90) and not get_flag(72) then
        add_dialogue("\"Hast thou properly searched the stables?\"")
        if unknown_090AH() then
            add_dialogue("\"What didst thou find?\"")
            unknown_0009H()
            var_0004 = {"a body", "a bucket", "nothing"}
            if not get_flag(60) then
                var_0004 = {"a body", "a bucket", "nothing", "a key"}
            end
            var_0005 = unknown_090BH(var_0004)
            if var_0005 == "a key" then
                if not var_0002 then
                    add_dialogue("\"Hmmm, a key. Perhaps if thou dost ask Christopher's son about it, he may know what it is for.\"")
                else
                    add_dialogue("\"Ask Spark about it. He may know something.\"")
                end
                set_flag(72, true)
            elseif var_0005 == "a body" then
                add_dialogue("\"I know that! What ELSE didst thou find? Thou shouldst look again, Avatar!\"")
                return
            elseif var_0005 == "a bucket" then
                add_dialogue("\"Yes, obviously it is filled with poor Christopher's own blood. But surely there was something else that might point us in the direction of the killer or killers - thou shouldst look again, Avatar.\"")
                return
            elseif var_0005 == "nothing" then
                add_dialogue("\"Thou shouldst look again, 'Avatar'!\"")
                return
            end
        else
            add_dialogue("\"Well, do so, then come speak with me!\"")
            return
        end
    elseif get_flag(89) then
        add_dialogue("\"Hmmm. Hast thou reconsidered mine offer to investigate the murder?\"")
        if unknown_090AH() then
            add_dialogue("\"Splendid. Then thou must really be the Avatar after all!\"")
            set_flag(89, false)
            unknown_0883H()
        else
            add_dialogue("\"Then leave our people to work it out for themselves.\"")
            unknown_0004H(-12)
            var_0006 = get_flag(-1)
            if not var_0006 then
                switch_talk_to(1, 0)
                add_dialogue("\"Avatar! I am ashamed of thee! Thou shouldst reconsider!\"")
                unknown_0004H(-1)
            end
            return
        end
    elseif not get_flag(76) then
        --unknown_005CH(objectref)
        --unknown_001DH(12, 11)
        add_dialogue("You see a middle-aged nobleman.")
        set_flag(76, true)
        var_0006 = get_flag(1)
        if not var_0006 then
            add_dialogue("\"Iolo! Who is this stranger?\"")
            switch_talk_to(1, 0)
            add_dialogue("\"Why, this is the Avatar!\" Iolo proudly proclaims. \"Canst thou believe it? May I introduce thee? This is Finnigan, the Town Mayor. And this is " .. var_0001 .. ", the Avatar!\"")
            if var_0003 then
                add_dialogue("\"I simply cannot believe she is here!\"")
            else
                add_dialogue("\"I simply cannot believe he is here!\"")
            end
            switch_talk_to(12, 0)
            add_dialogue("The Mayor looks you up and down, not sure if he believes Iolo or not. He looks at Iolo skeptically.")
            switch_talk_to(1, 0)
            add_dialogue("\"I swear to thee, it is the Avatar!\"")
            unknown_0004H(-1)
            switch_talk_to(12, 0)
        else
            add_dialogue("\"I have heard that thou art the Avatar. I am not certain that I believe it.")
        end
        add_dialogue("The mayor looks at you again as if he were studying every pore on your face. Finally, he smiles.")
        add_dialogue("\"Welcome, Avatar.\"")
        add_dialogue("But just as suddenly, Finnigan's face becomes stern.")
        add_dialogue("\"A horrible murder has occurred. If thou art truly the Avatar, perhaps thou canst help us solve it. I would feel better if thou takest this matter into thine hands. Thou shalt be handsomely rewarded if thou dost discover the name of the killer. Dost thou accept?\"")
        var_0005 = unknown_090AH()
        if var_0005 then
            var_0007 = get_flag(-11)
            if not var_0007 then
                add_dialogue("\"Petre here knows something about all of this.\"")
                switch_talk_to(11, 0)
                add_dialogue("The peasant interjects. \"I discovered poor Christopher and the Gargoyle Inamo early this morning.\"")
                unknown_0004H(-11)
            else
                switch_talk_to(12, 0)
                add_dialogue("\"Petre, the stables caretaker, discovered poor Christopher and Inamo early this morning.\"")
            end
            switch_talk_to(12, 0)
            add_dialogue("The Mayor continues. \"Hast thou searched the stables?\"")
            unknown_0885H()
        else
            add_dialogue("\"Well, thou could not be the real Avatar then!\"")
            set_flag(89, true)
            return
        end
    else
        add_dialogue("\"Yes, Avatar?\" Finnigan asks.")
    end
    add_answer({"bye", "murder", "job", "name"})
    if get_flag(91) then
        add_answer("report")
    end
    if not get_flag(63) then
        add_answer({"Klog", "Fellowship"})
    end
    if get_flag(66) and not get_flag(61) then
        add_answer("password")
    end
    if get_flag(69) and not get_flag(68) then
        add_answer("Pay me now, please")
    end
    while true do
        if cmps("name") then
            add_dialogue("\"My name is Finnigan.\"")
            remove_answer("name")
        elseif cmps("job") then
            add_dialogue("\"I am the Mayor of Trinsic and have been since I arrived here three years ago.\"")
            add_answer("Trinsic")
        elseif cmps("Trinsic") then
            var_0008 = var_0003 and "by one who claimed she was the Avatar." or "by one who claimed he was the Avatar."
            add_dialogue("\"Trinsic was once the city of Honor. I suppose it still is. Our Rune of Honor was taken many years ago " .. var_0008 .. " I believe it now resides in the Royal Museum in Britain, yet the empty pedestal still remains in the center of town. I feel this is symbolic of the town itself. It is rather empty -- of people, of life, and of honor. 'Tis sad, really.\"")
            add_dialogue("\"Then there is this murder, of course. We have temporarily closed the gates of the city and require a password to get in or out.\"")
            remove_answer("Trinsic")
            add_answer("password")
        elseif cmps("Pay me now, please") then
            add_dialogue("\"Of course, " .. var_0001 .. ". Here is thy gold.\"")
            var_0009 = unknown_002CH(true, 359, 359, 644, 100)
            if not var_0009 then
                add_dialogue("\"Oh, I am sorry, " .. var_0001 .. ". Thou still cannot carry this amount. Thou must return to me later.\"")
            else
                add_dialogue("\"Here thou art.\"")
                set_flag(69, false)
                set_flag(68, true)
            end
            remove_answer("Pay me now, please")
        elseif cmps("murder") then
            if not get_flag(61) then
                add_dialogue("\"A crime like this has never happened in Trinsic before. I cannot believe this happened to Christopher and Inamo. Please -- explore the town! I would appreciate it if thou wouldst bring me a report on thy progress. Be sure to ask everyone in town about the murder. After speaking with Christopher's son, thou mightest next want to speak with Gilberto, the guard on watch at the dock last night.\"")
                add_dialogue("The mayor63 hesitates, then leans in to speak quietly.")
                add_dialogue("\"Actually, I have seen something like this before. It was about four years ago, in Britain.\"")
                add_answer({"report", "Britain", "Inamo", "Christopher", "Gilberto"})
                set_flag(91, true)
                remove_answer("murder")
            else
                add_dialogue("\"I hope thou art progressing on the murder investigation.\"")
            end
        elseif cmps("Britain") then
            add_dialogue("\"'Twas before I came to Trinsic. There was a murder with strikingly similar aspects. A body was found mutilated exactly like poor Christopher. It appeared to be a ritualistic killing. I would wager that whoever was responsible for that murder is the culprit behind this one.\"")
            remove_answer("Britain")
        elseif cmps("son") then
            add_dialogue("\"Christopher's son is called Spark. Their house is in the northwest area of town.\"")
            remove_answer("son")
        elseif cmps("Gilberto") then
            add_dialogue("\"He was struck from behind early this morning and was knocked senseless. Johnson, the morning watch, found him unconscious. He is recuperating at Chantu the Healer's house on the west side of town.\"")
            remove_answer("Gilberto")
            add_answer({"Chantu", "Johnson"})
        elseif cmps("Chantu") then
            add_dialogue("\"He is our town healer. He hath been here for years. Nice fellow.\"")
            remove_answer("Chantu")
        elseif cmps("report") then
            if get_flag(68) then
                add_dialogue("\"I am satisfied with thy report. Please carry on thine investigation, Avatar.\"")
            elseif not get_flag(93) then
                add_dialogue("\"Art thou ready to answer some questions concerning the investigation?\"")
                var_000A = unknown_090AH()
                if var_000A then
                    set_flag(93, true)
                    unknown_0884H()
                else
                    add_dialogue("\"Oh. Well, carry on with thine investigation.\"")
                end
            else
                add_dialogue("\"Shall we continue thy report?\"")
                var_000B = unknown_090AH()
                if var_000B then
                    unknown_0884H()
                else
                    add_dialogue("\"Oh. Well, carry on with thine investigation.\"")
                end
            end
            remove_answer("report")
        elseif cmps("Fellowship") then
            add_dialogue("\"Why, they are an extremely helpful group. Their branch office is just east of mine. Very optimistic group of people.\"")
            remove_answer("Fellowship")
        elseif cmps("Klog") then
            add_dialogue("\"He is the Fellowship branch leader. Kind man.\"")
            remove_answer("Klog")
        elseif cmps("Johnson") then
            add_dialogue("\"He is probably at the dock right now.\"")
            remove_answer("Johnson")
        elseif cmps("Christopher") then
            add_dialogue("\"Christopher was the local blacksmith. He lives, or rather -lived-, with his son in the northwest part of town. The blacksmith's shop is in the southwest corner. Christopher was not a rich man by any means -- he barely kept himself and his son alive. But he certainly enjoyed his work.\"")
            remove_answer("Christopher")
            add_answer("son")
        elseif cmps("Inamo") then
            add_dialogue("\"The Gargoyle Inamo slept in the stables, as I understand it. I believe he emigrated here from Terfin a few months ago. It seems that he was merely a chance victim of someone intent on violence.\"")
            remove_answer("Inamo")
        elseif cmps("password") then
            if get_flag(68) and not get_flag(61) then
                add_dialogue("\"Oh, dost thou want the password now?\"")
                if unknown_090AH() then
                    if unknown_0886H() then
                        add_dialogue("\"Excellent! I have no doubts now that thou art the one true Avatar!\"")
                        add_dialogue("\"Oh-- I almost forgot! The password to leave or enter the town is 'Blackbird'!\"")
                        set_flag(61, true)
                        unknown_0911H(100)
                        return
                    else
                        add_dialogue("\"Hmmm. I am afraid that I still have my doubts about thou being the Avatar. My public duty disallows me to give thee the password. I am sorry.\"")
                        return
                    end
                else
                    add_dialogue("The Mayor shrugs and looks at you as if you were mad.")
                    return
                end
            else
                add_dialogue("\"I will give thee the password when thou hast given me a report on the progress of thine investigation.\"")
                add_answer("report")
                set_flag(66, true)
            end
            remove_answer("password")
        elseif cmps("bye") then
            break
        end
    end
    return
end