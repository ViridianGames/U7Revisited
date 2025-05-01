-- Function 04A2: Elad's healer dialogue
function func_04A2(eventid, itemref)
    -- Local variables (3 as per .localc)
    local local0, local1, local2

    if eventid ~= 1 then
        return
    end

    switch_talk_to(162, 0)
    local0 = call_0908H()
    local1 = call_0909H()
    add_answer({"bye", "job", "name"})

    if not get_flag(0x0204) then
        add_dialogue("The man looks at you through smiling eyes.")
        set_flag(0x0204, true)
    else
        add_dialogue("Elad bows in your direction.\"My pleasure to see thee again.\"")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"Elad is my name, ", local1, ".\"")
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("\"I am the healer of the residents of this community.\"")
            add_answer({"community", "heal", "residents"})
        elseif answer == "community" then
            add_dialogue("\"Moonglow is mine home. I have lived in this town for mine entire life. But I am weary of my life here. 'Tis time, I think, to move on. If only I did not have such strong ties here.\"He sighs sadly.")
            if not get_flag(0x01ED) then
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
            local2 = callis_003B()
            if local2 == 2 or local2 == 3 or local2 == 4 or local2 == 6 then
                call_0879H(425, 10, 25)
            else
                add_dialogue("\"Perhaps thou couldst come for healing when I am working in my shop.\"")
            end
            remove_answer("services")
        elseif answer == "ties" then
            add_dialogue("\"My patients here in Moonglow. Who will help them if not I?\"")
            remove_answer("ties")
        elseif answer == "residents" then
            add_dialogue("\"There are many people in Moonglow. My father once told me that the town was much smaller during his time. In fact, he said that Moonglow used to be separate from the Lycaeum!~~But, I digress. Thou didst ask about the people. I know most of the residents here. Dost thou want to know about the Lycaeum, the observatory, The Fellowship, the farmers, the trainer, or the tavern?\"")
            add_answer({"tavern", "trainer", "farmers", "Fellowship","observatory", "Lycaeum"})
            remove_answer("residents")
            _SaveAnswers()
            add_answer({"Lycaeum", "observatory", "Fellowship", "farmers", "trainer", "tavern", "shop keeper", "no one"})
        elseif answer == "Lycaeum" then
            add_dialogue("\"The Lycaeum is run by a kind man named Nelson. His advisor is Zelda. Do not break any rules in her presence or thou wilt receive a sharp reprimand!~Jillian also studies there. She can teach thee many things. And do not worry about Mariah. She is harmless if thou wilt but leave her be.\"")
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
        elseif answer == "shop keeper" then
            add_dialogue("\"She is a tailor. Lovely woman, that Carlyn. She minds the bar when I go to the Fellowship meetings at night.\"")
            add_dialogue("But I would rather discuss Zelda.")
            remove_answer("shop keeper")
        elseif answer == "Jillian" then
            add_dialogue("\"Wonderful scholar. Very nice woman. Married to Effrem.\"")
            add_answer("Effrem")
            add_dialogue("But I am more interested in discussing Zelda.")
            remove_answer("Jillian")
        elseif answer == "Effrem" then
            add_dialogue("\"Friendly fellow -- I like him.\"")
            add_dialogue("\"He stays home to care for their son.\"")
            add_dialogue("But I am more interested in discussing Brion.")
            remove_answer("Effrem")
        elseif answer == "trainer" then
            add_dialogue("\"Chad is a friendly fellow -- I like him.\"")
            add_dialogue("But I would rather discuss Brion.")
            remove_answer("trainer")
        elseif answer == "farmers" then
            add_dialogue("\"Tolemac and Cubolt are brothers. With Morz's help, they run a farm.\"")
            add_dialogue("But I would prefer to talk about Brion.")
            remove_answer("farmers")
        elseif answer == "healer" then
            add_dialogue("\"Friendly fellow -- I like him. His name is Elad.\"")
            add_dialogue("\"Sadly, his true desire is to leave Moonglow in search of adventure. But he will not leave, for he feels too much obligation for his patients.\" Phearcy shrugs.\"Perhaps not without reason.\"")
            add_dialogue("But Brion is more interesting to me.")
            remove_answer("healer")
        elseif answer == "Nelson" then
            add_dialogue("\"He is Brion's twin brother.\"")
            add_dialogue("Speaking of that, I would like to discuss Brion.")
            remove_answer("Nelson")
        elseif answer == "charge" then
            add_dialogue("\"Rankin is in charge of the entire local branch. If thou hast any questions about The Fellowship, he can answer them.\"")
            remove_answer("charge")
        elseif answer == "clerk" then
            add_dialogue("\"If thou hast any questions about The Fellowship, Balayna can answer them.\"")
            remove_answer("clerk")
        elseif answer == "Zelda" or answer == "Brion" then
            if get_flag(0x01D9) then
                add_dialogue("\"Well, as thou dost know, Brion is the head of Observatory, and Zelda, the advisor at the Lyceaum, is in love with him.\"")
            else
                add_dialogue("\"Ah, so thou dost wonder, too. All I know is that every time someone mentions Brion's name to Zelda, her serious expression changes to a smile.~~I have a deal for thee. Find out what their story is, and I will give thee and thy friends a free meal and drink. Thou canst find Brion at the observatory and Zelda at the Lycaeum.\"")
                local4 = true
            end
            remove_answer({"Zelda", "Brion"})
        elseif answer == "no one" then
            _RestoreAnswers()
            add_answer("bye")
        elseif answer == "buy" then
            add_dialogue("\"Food or drink, ", local1, "?\"")
            _SaveAnswers()
            add_answer({"drink", "food"})
            remove_answer("buy")
        elseif answer == "food" then
            call_08CBH()
            _RestoreAnswers()
            remove_answer("food")
        elseif answer == "drink" then
            call_08CCH()
            _RestoreAnswers()
            remove_answer("drink")
        elseif answer == "bye" then
            add_dialogue("\"Remember! Tell them thou didst eat at the Friendly Knave!\"")
            break
        end

        -- Note: Original has 'db 40' here, ignored
    end

    return
end

-- Helper functions
function add_dialogue(...)
    print(table.concat({...}))
end

function wait_for_answer()
    return "bye" -- Placeholder
end

function get_flag(flag)
    return false -- Placeholder
end

function set_flag(flag, value)
    -- Placeholder
end

function _SaveAnswers()
    -- Placeholder for saving answers
end

function _RestoreAnswers()
    -- Placeholder for restoring answers
end