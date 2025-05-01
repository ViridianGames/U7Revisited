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
    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x0204) then
        say("The man looks at you through smiling eyes.")
        set_flag(0x0204, true)
    else
        say("Elad bows in your direction.\"My pleasure to see thee again.\"")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"Elad is my name, ", local1, ".\"")
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("\"I am the healer of the residents of this community.\"")
            _AddAnswer({"community", "heal", "residents"})
        elseif answer == "community" then
            say("\"Moonglow is mine home. I have lived in this town for mine entire life. But I am weary of my life here. 'Tis time, I think, to move on. If only I did not have such strong ties here.\"He sighs sadly.")
            if not get_flag(0x01ED) then
                say("\"There is a traveller visiting from Yew. He has seen many exciting things in Britannia. I enjoy listening to his many tales of adventure.\"")
                _AddAnswer("traveller")
            end
            _AddAnswer("ties")
            _RemoveAnswer("community")
        elseif answer == "traveller" then
            say("\"His name is Addom. While he is in town, I am letting him stay in one of my beds.\"")
            _RemoveAnswer("traveller")
        elseif answer == "heal" then
            say("\"Yes, I sell mine healing services to those who need them.\"")
            _AddAnswer("services")
            _RemoveAnswer("heal")
        elseif answer == "services" then
            local2 = callis_003B()
            if local2 == 2 or local2 == 3 or local2 == 4 or local2 == 6 then
                call_0879H(425, 10, 25)
            else
                say("\"Perhaps thou couldst come for healing when I am working in my shop.\"")
            end
            _RemoveAnswer("services")
        elseif answer == "ties" then
            say("\"My patients here in Moonglow. Who will help them if not I?\"")
            _RemoveAnswer("ties")
        elseif answer == "residents" then
            say("\"There are many people in Moonglow. My father once told me that the town was much smaller during his time. In fact, he said that Moonglow used to be separate from the Lycaeum!~~But, I digress. Thou didst ask about the people. I know most of the residents here. Dost thou want to know about the Lycaeum, the observatory, The Fellowship, the farmers, the trainer, or the tavern?\"")
            _AddAnswer({"1234({"tavern", "trainer", "farmers", "Fellowship", "observatory", "Lycaeum"})
            _RemoveAnswer("residents")
            _SaveAnswers()
            _AddAnswer({"Lycaeum", "observatory", "Fellowship", "farmers", "trainer", "tavern", "shop keeper", "no one"})
        elseif answer == "Lycaeum" then
            say("\"The Lycaeum is run by a kind man named Nelson. His advisor is Zelda. Do not break any rules in her presence or thou wilt receive a sharp reprimand!~Jillian also studies there. She can teach thee many things. And do not worry about Mariah. She is harmless if thou wilt but leave her be.\"")
            _RemoveAnswer("Lycaeum")
        elseif answer == "observatory" then
            say("\"The head there is Brion. He is the twin of the head of the Lycaeum. I like him, although he and his brother are both a little eccentric.\"")
            _RemoveAnswer("observatory")
        elseif answer == "Fellowship" then
            say("\"I know these people least of all. The branch opened here about five years ago under the direction of a man named Rankin. A few months ago, a clerk joined him. Her name is Balayna.\"")
            _RemoveAnswer("Fellowship")
        elseif answer == "farmers" then
            say("\"Cubolt owns the farm. He manages it with his younger brother Tolemac and their friend Morz. I am not positive, but I believe Tolemac recently joined The Fellowship.\"")
            _RemoveAnswer("farmers")
        elseif answer == "tavern" then
            say("\"Phearcy tends the bar there. He is another good person with whom thou shouldst speak about the townspeople. However, he enjoys gossip, and may be a bit single-minded.\"")
            _RemoveAnswer("tavern")
        elseif answer == "trainer" then
            say("\"The trainer is named Chad. I believe he specializes in swift, skillful fighting, with knives and swords and such. See him if thou wishest to improve thy skills.\"")
            _RemoveAnswer("trainer")
        elseif answer == "shop keeper" then
            say("\"She is a tailor. Lovely woman, that Carlyn. She minds the bar when I go to the Fellowship meetings at night.\"")
            say("But I would rather discuss Zelda.")
            _RemoveAnswer("shop keeper")
        elseif answer == "Jillian" then
            say("\"Wonderful scholar. Very nice woman. Married to Effrem.\"")
            _AddAnswer("Effrem")
            say("But I am more interested in discussing Zelda.")
            _RemoveAnswer("Jillian")
        elseif answer == "Effrem" then
            say("\"Friendly fellow -- I like him.\"")
            say("\"He stays home to care for their son.\"")
            say("But I am more interested in discussing Brion.")
            _RemoveAnswer("Effrem")
        elseif answer == "trainer" then
            say("\"Chad is a friendly fellow -- I like him.\"")
            say("But I would rather discuss Brion.")
            _RemoveAnswer("trainer")
        elseif answer == "farmers" then
            say("\"Tolemac and Cubolt are brothers. With Morz's help, they run a farm.\"")
            say("But I would prefer to talk about Brion.")
            _RemoveAnswer("farmers")
        elseif answer == "healer" then
            say("\"Friendly fellow -- I like him. His name is Elad.\"")
            say("\"Sadly, his true desire is to leave Moonglow in search of adventure. But he will not leave, for he feels too much obligation for his patients.\" Phearcy shrugs.\"Perhaps not without reason.\"")
            say("But Brion is more interesting to me.")
            _RemoveAnswer("healer")
        elseif answer == "Nelson" then
            say("\"He is Brion's twin brother.\"")
            say("Speaking of that, I would like to discuss Brion.")
            _RemoveAnswer("Nelson")
        elseif answer == "charge" then
            say("\"Rankin is in charge of the entire local branch. If thou hast any questions about The Fellowship, he can answer them.\"")
            _RemoveAnswer("charge")
        elseif answer == "clerk" then
            say("\"If thou hast any questions about The Fellowship, Balayna can answer them.\"")
            _RemoveAnswer("clerk")
        elseif answer == "Zelda" or answer == "Brion" then
            if get_flag(0x01D9) then
                say("\"Well, as thou dost know, Brion is the head of Observatory, and Zelda, the advisor at the Lyceaum, is in love with him.\"")
            else
                say("\"Ah, so thou dost wonder, too. All I know is that every time someone mentions Brion's name to Zelda, her serious expression changes to a smile.~~I have a deal for thee. Find out what their story is, and I will give thee and thy friends a free meal and drink. Thou canst find Brion at the observatory and Zelda at the Lycaeum.\"")
                local4 = true
            end
            _RemoveAnswer({"Zelda", "Brion"})
        elseif answer == "no one" then
            _RestoreAnswers()
            _AddAnswer("bye")
        elseif answer == "buy" then
            say("\"Food or drink, ", local1, "?\"")
            _SaveAnswers()
            _AddAnswer({"drink", "food"})
            _RemoveAnswer("buy")
        elseif answer == "food" then
            call_08CBH()
            _RestoreAnswers()
            _RemoveAnswer("food")
        elseif answer == "drink" then
            call_08CCH()
            _RestoreAnswers()
            _RemoveAnswer("drink")
        elseif answer == "bye" then
            say("\"Remember! Tell them thou didst eat at the Friendly Knave!\"")
            break
        end

        -- Note: Original has 'db 40' here, ignored
    end

    return
end

-- Helper functions
function say(...)
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