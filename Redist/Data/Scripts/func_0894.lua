-- Function 0894: Stone golem dialogue
function func_0894(eventid, itemref)
    local local0, local1, local2, local3

    if not get_flag(795) then
        call_001DH(11, eventid)
    end
    if eventid == 1 then
        switch_talk_to(289, 0)
        if get_flag(804) and not get_flag(796) then
            say(itemref, "\"I -must- return his life to him. He -will- have a new heart!\" The determination is quite evident by his forceful glare and stance.")
        end
        if not get_flag(808) then
            call_0896H()
        end
        if not get_flag(795) then
            set_flag(795, true)
            say(itemref, "\"The stone statue stands with a lowered head. Despite its granite features, a downcast look is apparent on its face. Surprisingly, it turns to speak with you.\"")
            say(itemref, "@Why, by the stars, I believe it is a creature!@")
            say(itemref, "\"Slowly, as if with great effort, it raises it head.\"")
            switch_talk_to(289, 0)
            if check_condition(40, 414, -356) then
                local1 = _GetItemFrame(itemref)
                if local1 == 4 or local1 == 5 then
                    say(itemref, "\"What dost thou... want?\" it asks slowly.")
                else
                    say(itemref, "\"Help him?\" it asks carefully, pointing to the fallen statue lying beside it.")
                    _AddAnswer("help")
                end
                _AddAnswer("Creature?")
            else
                say(itemref, "\"In what way may I assist thee?\"")
            end
        end
        _AddAnswer({"bye", "job", "name"})
        local2 = false
        local3 = false
        while true do
            local answer = get_answer()
            switch_talk_to(289, 0)
            if answer == "name" then
                _RemoveAnswer("name")
                if not get_flag(797) then
                    say(itemref, "\"He tilts his head and stares at you quizzically.~ \"I apologize. Did I not already tell thee my master called me Bollux?\"")
                else
                    say(itemref, "\"My master named me Bollux.\"")
                    set_flag(797, true)
                end
                if not local3 then
                    _AddAnswer("master")
                end
            elseif answer == "job" then
                say(itemref, "\"I am a guardian of the Shrines of the Principles.\"")
                _AddAnswer("guardian")
            elseif answer == "guardian" then
                _RemoveAnswer("guardian")
                say(itemref, "\"We were... created to protect the Shrines of the Principles. Only the... Avatar should use their power. Adjhar and I were... keeping watch... when the wall fell on Adjhar. And the loud noise came... I carried him here so that I could restore him, but I do not... know how.\"")
            elseif answer == "Creature?" then
                _RemoveAnswer("Creature?")
                say(itemref, "\"We are called stone golems... because we are made out of stone and rock.\"")
                if not local2 then
                    _AddAnswer("made")
                    local2 = true
                end
                _AddAnswer("stone")
            elseif answer == "master" or answer == "Astelleron" then
                _RemoveAnswer({"master", "Astelleron"})
                local3 = true
                say(itemref, "\"Astelleron made us. He is our master.\"")
                if not local2 then
                    _AddAnswer("made")
                    local2 = true
                end
            elseif answer == "stone" then
                _RemoveAnswer("stone")
                say(itemref, "\"We were... fashioned... out of the rock from the quarry on this small island.\"")
            elseif answer == "made" then
                local2 = true
                _RemoveAnswer("made")
                say(itemref, "\"I know nothing about the process, but Astelleron once told me he used something called... magic to give us life and... animation.\" The golem pauses, obviously conscious of his next thought.~\"He did not like his... solitude. He said he was... lonely.\"")
                _AddAnswer({"lonely", "magic"})
                if not local3 then
                    _AddAnswer("Astelleron")
                end
            elseif answer == "magic" then
                _RemoveAnswer("magic")
                say(itemref, "\"I do not know what... it is, but there are many books in his house. Perhaps... there is something there about... magic.\"")
                _AddAnswer("books")
            elseif answer == "books" then
                _RemoveAnswer("books")
                if not get_flag(803) then
                    say(itemref, "\"I have a book here that Adjhar said told about... our... creation. This might help bring Adjhar back.\"")
                    local4 = give_item(false, -359, 144, 642, 1)
                    if local4 then
                        say(itemref, "\"He hands to you a very old tome. It is evident the book has seen much use, for the leather covering is wearing away to reveal the wood beneath and the pages are quite dog-eared.~\"I have already set up five... rocks to mark a spot for the... blood.\"")
                        _AddAnswer("blood")
                        set_flag(803, true)
                    else
                        say(itemref, "\"Thou art... carrying too much. Put something down and I can give this to you.\"")
                    end
                else
                    say(itemref, "\"There are several... more books lying about the house. I do not... know what they are about. Adjhar read them.\"")
                end
            elseif answer == "lonely" then
                _RemoveAnswer("lonely")
                say(itemref, "\"Astelleron said it was how... a person feels when no one is around. He told us how... happy he felt after we were... born.~ He called me... a son.\"")
            elseif answer == "help" then
                _RemoveAnswer("help")
                say(itemref, "\"My companion... Adjhar... He is dying. Thou must help repair him. Please, I beg... thee.\"")
                if not get_flag(803) then
                    say(itemref, "\"I have a book here that Adjhar said told about... our... creation. This might help bring him back.\"")
                    local4 = give_item(false, -359, 144, 642, 1)
                    if local4 then
                        say(itemref, "\"He hands to you a very old tome. It is evident the book has seen much use, for the leather covering is wearing away to reveal the wood beneath and the pages are quite dog-eared. \"I have already set up five... rocks to mark a spot for the... blood.\"")
                        _AddAnswer("blood")
                        set_flag(803, true)
                    else
                        say(itemref, "\"Thou art... carrying too much. Put something down and I can give this to you.\"")
                    end
                end
                _AddAnswer("Adjhar")
            elseif answer == "Adjhar" then
                _RemoveAnswer("Adjhar")
                say(itemref, "\"He is my brother... and my friend. We protected the... Shrines together. We cannot let him... stay like that. Help me... assist him.\"")
            elseif answer == "blood" then
                _RemoveAnswer("blood")
                say(itemref, "\"I did not... understand the book, but I remember... blood...\"")
            elseif answer == "bye" then
                say(itemref, "\"Good... bye.\"*")
                return
            end
        end
    end
    return
end