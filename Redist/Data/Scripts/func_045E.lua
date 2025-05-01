-- Manages Karenna's dialogue in Minoc, covering combat training, murders, Jakher's relationship, and gypsy connections.
function func_045E(eventid, itemref)
    local local0, local1, local2, local3

    if eventid == 1 then
        switch_talk_to(94, 0)
        local0 = get_player_name()
        local1 = get_party_size()
        local2 = switch_talk_to(94)

        add_answer({"murders", "bye", "job", "name"})

        if not get_flag(244) then
            add_answer("gypsies")
        end
        if not get_flag(245) then
            add_answer("attractive")
        end

        if not get_flag(281) then
            add_dialogue("You see a stealthy-looking woman, dressed all in green. There is a wicked grin on her face.")
            set_flag(281, true)
        else
            add_dialogue("\"How good to see thee again,\" says Karenna.")
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"I answer to Karenna, and to nothing else.\"")
                remove_answer("name")
            elseif answer == "job" then
                if not get_flag(287) then
                    add_dialogue("\"I am a teacher in Minoc, along with Jakher.\"")
                    add_answer({"Jakher", "Minoc", "teacher"})
                else
                    add_dialogue("\"An odd question to ask at such a time as this, " .. local0 .. ". Dost thou know that two people lie dead in that sawmill and they are dead from the hand of perpetrator or perpetrators unknown?\"")
                    set_flag(287, true)
                    add_answer("murders")
                end
            elseif answer == "Minoc" then
                add_dialogue("\"Minoc was usually busy, but quiet. Then our town was bothered by this nonsense over Owen's monument, and now these murders.\"")
                add_answer({"murders", "monument"})
                remove_answer("Minoc")
            elseif answer == "murders" then
                add_dialogue("\"Shocking! Such things do not normally happen here. It well proves the value of knowing how to defend oneself.\"")
                remove_answer("murders")
            elseif answer == "Jakher" then
                add_dialogue("\"He is quite an able trainer in his own right. Not as skilled as myself, obviously. But I do think he is cute, though I bid thee, do not tell him that I spoke of this. It will only encourage him.\"")
                if get_item_type(-95) then
                    switch_talk_to(95, 0)
                    add_dialogue("\"Art thou speaking about me? Mine ears are burning!\"*")
                    switch_talk_to(94, 0)
                    add_dialogue("\"Nothing thou shouldst be concerned about, Jakher.\" She winks at you.*")
                    hide_npc(95)
                    switch_talk_to(94, 0)
                end
                set_flag(246, true)
                remove_answer("Jakher")
            elseif answer == "teacher" then
                if local2 == 27 then
                    add_dialogue("\"I teach that singular skill which enables one to learn all the lessons of life without losing it in the process. Combat!~~\"I would charge thee 20 gold for each training session. Art thou still interested?\"")
                    if get_answer() then
                        train_combat(20, 4, {1, 2}) -- Unmapped intrinsic 08A6
                    else
                        add_dialogue("\"Very well. If thou art fortunate thou wilt not have cause to regret it.\"")
                    end
                    remove_answer("teacher")
                else
                    add_dialogue("\"Our establishment is now closed. Please come by during business hours.\"")
                    remove_answer("teacher")
                end
            elseif answer == "monument" then
                add_dialogue("\"I understand it is to be thirty feet high and will display our local shipwright as he holds aloft a sextant. Thou wouldst not believe a thing as benign as this could create such trouble.\"")
                remove_answer("monument")
                add_answer("trouble")
            elseif answer == "trouble" then
                add_dialogue("\"It would seem the increase in hostilities amongst the fair citizenry over our shipwright's monument has filled much of the local populace with a burning desire to acquire combative skills. Business has never been better!\"")
                remove_answer("trouble")
                add_answer("hostilities")
            elseif answer == "hostilities" then
                add_dialogue("\"Everyone in town is all up in arms about this and that. But surely others would know more of these local politics. I care not.\"")
                remove_answer("hostilities")
            elseif answer == "attractive" then
                add_dialogue("\"Jakher told thee he doth find me attractive? He denies it, of course, but I have known for years that he doth have feelings for me.\"")
                if get_item_type(-95) then
                    switch_talk_to(95, 0)
                    add_dialogue("\"What? What didst thou say?\"*")
                    switch_talk_to(94, 0)
                    add_dialogue("\"Nothing, Jakher. Go away.\" She giggles conspiratorally at you.*")
                    hide_npc(95)
                    switch_talk_to(94, 0)
                end
                remove_answer("attractive")
            elseif answer == "gypsies" then
                add_dialogue("\"Frederico, the leader of the Gypsies, and his wife, Tania, were good people. Why, the worst thing I ever knew either of them to do was a simple prank.\"")
                remove_answer("gypsies")
                add_answer("prank")
            elseif answer == "prank" then
                add_dialogue("\"Once Frederico threw a rock through the window of the local Fellowship branch... Oh, well, I thought it was amusing!\"")
                remove_answer("prank")
            elseif answer == "bye" then
                add_dialogue("\"Farewell. May all thy journeys be interesting ones.\"*")
                break
            end
        end
    elseif eventid == 0 then
        switch_talk_to(94)
    end
    return
end