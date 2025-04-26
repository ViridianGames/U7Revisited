-- Manages Finnigan's dialogue and interactions

-- Global variables for answer handling
answers = answers or {}
answer = answer or nil

function func_040C(itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9
    local local10, local11, local12, local13, local14

    if eventid() == 1 then
        _SwitchTalkTo(0, -12)
        local0 = call_0909H()
        local1 = call_0908H()
        local2 = call_08F7H(-2)
        local3 = callis_005A()
        if get_flag(90) and not get_flag(72) then
            if not answer then
                say("\"Hast thou properly searched the stables?\"")
                answers = {true, false}
                answer = call_090AH()
                return
            elseif answer == true then
                say("\"What didst thou find?\"")
                callis_0009()
                local4 = {"a body", "a bucket", "nothing"}
                if not get_flag(60) then
                    table.insert(local4, "a key")
                end
                answers = local4
                answer = call_090BH(answers)
                return
            else
                say("\"Well, do so, then come speak with me!\"")
                answers = {}
                answer = nil
                abort()
            end
        elseif answer == "a key" then
            if not local2 then
                say("\"Hmmm, a key. Perhaps if thou dost ask Christopher's son about it, he may know what it is for.\"")
            else
                say("\"Ask Spark about it. He may know something.\"")
            end
            set_flag(72, true)
            answers = {}
            answer = nil
            return
        elseif answer == "a body" then
            say("\"I know that! What ELSE didst thou find? Thou shouldst look again, Avatar!\"")
            answers = {}
            answer = nil
            abort()
        elseif answer == "a bucket" then
            say("\"Yes, obviously it is filled with poor Christopher's own blood. But surely there was something else that might point us in the direction of the killer or killers - thou shouldst look again, Avatar.\"")
            answers = {}
            answer = nil
            abort()
        elseif answer == "nothing" then
            say("\"Thou shouldst look again, 'Avatar'!\"")
            answers = {}
            answer = nil
            abort()
        end
        if get_flag(89) then
            if not answer then
                say("\"Hmmm. Hast thou reconsidered mine offer to investigate the murder?\"")
                answers = {true, false}
                answer = call_090AH()
                return
            elseif answer == true then
                say("\"Splendid. Then thou must really be the Avatar after all!\"")
                set_flag(89, false)
                call_0883H()
            else
                say("\"Then leave our people to work it out for themselves.\"")
                _HideNPC(-12)
                local6 = call_08F7H(-1)
                if not local6 then
                    _SwitchTalkTo(0, -1)
                    say("\"Avatar! I am ashamed of thee! Thou shouldst reconsider!\"")
                    _HideNPC(-1)
                end
                answers = {}
                answer = nil
                abort()
            end
        end
        if not get_flag(76) then
            if not answer then
                callis_005C(itemref)
                callis_001D(11, callis_001B(-12, -12))
                say("You see a middle-aged nobleman.")
                set_flag(76, true)
                local6 = call_08F7H(-1)
                if not local6 then
                    say("\"Iolo! Who is this stranger?\"")
                    _SwitchTalkTo(0, -1)
                    say("\"Why, this is the Avatar!\" Iolo proudly proclaims. \"Canst thou believe it? May I introduce thee? This is Finnigan, the Town Mayor. And this is " .. local1 .. ", the Avatar!\"")
                    if local3 then
                        say("\"I simply cannot believe she is here!\"")
                    else
                        say("\"I simply cannot believe he is here!\"")
                    end
                    _SwitchTalkTo(0, -12)
                    say("The Mayor looks you up and down, not sure if he believes Iolo or not. He looks at Iolo skeptically.")
                    _SwitchTalkTo(0, -1)
                    say("\"I swear to thee, it is the Avatar!\"")
                    _HideNPC(-1)
                    _SwitchTalkTo(0, -12)
                else
                    say("\"I have heard that thou art the Avatar. I am not certain that I believe it.")
                end
                say("The mayor looks at you again as if he were studying every pore on your face. Finally, he smiles.")
                say("\"Welcome, Avatar.\"")
                say("But just as suddenly, Finnigan's face becomes stern.")
                say("\"A horrible murder has occurred. If thou art truly the Avatar, perhaps thou canst help us solve it. I would feel better if thou takest this matter into thine hands. Thou shalt be handsomely rewarded if thou dost discover the name of the killer. Dost thou accept?\"")
                answers = {true, false}
                answer = call_090AH()
                return
            elseif answer == true then
                local7 = call_08F7H(-11)
                if not local7 then
                    say("\"Petre here knows something about all of this.\"")
                    _SwitchTalkTo(0, -11)
                    say("The peasant interjects. \"I discovered poor Christopher and the Gargoyle Inamo early this morning.\"")
                    _HideNPC(-11)
                else
                    _SwitchTalkTo(0, -12)
                    say("\"Petre, the stables caretaker, discovered poor Christopher and Inamo early this morning.\"")
                end
                _SwitchTalkTo(0, -12)
                say("The Mayor continues. \"Hast thou searched the stables?\"")
                call_0885H()
            else
                say("\"Well, thou could not be the real Avatar then!\"")
                set_flag(89, true)
                answers = {}
                answer = nil
                abort()
            end
        else
            if not answer then
                say("\"Yes, Avatar?\" Finnigan asks.")
                answers = {}
                _AddAnswer({"bye", "murder", "job", "name"})
                if not get_flag(91) then
                    _AddAnswer("report")
                end
                if not get_flag(63) then
                    _AddAnswer({"Klog", "Fellowship"})
                end
                if get_flag(66) and not get_flag(61) then
                    _AddAnswer("password")
                end
                if get_flag(69) and not get_flag(68) then
                    _AddAnswer("Pay me now, please")
                end
                answer = call_090BH(answers)
                return
            end
        end

        -- Process answer
        if cmp_strings("name", 1) then
            say("\"My name is Finnigan.\"")
            _RemoveAnswer("name")
        elseif cmp_strings("job", 1) then
            say("\"I am the Mayor of Trinsic and have been since I arrived here three years ago.\"")
            _AddAnswer("Trinsic")
        elseif cmp_strings("Trinsic", 1) then
            local8 = local3 and "by one who claimed she was the Avatar." or "by one who claimed he was the Avatar."
            say("\"Trinsic was once the city of Honor. I suppose it still is. Our Rune of Honor was taken many years ago " .. local8 .. " I believe it now resides in the Royal Museum in Britain, yet the empty pedestal still remains in the center of town. I feel this is symbolic of the town itself. It is rather empty -- of people, of life, and of honor. 'Tis sad, really.\"")
            say("\"Then there is this murder, of course. We have temporarily closed the gates of the city and require a password to get in or out.\"")
            _RemoveAnswer("Trinsic")
            _AddAnswer("password")
        elseif cmp_strings("Pay me now, please", 1) then
            say("\"Of course, " .. local1 .. ". Here is thy gold.\"")
            if not callis_002C(true, -359, -359, 644, 100) then
                say("\"Here thou art.\"")
                set_flag(69, false)
                set_flag(68, true)
            else
                say("\"Oh, I am sorry, " .. local1 .. ". Thou still cannot carry this amount. Thou must return to me later.\"")
            end
            _RemoveAnswer("Pay me now, please")
        elseif cmp_strings("murder", 1) then
            if not get_flag(61) then
                say("\"A crime like this has never happened in Trinsic before. I cannot believe this happened to Christopher and Inamo. Please -- explore the town! I would appreciate it if thou wouldst bring me a report on thy progress. Be sure to ask everyone in town about the murder. After speaking with Christopher's son, thou mightest next want to speak with Gilberto, the guard on watch at the dock last night.\"")
                say("The mayor hesitates, then leans in to speak quietly.")
                say("\"Actually, I have seen something like this before. It was about four years ago, in Britain.\"")
                _AddAnswer({"report", "Britain", "Inamo", "Christopher", "Gilberto"})
                set_flag(91, true)
                _RemoveAnswer("murder")
            else
                say("\"I hope thou art progressing on the murder investigation.\"")
            end
        elseif cmp_strings("Britain", 1) then
            say("\"'Twas before I came to Trinsic. There was a murder with strikingly similar aspects. A body was found mutilated exactly like poor Christopher. It appeared to be a ritualistic killing. I would wager that whoever was responsible for that murder is the culprit behind this one.\"")
            _RemoveAnswer("Britain")
        elseif cmp_strings("son", 1) then
            say("\"Christopher's son is called Spark. Their house is in the northwest area of town.\"")
            _RemoveAnswer("son")
        elseif cmp_strings("Gilberto", 1) then
            say("\"He was struck from behind early this morning and was knocked senseless. Johnson, the morning watch, found him unconscious. He is recuperating at Chantu the Healer's house on the west side of town.\"")
            _RemoveAnswer("Gilberto")
            _AddAnswer({"Chantu", "Johnson"})
        elseif cmp_strings("Chantu", 1) then
            say("\"He is our town healer. He hath been here for years. Nice fellow.\"")
            _RemoveAnswer("Chantu")
        elseif cmp_strings("report", 1) then
            if get_flag(68) then
                say("\"I am satisfied with thy report. Please carry on thine investigation, Avatar.\"")
            elseif not get_flag(93) then
                say("\"Art thou ready to answer some questions concerning the investigation?\"")
                answers = {true, false}
                answer = nil
                return
            else
                say("\"Shall we continue thy report?\"")
                answers = {true, false}
                answer = nil
                return
            end
        elseif cmp_strings(true, 1) then
            if not get_flag(93) then
                set_flag(93, true)
                call_0884H()
            else
                call_0884H()
            end
        elseif cmp_strings(false, 1) then
            say("\"Oh. Well, carry on with thine investigation.\"")
        elseif cmp_strings("Fellowship", 1) then
            say("\"Why, they are an extremely helpful group. Their branch office is just east of mine. Very optimistic group of people.\"")
            _RemoveAnswer("Fellowship")
        elseif cmp_strings("Klog", 1) then
            say("\"He is the Fellowship branch leader. Kind man.\"")
            _RemoveAnswer("Klog")
        elseif cmp_strings("Johnson", 1) then
            say("\"He is probably at the dock right now.\"")
            _RemoveAnswer("Johnson")
        elseif cmp_strings("Christopher", 1) then
            say("\"Christopher was the local blacksmith. He lives, or rather -lived-, with his son in the northwest part of town. The blacksmith's shop is in the southwest corner. Christopher was not a rich man by any means -- he barely kept himself and his son alive. But he certainly enjoyed his work.\"")
            _RemoveAnswer("Christopher")
            _AddAnswer("son")
        elseif cmp_strings("Inamo", 1) then
            say("\"The Gargoyle Inamo slept in the stables, as I understand it. I believe he emigrated here from Terfin a few months ago. It seems that he was merely a chance victim of someone intent on violence.\"")
            _RemoveAnswer("Inamo")
        elseif cmp_strings("password", 1) then
            if get_flag(68) and not get_flag(61) then
                say("\"Oh, dost thou want the password now?\"")
                answers = {true, false}
                answer = nil
                return
            else
                say("\"I will give thee the password when thou hast given me a report on the progress of thine investigation.\"")
                _AddAnswer("report")
                set_flag(66, true)
            end
            _RemoveAnswer("password")
        elseif cmp_strings(true, 1) then
            if call_0886H() then
                say("\"Excellent! I have no doubts now that thou art the one true Avatar!\"")
                say("\"Oh-- I almost forgot! The password to leave or enter the town is 'Blackbird'!\"")
                set_flag(61, true)
                call_0911H(100)
                answers = {}
                answer = nil
                abort()
            else
                say("\"Hmmm. I am afraid that I still have my doubts about thou being the Avatar. My public duty disallows me to give thee the password. I am sorry.\"")
                answers = {}
                answer = nil
                abort()
            end
        elseif cmp_strings(false, 1) then
            say("The Mayor shrugs and looks at you as if you were mad.")
            answers = {}
            answer = nil
            abort()
        elseif cmp_strings("bye", 1) then
            say("The Mayor nods his head at you and goes on about his business.")
            answers = {}
            answer = nil
            return
        end

        -- Clear answer if not handled
        answer = nil
        return
    elseif eventid() == 0 then
        local12 = callis_001C(callis_001B(-12, -12))
        local13 = callis_0010(4, 1)
        local14 = ""
        if local12 == 11 then
            if local13 == 1 then
                local14 = "@What a day...@"
            elseif local13 == 2 then
                local14 = "@Another day, another gold coin...@"
            elseif local13 == 3 then
                local14 = "@I shall search the area here...@"
            elseif local13 == 4 then
                local14 = "@I am too old for this...@"
            end
            _ItemSay(local14, -12)
        else
            call_092EH(-12)
        end
        answers = {}
        answer = nil
    end
end

-- Helper functions
function eventid()
    return 0 -- Placeholder
end

function say(...)
    print(table.concat({...}))
end

function get_flag(id)
    return false -- Placeholder
end

function set_flag(id, value)
    -- Placeholder
end

function cmp_strings(str, count)
    return false -- Placeholder
end