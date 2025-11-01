--- Best guess: Handles dialogue with Paulette, a ghostly barmaid in the Keg O' Spirits tavern on Skara Brae, discussing her past job, the fire that killed her, and her flirtatious interactions. Includes refusal to be a sacrifice for the Well of Souls.
function npc_paulette_0145(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B

    start_conversation()
    if eventid == 1 then
        switch_talk_to(145)
        var_0000 = get_lord_or_lady()
        var_0001 = is_player_female()
        var_0002 = get_schedule() --- Guess: Checks game state
        var_0003 = get_schedule_type(145) --- Guess: Gets schedule
        var_0004 = false
        var_0005 = false
        add_answer({"bye", "job", "name"})
        if not get_flag(380) then
            add_answer("Tortured One")
        end
        if not get_flag(441) then
            add_dialogue("The lovely apparition goes about her tasks without offering any response.")
            abort()
        end
        if not get_flag(426) then
            if var_0002 == 0 or var_0002 == 1 then
                if var_0003 == 14 then
                    add_dialogue("The lovely barmaid stares off into oblivion, completely unaware of her location and position.")
                    abort()
                elseif var_0003 ~= 11 then
                    add_dialogue("The pretty barmaid looks as if she's about to fall over for a moment, then quickly rights herself. \"Oh, I feel a bit... faint.\" She turns away, distracted.")
                    abort()
                end
            end
        end
        if get_flag(420) then
            add_dialogue("\"Go away! Thou art cruel and mean-hearted.\" She turns away, but not before you see the tears in her eyes.")
            abort()
        end
        var_0006 = npc_id_in_party(144) --- Guess: Checks player status
        if var_0006 then
            if not get_flag(446) then
                add_dialogue("Paulette perks up as she sees Rowena.")
                add_dialogue("\"Hello, milady. 'Tis good to see thee again. How art thou?\"")
                switch_talk_to(144)
                add_dialogue("\"I am fine, Paulette. I thank thee for thy concern.\"")
                hide_npc(144)
                switch_talk_to(145)
                add_dialogue("\"'Tis good news indeed, milady.\"")
                set_flag(446, true)
            end
        end
        var_0007 = npc_id_in_party(147) --- Guess: Checks player status
        if var_0007 then
            if not get_flag(445) then
                add_dialogue("\"Hello, Mayor. It has been quite a while since we've seen thee in our tavern. There was a time, I remember, when we couldn't keep thee away.\"")
                switch_talk_to(147)
                add_dialogue("The mayor becomes quickly embarrassed as he tries to quiet the rather friendly Paulette.")
                add_dialogue("\"I, er, used to be a wine connoisseur of sorts,\" he says to you.")
                hide_npc(147)
                switch_talk_to(145)
                add_dialogue("\"'Tis not all thou wert a connoisseur of,\" adds Paulette, eyes twinkling. \"I seem to remember thou had quite a taste for redheads.\"")
                set_flag(445, true)
            end
        end
        if not get_flag(408) then
            add_answer("sacrifice")
        end
        if not get_flag(458) then
            if var_0001 then
                add_dialogue("You see a pretty, ghostly girl with long black hair. \"Hello, " .. var_0000 .. ". I am called Paulette. How may I help thee?\"")
            else
                add_dialogue("Standing before you, with a hand on her hip, is a lovely, young woman with long black hair. \"Ooooh... Thou art a big one, " .. var_0000 .. ".\" She traces the line of your bicep.")
                add_dialogue("\"I'd wager thou couldst lift me over thine head.\" She smiles enticingly. However, you doubt that you could even touch her in her ghostly state.")
                add_dialogue("\"Thou mayest call me Paulette, gorgeous. What can I do for thee?\" She winks at you.")
            end
            set_flag(458, true)
        else
            if var_0001 then
                add_dialogue("\"Yes, " .. var_0000 .. "?\", she asks sweetly.")
            else
                add_dialogue("Paulette turns to face you and smiles coquettishly, \"I had thought that thou might return.\" Her eyes sparkle up at you mischievously.")
            end
        end
        while true do
            var_0008 = get_answer()
            if var_0008 == "name" then
                add_dialogue("\"Why, " .. var_0000 .. ", hast thou forgotten already? I am Paulette.\"")
                remove_answer("name")
            elseif var_0008 == "job" then
                if var_0001 then
                    add_dialogue("\"Well, " .. var_0000 .. ", before the fire,\" she shudders, \"I used to be the barmaid here.\"")
                else
                    add_dialogue("\"Well, " .. var_0000 .. ". I used to clean tables here...\" As she says this, she bends over and pretends to wipe a table clean. You notice how low the cut of her bodice really is.")
                    add_dialogue("\"...and serve people, like thyself. Of course, none so handsome.\" Her ghostly features blush prettily.")
                    add_dialogue("\"But that was before,\" she shudders, \"the fire.\"")
                end
                add_answer("buy")
                if not var_0005 then
                    add_answer("here")
                end
                if not var_0004 then
                    add_answer("fire")
                end
            elseif var_0008 == "buy" then
                add_dialogue("\"Thou dost wish to purchase something?\"")
                var_0009 = select_option()
                if var_0009 then
                    add_dialogue("\"I am sorry, " .. var_0000 .. ",\" she giggles, \"but all we serve here are... spirits!\"")
                    var_000A = npc_id_in_party(140) --- Guess: Checks player status
                    if var_000A and not get_flag(436) then
                        switch_talk_to(140)
                        add_dialogue("\"That's a good one, wench,\" laughs the portly ghost.")
                        hide_npc(140)
                        switch_talk_to(145)
                    end
                else
                    add_dialogue("\"Very well, " .. var_0000 .. ".\"")
                end
                remove_answer("buy")
            elseif var_0008 == "Tortured One" then
                add_dialogue("She appears puzzled for an instant, but then she nods her head.")
                add_dialogue("\"Oh, thou must be referring to Caine. He was the alchemist who was responsible for the fire.\"")
                remove_answer("Tortured One")
                if not var_0004 then
                    add_answer("fire")
                end
            elseif var_0008 == "fire" then
                add_dialogue("\"Oh, yes. It was horrible! The tavern caught on fire. I ran to my room, hoping to escape the flames. But then I started coughing. I couldn't breathe.\" Her chest rises and falls quickly as if she's reliving the experience.")
                add_dialogue("\"Finally, I could take it no longer.\" She brings the back of her hand to her forehead, dramatically. \"I fainted. Then I was here again, just like thou dost see me now.\" Her smile is like that of a child.")
                var_0004 = true
                remove_answer("fire")
                add_answer("here again")
                if not var_0005 then
                    add_answer("tavern")
                end
            elseif var_0008 == "here again" then
                add_dialogue("\"Yes, 'twas quite odd. When I awoke, it was as if I had never left when the fire began. In fact, were it not for the scorch marks everywhere, I would doubt the fire ever happened.\"")
                remove_answer("here again")
            elseif var_0008 == {"here", "tavern"} then
                if var_0001 then
                    var_000B = " coyly"
                else
                    var_000B = ""
                end
                add_dialogue("\"Why, 'tis called the Keg O' Spirits. That's a fine name for a tavern, dost thou not agree?\" She smiles " .. var_000B .. ".")
                remove_answer({"tavern", "here"})
                var_0005 = true
            elseif var_0008 == "sacrifice" then
                if not get_flag(411) then
                    add_dialogue("\"Thou wantest me to... to jump in a well?\" Her eyes widen with astonishment.")
                    var_000B = select_option()
                    if var_000B then
                        add_dialogue("\"Well, thou canst go jump in a lake!\" She crosses her arms on her buxom chest and turns away from you angrily.")
                        set_flag(411, true)
                        abort()
                    else
                        add_dialogue("She recovers her composure, \"Oh. For a moment there, I thought that thou wouldst have me be thy... sacrifice.\"")
                    end
                else
                    add_dialogue("\"Please, just leave me alone!\" she looks as if she's about to cry.")
                    set_flag(420, true)
                    abort()
                end
                remove_answer("sacrifice")
            elseif var_0008 == "bye" then
                break
            end
        end
        if var_0001 then
            add_dialogue("\"Goodbye, " .. var_0000 .. ".\" The pretty ghost turns away.")
        else
            add_dialogue("Paulette rushes up to you as you say goodbye and gives you a little kiss on the cheek. She backs away slowly, \"Farewell, handsome.\"")
        end
    elseif eventid == 0 then
        abort()
    end
end