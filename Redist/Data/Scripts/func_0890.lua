-- Function 0890: Adjhar golem dialogue
function func_0890(eventid, itemref)
    local local0

    switch_talk_to(288, 0)
    if not get_flag(788) then
        add_answer({"bye", "sacrificed", "Don't know"})
        set_flag(788, true)
    else
        add_answer({"bye", "job", "name"})
    end
    if not get_flag(798) then
        add_answer("what next")
    end
    while true do
        local answer = get_answer()
        if answer == "Don't know" then
            add_dialogue(itemref, "\"He kneels over the body and inspects the other golem. As his fingers trace around the gaping hole in Bollux's chest, an expression of understanding fills his visage.~\"H-his heart is gone!\"~ He stares down at his own chest. \"He sacrificed himself by giving me his heart... the fool!\" His words are insulting but his tone is affectionate.\"")
            remove_answer({"sacrificed", "Don't know"})
            add_dialogue(itemref, "\"I must help him, as he helped me! Wilt thou assist?\"")
            if get_answer() then
                add_dialogue(itemref, "\"Very good,\" he says, noticeably relieved. \"I thank thee in advance.\"")
                set_flag(798, true)
                add_answer({"fool", "job", "name"})
            else
                add_dialogue(itemref, "\"Then I must go this one myself,\" he says angrily. \"'Tis no more than one friend would do for another... no more than Bollux did for me!\"")
                add_dialogue(itemref, "\"He looks at you carefully. His stoney features do nothing to hide the suspicion on his face, or in his voice.~\"It is quite obvious to me thou art but a lost traveler and certainly not the Avatar for whom I mistook thee.\"*")
                return
            end
        elseif answer == "sacrificed" then
            add_dialogue(itemref, "\"You quickly relate the details of Bollux's death as he pulled the object from his chest and placed it in the other golem's.~\"He sacrificed himself by giving me his heart... the fool!\" His words are insulting but his tone is affectionate.\"")
            remove_answer({"sacrificed", "Don't know"})
            add_dialogue(itemref, "\"I must help him, as he helped me! Wilt thou assist?\"")
            if get_answer() then
                add_dialogue(itemref, "\"Very good,\" he says, notably relieved. \"I thank thee in advance.\"")
                set_flag(798, true)
                add_answer({"fool", "job", "name"})
            else
                add_dialogue(itemref, "\"Then I must go this one myself,\" he says angrily. \"'Tis no more than one friend would do for another... no more than Bollux did for me!\"")
                add_dialogue(itemref, "\"He looks at you carefully. His stoney features do nothing to hide the suspicion on his face, or in his voice.~\"It is quite obvious to me thou art but a lost traveler and certainly not the Avatar for whom I mistook thee.\"*")
                return
            end
        elseif answer == "name" then
            remove_answer("name")
            add_dialogue(itemref, "\"I am the golem called Adjhar, at thy service.\"")
        elseif answer == "job" then
            add_dialogue(itemref, "\"I am one of the guardians of the Shrines of the Principles. That was exactly what Bollux and I were doing when the wall fell and crushed me.\"")
            add_answer({"wall", "Shrines", "Bollux"})
        elseif answer == "Shrines" then
            remove_answer("Shrines")
            add_dialogue(itemref, "\"Surely thou hast heard of the Shrines of the Three Principles: Truth, Love, and Courage! We golems were fabricated to protect the Shrines, for only an Avatar -- -the- Avatar -- may utilize the awesome power they can convey.\"")
        elseif answer == "wall" then
            remove_answer("wall")
            add_dialogue(itemref, "\"I do not remember the incident clearly. However, I will relate what I can recall. Bollux and I were standing guard in the Shrine Room of the Principles when we detected an intrusion into the castle. I remember nothing more than being aware of great heat, and then part of the wall crumbling atop me, crushing my legs. I suppose Bollux was more fortunate. Was it he who carried me here?\"")
            if get_answer() then
                add_dialogue(itemref, "\"Then it is imperative that we find a way to bring him back! If nothing else, I owe him my gratitude.\"")
            else
                add_dialogue(itemref, "\"Strange,\" he says, puzzled. \"I am at a loss then to explain my arrival here.~Regardless, I -must- find a way to restore life to him!\"")
            end
        elseif answer == "Bollux" then
            add_dialogue(itemref, "\"Hast thou not already met him? He is my older brother, and my friend.\"")
            remove_answer("Bollux")
            add_answer("older")
        elseif answer == "older" then
            add_dialogue(itemref, "\"Master Astelleron -- we actually called him our father -- created him before he did me. And he instilled Bollux with a personality first.\"")
            remove_answer("older")
        elseif answer == "what next" then
            remove_answer("what next")
            add_dialogue(itemref, "\"Dost thou have the book entitled, `The Stone of Castambre?'\"")
            if get_answer() then
                local0 = check_condition(-359, 144, 642, 1, -357)
                if local0 then
                    add_dialogue(itemref, "\"His eyes reveal his hope. As he takes the book from you, it almost appears as if he is smiling.\"")
                    call_0891H()
                else
                    add_dialogue(itemref, "\"I must see the book the book to use it. Perhaps thou hast mislaid it about somewhere.\" He stares directly at you. \"'Tis vital that I have that tome. I beg thee, retrieve it for me!\"")
                    set_flag(799, true)
                end
            else
                add_dialogue(itemref, "\"Please go and recover it then. I believe it contains information that may help my companion.\"")
                set_flag(799, true)
            end
        elseif answer == "fool" then
            remove_answer("fool")
            add_dialogue(itemref, "\"Poor Bollux did not know of the Stone of Castambre. His sacrifice was, perhaps, unnecessary. Hast thou, perchance, come across MacCuth's \"The Stone of Castambre?\"")
            if get_answer() then
                add_dialogue(itemref, "\"Dost thou have it with thee?\"")
                if get_answer() then
                    local0 = check_condition(-359, 144, 642, 1, -357)
                    if local0 then
                        add_dialogue(itemref, "\"His eyes reveal his hope. As he takes the book from you, it almost appears as if he is smiling.\"")
                        call_0891H()
                    else
                        add_dialogue(itemref, "\"I must see the book the book to use it. Perhaps thou hast mislaid it about somewhere.\" He stares directly at you. \"'Tis vital that I have that tome. I beg thee, retrieve it for me!\"")
                        set_flag(799, true)
                    end
                else
                    add_dialogue(itemref, "\"Please go and recover it then. I believe it contains information that may help my companion.\"")
                    set_flag(799, true)
                end
            else
                add_dialogue(itemref, "\"Then I recommend thou dost search within my master's chambers for it. The pages contain words which may help my companion.\"")
            end
        elseif answer == "bye" then
            add_dialogue(itemref, "\"I can offer nothing more for thine assistance than my deepest appreciation. Please journey in peace.\"*")
            return
        end
    end
    return
end