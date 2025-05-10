--- Best guess: Manages Elad’s dialogue in Moonglow, discussing his role as a healer, the community, and his desire to leave.
function func_04A2(eventid, itemref)
    local var_0000, var_0001, var_0002

    if eventid == 1 then
        switch_talk_to(0, 162)
        var_0000 = unknown_0908H()
        var_0001 = get_lord_or_lady()
        start_conversation()
        add_answer({"bye", "job", "name"})
        if not get_flag(516) then
            add_dialogue("The man looks at you through smiling eyes.")
        else
            add_dialogue("Elad bows in your direction. \"My pleasure to see thee again.\"")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"Elad is my name, " .. var_0001 .. ".\"")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"I am the healer of the residents of this community.\"")
                add_answer({"community", "heal", "residents"})
            elseif answer == "community" then
                add_dialogue("\"Moonglow is mine home. I have lived in this town for mine entire life. But I am weary of my life here. 'Tis time, I think, to move on. If only I did not have such strong ties here.\" He sighs sadly.")
                if not get_flag(493) then
                    add_dialogue("\"There is a traveller visiting from Yew. He has seen many exciting things in Britannia. I enjoy listening to his many tales of adventure.\"")
                    add_answer("traveller")
                end
                add_answer("ties")
                remove_answer("community")
            elseif answer == "traveller" then
                add_dialogue("\"His name is Addom. While he is in town, I am letting him stay in one of my beds.\"")
                remove_answer("traveller")
            elseif answer == "heal" then
                add_dialogue("\"Yes, I sell mine healing services to those who need them.\"")
                add_answer("services")
                remove_answer("heal")
            elseif answer == "services" then
                var_0002 = unknown_003BH()
                if var_0002 == 2 or var_0002 == 3 or var_0002 == 4 or var_0002 == 6 then
                    unknown_0879H(425, 10, 25)
                else
                    add_dialogue("\"Perhaps thou couldst come for healing when I am working in my shop.\"")
                end
                remove_answer("services")
            elseif answer == "ties" then
                add_dialogue("\"My patients here in Moonglow. Who will help them if not I?\"")
                remove_answer("ties")
            elseif answer == "residents" then
                add_dialogue("\"There are many people in Moonglow. My father once told me that the town was much smaller during his time. In fact, he said that Moonglow used to be separate from the Lycaeum!\" \"But, I digress. Thou didst ask about the people. I know most of the residents here. Dost thou want to know about the Lycaeum, the observatory, The Fellowship, the farmers, the trainer, or the tavern?\"")
                add_answer({"tavern", "trainer", "farmers", "Fellowship", "observatory", "Lycaeum"})
                remove_answer("residents")
            elseif answer == "Lycaeum" then
                add_dialogue("\"The Lycaeum is run by a kind man named Nelson. His advisor is Zelda. Do not break any rules in her presence or thou wilt receive a sharp reprimand!\" \"Jillian also studies there. She can teach thee many things. And do not worry about Mariah. She is harmless if thou wilt but leave her be.\"")
                remove_answer("Lycaeum")
            elseif answer == "observatory" then
                add_dialogue("\"The head there is Brion. He is the twin of the head of the Lycaeum. I like him, although he and his brother are both a little eccentric.\"")
                remove_answer("observatory")
            elseif answer == "Fellowship" then
                add_dialogue("\"I know these people least of all. The branch opened here about five years ago under the direction of a man named Rankin. A few months ago, a clerk joined him. Her name is Balayna.\"")
                remove_answer("Fellowship")
            elseif answer == "farmers" then
                add_dialogue("\"Cubolt owns the farm. He manages it with his younger brother Tolemac and their friend Morz. I am not positive, but I believe Tolemac recently joined The Fellowship.\"")
                remove_answer("farmers")
            elseif answer == "tavern" then
                add_dialogue("\"Phearcy tends the bar there. He is another good person with whom thou shouldst speak about the townspeople. However, he enjoys gossip, and may be a bit single-minded.\"")
                remove_answer("tavern")
            elseif answer == "trainer" then
                add_dialogue("\"The trainer is named Chad. I believe he specializes in swift, skillful fighting, with knives and swords and such. See him if thou wishest to improve thy skills.\"")
                remove_answer("trainer")
            elseif answer == "bye" then
                add_dialogue("\"Leaving so soon, " .. var_0001 .. "? Very well, may thy journeys be filled with prosperity.\" He sighs. Suddenly, his face brightens. \"Wait! Perhaps I could join thee?\" He quickly stands up, smiling. Then, just as suddenly, his smile fades. \"No. I cannot. I have far too many things to do, too many people to care for. Perhaps in the future?\" He forces a smile. \"I hope when we meet next time, " .. var_0001 .. ", I will have the opportunity to join thee. Pleasant journey, my friend.\"")
                break
            end
        end
    elseif eventid == 0 then
        unknown_092EH(162)
    end
    return
end