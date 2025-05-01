-- Function 0894: Stone golem dialogue
function func_0894(eventid, itemref)
    local local0, local1, local2, local3

    if not get_flag(795) then
        call_001DH(11, eventid)
    end
    if eventid == 1 then
        switch_talk_to(289, 0)
        if get_flag(804) and not get_flag(796) then
            add_dialogue(itemref, "\"I -must- return his life to him. He -will- have a new heart!\" The determination is quite evident by his forceful glare and stance.")
        end
        if not get_flag(808) then
            call_0896H()
        end
        if not get_flag(795) then
            set_flag(795, true)
            add_dialogue(itemref, "\"The stone statue stands with a lowered head. Despite its granite features, a downcast look is apparent on its face. Surprisingly, it turns to speak with you.\"")
            add_dialogue(itemref, "@Why, by the stars, I believe it is a creature!@")
            add_dialogue(itemref, "\"Slowly, as if with great effort, it raises it head.\"")
            switch_talk_to(289, 0)
            if check_condition(40, 414, -356) then
                local1 = _GetItemFrame(itemref)
                if local1 == 4 or local1 == 5 then
                    add_dialogue(itemref, "\"What dost thou... want?\" it asks slowly.")
                else
                    add_dialogue(itemref, "\"Help him?\" it asks carefully, pointing to the fallen statue lying beside it.")
                    add_answer("help")
                end
                add_answer("Creature?")
            else
                add_dialogue(itemref, "\"In what way may I assist thee?\"")
            end
        end
        add_answer({"bye", "job", "name"})
        local2 = false
        local3 = false
        while true do
            local answer = get_answer()
            switch_talk_to(289, 0)
            if answer == "name" then
                remove_answer("name")
                if not get_flag(797) then
                    add_dialogue(itemref, "\"He tilts his head and stares at you quizzically.~ \"I apologize. Did I not already tell thee my master called me Bollux?\"")
                else
                    add_dialogue(itemref, "\"My master named me Bollux.\"")
                    set_flag(797, true)
                end
                if not local3 then
                    add_answer("master")
                end
            elseif answer == "job" then
                add_dialogue(itemref, "\"I am a guardian of the Shrines of the Principles.\"")
                add_answer("guardian")
            elseif answer == "guardian" then
                remove_answer("guardian")
                add_dialogue(itemref, "\"We were... created to protect the Shrines of the Principles. Only the... Avatar should use their power. Adjhar and I were... keeping watch... when the wall fell on Adjhar. And the loud noise came... I carried him here so that I could restore him, but I do not... know how.\"")
            elseif answer == "Creature?" then
                remove_answer("Creature?")
                add_dialogue(itemref, "\"We are called stone golems... because we are made out of stone and rock.\"")
                if not local2 then
                    add_answer("made")
                    local2 = true
                end
                add_answer("stone")
            elseif answer == "master" or answer == "Astelleron" then
                remove_answer({"master", "Astelleron"})
                local3 = true
                add_dialogue(itemref, "\"Astelleron made us. He is our master.\"")
                if not local2 then
                    add_answer("made")
                    local2 = true
                end
            elseif answer == "stone" then
                remove_answer("stone")
                add_dialogue(itemref, "\"We were... fashioned... out of the rock from the quarry on this small island.\"")
            elseif answer == "made" then
                local2 = true
                remove_answer("made")
                add_dialogue(itemref, "\"I know nothing about the process, but Astelleron once told me he used something called... magic to give us life and... animation.\" The golem pauses, obviously conscious of his next thought.~\"He did not like his... solitude. He said he was... lonely.\"")
                add_answer({"lonely", "magic"})
                if not local3 then
                    add_answer("Astelleron")
                end
            elseif answer == "magic" then
                remove_answer("magic")
                add_dialogue(itemref, "\"I do not know what... it is, but there are many books in his house. Perhaps... there is something there about... magic.\"")
                add_answer("books")
            elseif answer == "books" then
                remove_answer("books")
                if not get_flag(803) then
                    add_dialogue(itemref, "\"I have a book here that Adjhar said told about... our... creation. This might help bring Adjhar back.\"")
                    local4 = give_item(false, -359, 144, 642, 1)
                    if local4 then
                        add_dialogue(itemref, "\"He hands to you a very old tome. It is evident the book has seen much use, for the leather covering is wearing away to reveal the wood beneath and the pages are quite dog-eared.~\"I have already set up five... rocks to mark a spot for the... blood.\"")
                        add_answer("blood")
                        set_flag(803, true)
                    else
                        add_dialogue(itemref, "\"Thou art... carrying too much. Put something down and I can give this to you.\"")
                    end
                else
                    add_dialogue(itemref, "\"There are several... more books lying about the house. I do not... know what they are about. Adjhar read them.\"")
                end
            elseif answer == "lonely" then
                remove_answer("lonely")
                add_dialogue(itemref, "\"Astelleron said it was how... a person feels when no one is around. He told us how... happy he felt after we were... born.~ He called me... a son.\"")
            elseif answer == "help" then
                remove_answer("help")
                add_dialogue(itemref, "\"My companion... Adjhar... He is dying. Thou must help repair him. Please, I beg... thee.\"")
                if not get_flag(803) then
                    add_dialogue(itemref, "\"I have a book here that Adjhar said told about... our... creation. This might help bring him back.\"")
                    local4 = give_item(false, -359, 144, 642, 1)
                    if local4 then
                        add_dialogue(itemref, "\"He hands to you a very old tome. It is evident the book has seen much use, for the leather covering is wearing away to reveal the wood beneath and the pages are quite dog-eared. \"I have already set up five... rocks to mark a spot for the... blood.\"")
                        add_answer("blood")
                        set_flag(803, true)
                    else
                        add_dialogue(itemref, "\"Thou art... carrying too much. Put something down and I can give this to you.\"")
                    end
                end
                add_answer("Adjhar")
            elseif answer == "Adjhar" then
                remove_answer("Adjhar")
                add_dialogue(itemref, "\"He is my brother... and my friend. We protected the... Shrines together. We cannot let him... stay like that. Help me... assist him.\"")
            elseif answer == "blood" then
                remove_answer("blood")
                add_dialogue(itemref, "\"I did not... understand the book, but I remember... blood...\"")
            elseif answer == "bye" then
                add_dialogue(itemref, "\"Good... bye.\"*")
                return
            end
        end
    end
    return
end