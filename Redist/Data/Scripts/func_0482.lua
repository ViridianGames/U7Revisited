--- Best guess: Handles dialogue with Boris, the innkeeper of The Modest Damsel in New Magincia, managing Dupre’s bar tab, serving food, drinks, and rooms, and reluctantly addressing a stolen locket.
function func_0482(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F

    start_conversation()
    if eventid == 1 then
        switch_talk_to(130, 0)
        var_0000 = get_lord_or_lady()
        var_0001 = get_schedule() --- Guess: Checks game state
        var_0002 = unknown_001CH(130) --- Guess: Gets object state
        add_answer({"bye", "job", "name"})
        if not get_flag(384) then
            add_answer("strangers")
        end
        if not get_flag(381) then
            add_answer("locket")
        end
        if not get_flag(405) then
            add_dialogue("\"Art thou ready to pay thy bill?\"")
            if select_option() then
                var_0004 = get_party_gold() --- Guess: Counts items
                if var_0004 >= 74 then
                    var_0005 = unknown_002BH(true, 359, 359, 644, 74) --- Guess: Deducts item and adds item
                    if var_0005 then
                        switch_talk_to(4, 0)
                        add_dialogue("\"I thank thee, Avatar.\"")
                        add_dialogue("You hand the gold over to Boris.")
                        set_flag(405, false)
                        switch_talk_to(130, 0)
                        add_dialogue("\"'Tis a pleasure to do business with thee, Sir Dupre! And welcome to my pub!\"")
                        hide_npc(4)
                        switch_talk_to(130, 0)
                    else
                        add_dialogue("\"Hmmm, where did our gold go?\"")
                        set_flag(405, true)
                        abort()
                    end
                else
                    add_dialogue("\"I am afraid are pockets are too empty!\"")
                    set_flag(405, true)
                    abort()
                end
            else
                add_dialogue("\"Goodbye, then!\"")
                abort()
            end
        else
            add_dialogue("You see a leering, ill-postured man who chortles to himself.")
            set_flag(395, true)
            if var_0002 == 23 then
                var_0003 = npc_id_in_party(4) --- Guess: Checks player status
                if var_0003 then
                    add_dialogue("\"Well if it isn't Dupre! -Sir- Dupre now, is it?\"")
                    switch_talk_to(4, 0)
                    add_dialogue("\"That it is, Boris.\"")
                    switch_talk_to(130, 0)
                    add_dialogue("\"Hmmm-- it seems to me thou dost have a tab still going here? Yes?\"")
                    switch_talk_to(4, 0)
                    add_dialogue("\"Oh? Do I?\"")
                    switch_talk_to(130, 0)
                    add_dialogue("\"Yes indeed! Let me see... I believe the total that thou dost owe is 74 gold pieces. I am afraid that thou must pay up before I can speak with thee or anyone else with thee.\"")
                    switch_talk_to(4, 0)
                    add_dialogue("Dupre looks embarrassed. He turns to you. \"My friend, wilt thou help me out?\"")
                    if select_option() then
                        var_0004 = get_party_gold() --- Guess: Counts items
                        if var_0004 >= 74 then
                            var_0005 = unknown_002BH(true, 359, 359, 644, 74) --- Guess: Deducts item and adds item
                            if var_0005 then
                                switch_talk_to(4, 0)
                                add_dialogue("\"I thank thee, Avatar.\"")
                                add_dialogue("You hand the gold over to Boris.")
                                set_flag(405, false)
                                switch_talk_to(130, 0)
                                add_dialogue("\"'Tis a pleasure to do business with thee, Sir Dupre! And welcome to my pub!\"")
                                hide_npc(4)
                                switch_talk_to(130, 0)
                            else
                                add_dialogue("\"Hmmm, where did our gold go?\"")
                                set_flag(405, true)
                                abort()
                            end
                        else
                            add_dialogue("\"I am afraid are pockets are too empty!\"")
                            set_flag(405, true)
                            abort()
                        end
                    else
                        switch_talk_to(130, 0)
                        add_dialogue("\"Well, I wilt not be serving thee or speaking to thee until thy bill is paid!\"")
                        set_flag(405, true)
                        abort()
                    end
                end
            else
                add_dialogue("\"Hello again,\" says Boris.")
            end
        end
        while true do
            var_0006 = get_answer()
            if var_0006 == "name" then
                add_dialogue("\"Call me Boris.\"")
                remove_answer("name")
            elseif var_0006 == "job" then
                add_dialogue("\"I run The Modest Damsel, here in New Magincia.\"")
                add_answer({"New Magincia", "Modest Damsel"})
            elseif var_0006 == "Modest Damsel" then
                if var_0002 == 23 then
                    add_dialogue("\"It is a little inn and tavern. I am the owner, along with my wife, Magenta. Wouldst thou like something to eat or drink, or perhaps a room?\"")
                    add_answer({"room", "eat or drink", "Magenta"})
                else
                    add_dialogue("\"The Modest Damsel is now closed for business. But do please return during business hours.\"")
                end
                remove_answer("Modest Damsel")
            elseif var_0006 == "Magenta" then
                add_dialogue("\"She became the mayor of New Magincia after the death of the old mayor, her father, several years ago. She has done such a good job that no one has opposed her for the position yet.\"")
                remove_answer("Magenta")
            elseif var_0006 == "eat or drink" then
                add_dialogue("\"I am certain thou wilt enjoy our food and drink.\"")
                unknown_0855H() --- Guess: Serves food or drink
            elseif var_0006 == "room" then
                add_dialogue("\"Why dost thou not stay the night? For but 3 gold thou canst let one of our rooms. Dost thou wish to stay the night?\"")
                if select_option() then
                    var_0007 = unknown_0023H() --- Guess: Gets party members
                    var_0008 = 0
                    while true do
                        var_0008 = var_0008 + 1
                        if var_0008 >= var_0007 then break end
                    end
                    var_000B = var_0008 * 3
                    var_000C = get_party_gold() --- Guess: Counts items
                    if var_000C >= var_000B then
                        var_000D = unknown_002CH(true, 359, 255, 641, 1) --- Guess: Checks inventory space
                        if var_000D then
                            add_dialogue("\"Here is thy room key. 'Twill only work in this inn.\"")
                            var_000E = unknown_002BH(true, 359, 359, 644, var_000B) --- Guess: Deducts item and adds item
                        else
                            add_dialogue("\"Sorry, " .. var_0000 .. ", thou must remove some of thy load before I can give thee the room key.\"")
                        end
                    else
                        add_dialogue("\"Thou hast not enough gold for my rooms.\"")
                    end
                else
                    add_dialogue("\"Some other evening, perhaps.\"")
                end
                remove_answer("room")
            elseif var_0006 == "New Magincia" then
                add_dialogue("\"In all of Britannia thou shalt not find a place that changes so little. Even the people always seem the same.\"")
                add_answer("people")
                remove_answer("New Magincia")
            elseif var_0006 == "people" then
                add_dialogue("\"There are merchants and laborers, as well as a few new folks.\"")
                add_answer({"new folks", "laborers", "merchants"})
                remove_answer("people")
            elseif var_0006 == "merchants" then
                add_dialogue("\"They would be Russell, the shipwright; Henry, the peddler; and Sam, the flower man.\"")
                add_answer({"Sam", "Henry", "Russell"})
                remove_answer("merchants")
            elseif var_0006 == "laborers" then
                add_dialogue("\"They would be Katrina, the shepherd, and Constance, the water carrier.\"")
                add_answer({"Constance", "Katrina"})
                remove_answer("laborers")
            elseif var_0006 == "new folks" then
                add_dialogue("\"Except for the three strangers, the only relatively new person on the island is Alagner, the sage.\"")
                add_answer({"strangers", "Alagner"})
                remove_answer("new folks")
            elseif var_0006 == "Alagner" then
                add_dialogue("\"Alagner is not from New Magincia, of course, but has settled here after studying the world, for he well knows the value of our peace and solitude.\"")
                remove_answer("Alagner")
            elseif var_0006 == "Russell" then
                add_dialogue("\"A brilliant artist and craftsman, Russell cares little for wealth or notoriety. He is content simply building his fine ships and watching them sail.\"")
                remove_answer("Russell")
            elseif var_0006 == "Katrina" then
                add_dialogue("\"Katrina has come to the aid of the people of this town on more than one occasion. She gets an interesting smile on her face whenever thy name is mentioned.\"")
                var_000F = npc_id_in_party(9) --- Guess: Checks player status
                if var_000F then
                    switch_talk_to(9, 0)
                    add_dialogue("\"That is because the Avatar is one my dearest friends.\"")
                    switch_talk_to(130, 0)
                    add_dialogue("\"Am I not one of thy dearest friends, Katrina?\"")
                    switch_talk_to(9, 0)
                    add_dialogue("\"Thou art a flirt, Boris! Dost Magenta know how thou dost want to be dearest friends with the other women living on the island?\"")
                    switch_talk_to(130, 0)
                    add_dialogue("\"Thou dost torture me, Katrina!\" He laughs.")
                    hide_npc(9)
                    switch_talk_to(130, 0)
                end
                remove_answer("Katrina")
            elseif var_0006 == "Henry" then
                add_dialogue("\"Henry's parents were so poor it is a wonder he did not starve to death. I think Constance kept him going. He has loved her since they were children.\"")
                remove_answer("Henry")
            elseif var_0006 == "Constance" then
                add_dialogue("\"Constance is an orphan who was raised mostly by Katrina. Her innocence is surpassed only by her beauty. She is loved by all.\" Boris stares off into space for a few seconds before coming to his senses.")
                remove_answer("Constance")
            elseif var_0006 == "Sam" then
                add_dialogue("Boris laughs. \"Thou wouldst have to meet Sam for thyself. He is an incredible person who is perfecting the art of enjoying life.\"")
                remove_answer("Sam")
            elseif var_0006 == "strangers" then
                add_dialogue("\"A shipwreck has brought three strangers to our island. Rumour has it one of them is a monied gentleman from Buccaneer's Den, and the other two are his hired swords. They were in here drinking one night. They are not the sort of crowd I would wish to serve at mine establishment.\"")
                set_flag(384, true)
                remove_answer("strangers")
            elseif var_0006 == "locket" then
                if get_flag(383) then
                    add_dialogue("\"I do not wish to hear of that locket ever again! Do not speak to me of it!\"")
                    abort()
                elseif not get_flag(389) then
                    add_dialogue("\"I am quite certain I have never seen such a locket. I shall be happy to keep mine eyes open, though.\"")
                    set_flag(387, true)
                elseif not get_flag(382) then
                    add_dialogue("You tell Boris what you had heard from the pirate, Battles. He breaks out into a cold sweat. \"Thou hast seen through my deception. I shall hand it over to thee.\" He opens a secret panel from behind the bar and looks inside. When he looks back to you his face has lost all color. \"The locket is gone! I swear to thee, I know not where it is!\"")
                    set_flag(382, true)
                else
                    add_dialogue("\"I still have not been able to find the locket!\" Boris looks as if he is about to tear his hair out, \"But I will keep looking until I find it!\"")
                end
                remove_answer("locket")
            elseif var_0006 == "bye" then
                break
            end
        end
        add_dialogue("\"Good journey!\"")
    elseif eventid == 0 then
        unknown_092EH(130) --- Guess: Triggers a game event
    end
end