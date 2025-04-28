require "U7LuaFuncs"
-- Manages Paulette's dialogue in Skara Brae, as the ghostly barmaid, covering her flirtatious demeanor, the fire, and her refusal to be a sacrifice.
function func_0491(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11

    if eventid == 1 then
        switch_talk_to(-145, 0)
        local0 = get_player_name()
        local1 = is_player_female()
        local2 = get_part_of_day()
        local3 = get_schedule(-145)
        local4 = false
        local5 = false
        add_answer({"bye", "job", "name"})
        if not get_flag(380) then
            add_answer("Tortured One")
        end
        if not get_flag(441) then
            say("The lovely apparition goes about her tasks without offering any response.*")
            return
        end
        if not get_flag(426) then
            if local2 == 0 or local2 == 1 then
                if local3 == 14 then
                    say("The lovely barmaid stares off into oblivion, completely unaware of her location and position.*")
                    return
                elseif local3 ~= 11 then
                    say("The pretty barmaid looks as if she's about to fall over for a moment, then quickly rights herself. \"Oh, I feel a bit... faint.\" She turns away, distracted.*")
                    return
                end
            end
        end
        if get_flag(420) then
            say("\"Go away! Thou art cruel and mean-hearted.\" She turns away, but not before you see the tears in her eyes.*")
            return
        end
        local6 = switch_talk_to(-144)
        if local6 and not get_flag(446) then
            say("Paulette perks up as she sees Rowena.~~\"Hello, milady. 'Tis good to see thee again. How art thou?\"*")
            switch_talk_to(-144, 0)
            say("\"I am fine, Paulette. I thank thee for thy concern.\"*")
            hide_npc(-144)
            switch_talk_to(-145, 0)
            say("\"'Tis good news indeed, milady.\"")
            set_flag(446, true)
        end
        local7 = switch_talk_to(-147)
        if local7 and not get_flag(445) then
            say("\"Hello, Mayor. It has been quite a while since we've seen thee in our tavern. There was a time, I remember, when we couldn't keep thee away.\"*")
            switch_talk_to(-147, 0)
            say("The mayor becomes quickly embarrassed as he tries to quiet the rather friendly Paulette.~~\"I, er, used to be a wine connoisseur of sorts,\" he says to you.*")
            hide_npc(-147)
            switch_talk_to(-145, 0)
            say("\"'Tis not all thou wert a connoisseur of,\" adds Paulette, eyes twinkling. \"I seem to remember thou had quite a taste for redheads.\"")
            set_flag(445, true)
        end
        if not get_flag(408) then
            add_answer("sacrifice")
        end
        if not get_flag(458) then
            if not local1 then
                say("You see a pretty, ghostly girl with long black hair. \"Hello, " .. local0 .. ". I am called Paulette. How may I help thee?\"")
            else
                say("Standing before you, with a hand on her hip, is a lovely, young woman with long black hair. \"Ooooh... Thou art a big one, " .. local0 .. ".\" She traces the line of your bicep.~~\"I'd wager thou couldst lift me over thine head.\" She smiles enticingly. However, you doubt that you could even touch her in her ghostly state.~~\"Thou mayest call me Paulette, gorgeous. What can I do for thee?\" She winks at you.")
            end
            set_flag(458, true)
        else
            if not local1 then
                say("\"Yes, " .. local0 .. "?,\" she asks sweetly.")
            else
                say("Paulette turns to face you and smiles coquettishly, \"I had thought that thou might return.\" Her eyes sparkle up at you mischievously.")
            end
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                say("\"Why, " .. local0 .. ", hast thou forgotten already? I am Paulette.\"")
                remove_answer("name")
            elseif answer == "job" then
                if not local1 then
                    say("\"Well, " .. local0 .. ", before the fire,\" she shudders, \"I used to be the barmaid here.\"")
                else
                    say("\"Well, " .. local0 .. ". I used to clean tables here...\" As she says this, she bends over and pretends to wipe a table clean. You notice how low the cut of her bodice really is.~~\"...and serve people, like thyself. Of course, none so handsome.\" Her ghostly features blush prettily.~~\"But that was before,\" she shudders, \"the fire.\"")
                end
                add_answer("buy")
                if not local5 then
                    add_answer("here")
                end
                if not local4 then
                    add_answer("fire")
                end
            elseif answer == "buy" then
                say("\"Thou dost wish to purchase something?\"")
                local8 = get_answer()
                if local8 then
                    say("\"I am sorry, " .. local0 .. ",\" she giggles, \"but all we serve here are... spirits!\"*")
                    local9 = switch_talk_to(-140)
                    if local9 and get_flag(436) then
                        switch_talk_to(-140, 0)
                        say("\"That's a good one, wench,\" laughs the portly ghost.*")
                        hide_npc(-140)
                        switch_talk_to(-145, 0)
                    end
                else
                    say("\"Very well, " .. local0 .. ".\"")
                end
                remove_answer("buy")
            elseif answer == "Tortured One" then
                say("She appears puzzled for an instant, but then she nods her head.~~\"Oh, thou must be referring to Caine. He was the alchemist who was responsible for the fire.\"")
                remove_answer("Tortured One")
                if not local4 then
                    add_answer("fire")
                end
            elseif answer == "fire" then
                say("\"Oh, yes. It was horrible! The tavern caught on fire. I ran to my room, hoping to escape the flames. But then I started coughing. I couldn't breathe.\" Her chest rises and falls quickly as if she's reliving the experience.~~\"Finally, I could take it no longer.\" She brings the back of her hand to her forehead, dramatically. \"I fainted. Then I was here again, just like thou dost see me now.\" Her smile is like that of a child.")
                local4 = true
                remove_answer("fire")
                add_answer("here again")
                if not local5 then
                    add_answer("tavern")
                end
            elseif answer == "here again" then
                say("\"Yes, 'twas quite odd. When I awoke, it was as if I had never left when the fire began. In fact, were it not for the scorch marks everywhere, I would doubt the fire ever happened.\"")
                remove_answer("here again")
            elseif answer == "here" or answer == "tavern" then
                if not local1 then
                    local10 = " coyly"
                else
                    local10 = ""
                end
                say("\"Why, 'tis called the Keg O' Spirits. That's a fine name for a tavern, dost thou not agree?\" She smiles " .. local10 .. ".")
                remove_answer({"tavern", "here"})
                local5 = true
            elseif answer == "sacrifice" then
                if not get_flag(411) then
                    say("\"Thou wantest me to... to jump in a well?\" Her eyes widen with astonishment.")
                    local11 = get_answer()
                    if local11 then
                        say("\"Well, thou canst go jump in a lake!\" She crosses her arms on her buxom chest and turns away from you angrily.*")
                        set_flag(411, true)
                        return
                    else
                        say("She recovers her composure, \"Oh. For a moment there, I thought that thou wouldst have me be thy... sacrifice.\"")
                    end
                else
                    say("\"Please, just leave me alone!\" she looks as if she's about to cry.*")
                    set_flag(420, true)
                    return
                end
                remove_answer("sacrifice")
            elseif answer == "bye" then
                if not local1 then
                    say("\"Goodbye, " .. local0 .. ".\" The pretty ghost turns away.*")
                else
                    say("Paulette rushes up to you as you say goodbye and gives you a little kiss on the cheek. She backs away slowly, \"Farewell, handsome.\"*")
                end
                break
            end
        end
    elseif eventid == 0 then
        return
    end
    return
end