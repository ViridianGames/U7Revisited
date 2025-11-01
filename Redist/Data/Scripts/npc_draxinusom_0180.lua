--- Best guess: Manages Draxinusom's dialogue in Terfin, an aged gargoyle reflecting on his past, The Fellowship, and the loss of his Ethereal Ring.
function npc_draxinusom_0180(eventid, objectref)
    local var_0000, var_0001, var_0002

    if eventid == 1 then
        switch_talk_to(0, 180)
        var_0000 = get_player_name()
        start_conversation()
        add_answer({"bye", "job", "name"})
        if not get_flag(569) and not get_flag(568) then
            add_answer("Inamo")
        end
        if get_flag(4) then
            add_answer("Moongates")
        end
        if not get_flag(581) then
            add_dialogue("You see an aged gargoyle, bent and withered, with a regal bearing. He smiles gently.")
            set_flag(581, true)
        else
            add_dialogue("\"To be good to see you again, old friend. To be needing Draxinusom again so soon?\"")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"To have been many years. To be your old acquaintance, " .. var_0000 .. ", Draxinusom.\"")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"To ask about Job? To be unable to say that I truly have one at this time. To notice how the young ones no longer look to me for guidance any more. To look more to Teregus, or, more often, to those in The Fellowship.\"")
                add_answer({"Fellowship", "Teregus"})
            elseif answer == "Terfin" then
                add_dialogue("\"To be quite comfortable for our needs. To be, however, unfortunate that it was thought necessary to isolate us from the humans. To have engendered resentment and tension in our younger generations. To remember not the old days, my friend -- the days when we had to work together to survive.\" He smiles, reliving old memories, then shakes his head.")
                add_dialogue("\"To have had to give up many much when we moved.\"")
                add_answer("give up")
                remove_answer("Terfin")
            elseif answer == "give up" then
                add_dialogue("\"To have been many favorite possessions. To be too much trouble to move so much.\" He sighs.")
                if get_flag(480) then
                    add_dialogue("\"To especially regret selling my Ethereal Ring.\"")
                    add_answer({"Ethereal Ring", "selling"})
                end
                remove_answer("give up")
            elseif answer == "Ethereal Ring" then
                add_dialogue("\"Ah. To be, indeed, a lovely treasure. To have been quite useful. A shame to have been, really, to have had to sell it. To have been one of my favorites.\"")
                remove_answer("Ethereal Ring")
            elseif answer == "selling" then
                add_dialogue("\"To have sold most of my treasures when we were... uh... asked, shall to say, to move to the island. To have all happened rather quickly, you see. To have sold most to the Sultan of Spektran.\"")
                add_answer("Sultan")
                remove_answer("selling")
            elseif answer == "Sultan" then
                add_dialogue("\"To have seemed nice enough, for a human. To be a bit mad, he is, even for a human. To tell you he lives on an island just to the west of us. To know, at least, that my prized possessions would be safe in his hands.\"")
                add_answer("safe")
                set_flag(571, true)
                utility_unknown_1041(50)
                remove_answer("Sultan")
            elseif answer == "safe" then
                add_dialogue("He nods his head. \"To be rumored to have one of the best-guarded vaults in all of Britannia. To be supposedly enchanted. To know not details.\"")
                remove_answer("safe")
            elseif answer == "Inamo" then
                remove_answer("Inamo")
                add_dialogue("\"To be a fine young gargoyle. To have been raised by Teregus, keeper of the altars. To have left town because of the tension between the altar worshippers and The Fellowship. To have been angry and distrustful of The Fellowship. To have news of him?\"")
                var_0001 = ask_yes_no()
                if var_0001 then
                    add_dialogue("\"To be excellent! To have seen him? To know how he is faring? To be well?\"")
                    set_flag(568, true)
                    save_answers()
                    add_answer({"well", "not well", "murdered"})
                else
                    add_dialogue("\"Ah. To be too bad. To tell you Teregus wanted to know how he was doing.\"")
                end
            elseif answer == "well" then
                add_dialogue("\"To be very good. To know Teregus will be pleased to learn that, as well!\"")
                restore_answers()
            elseif answer == "murdered" then
                add_dialogue("\"To be terrible news! To have been such a fine gargoyle. To know Teregus will be heartbroken. To be wishing not for him to grieve, but to take to him the news immediately. To be better to hear it from you.\"")
                restore_answers()
            elseif answer == "Moongates" then
                add_dialogue("\"Mine own Orb of the Moons exploded recently! To no longer be able to travel via Moongates. To be strange!\"")
                remove_answer("Moongates")
            elseif answer == "not well" then
                add_dialogue("\"To be a shame. To be taking the news to Teregus of his youngling. To be wondering why we had not heard from Inamo recently.\"")
                restore_answers()
            elseif answer == "Teregus" then
                add_dialogue("\"To be truly a fine young gargoyle. To be one of the most sensible, too. To have seen fit to adhere to the old ways, the ways of the altars. To see that some of the youngest still look up to him, but the majority seem to have been wooed away by the glamor of The Fellowship.\"")
                if not get_flag(568) then
                    add_dialogue("\"To tell you that his weanling, Inamo, is in Trinsic at this time.\"")
                    set_flag(569, true)
                    add_answer("Inamo")
                end
                remove_answer("Teregus")
            elseif answer == "Fellowship" then
                add_dialogue("\"To know not what to think of them and their tenets. To seem not dangerous, but not to be following the old ways, the ways of Passion, Diligence, and Control. To feign worship to the shrines here in Terfin, of course, especially to Control, but not yet to trust them. To wait and see. To have forceful leaders who espouse doctrines of submission.\" He shrugs.")
                add_dialogue("\"To be genuinely inspired, perhaps, and perhaps not.\"")
                add_answer({"leaders", "Terfin"})
                remove_answer("Fellowship")
            elseif answer == "leaders" then
                add_dialogue("\"To inform you that The Fellowship is directed by two winged brethren. To be called Runeb and Quan.\"")
                add_answer({"Quan", "Runeb"})
                remove_answer("leaders")
            elseif answer == "Runeb" then
                add_dialogue("\"To mean, in your language, `Red Mist'. To have been given that name because that is all he leaves behind of an adversary in battle. Before his conversion by The Fellowship, to have been known as a particularly cruel and dangerous gargoyle.\"")
                var_0002 = is_dead(get_npc_name(-184))
                if var_0002 then
                    add_dialogue("\"To be gone -- dead -- now.\"")
                end
                remove_answer("Runeb")
            elseif answer == "Quan" then
                add_dialogue("\"Ah, to be an interesting one. To be a strong, powerful personality, to be from one of the families most able to claim noble lineage in our society. To have been always most self-serving, striving only to gain status and wealth for himself. To have certainly changed his tune since joining The Fellowship. To have my doubts, however, that his goals have changed as well.\"")
                remove_answer("Quan")
            elseif answer == "bye" then
                add_dialogue("\"To bid farewell, old friend. To not be hesitating to return if there is aught else I can do for you. To be lonely here now for an old gargoyle dedicated to the ancient ways...\"")
                break
            end
        end
    elseif eventid == 0 then
        return
    end
    return
end