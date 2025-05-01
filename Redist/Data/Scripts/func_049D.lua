-- Manages Tolemac's dialogue in Moonglow, as a farmer and Fellowship member, discussing his brother Cubolt and refusal to reconvert.
function func_049D(eventid, itemref)
    local local0, local1, local2, local3

    if eventid ~= 1 then
        apply_effect(-157) -- Unmapped intrinsic
        return
    end

    switch_talk_to(157, 0)
    local0 = get_player_name()
    local1 = get_random()
    add_answer({"bye", "Fellowship", "job", "name"})

    if get_flag(469) then
        say("\"Get thee away! I'll hear no more of thy lies!\"*")
        return
    end

    if local1 == 7 then
        local2 = check_fellowship(-250, -157) -- Unmapped intrinsic
        if local2 then
            say("\"I am trying to pay attention!\" he says, glaring at you.")
        else
            say("\"Sorry, " .. local0 .. ", I cannot talk now. I must get to the Fellowship meeting!\"")
        end
        return
    end

    if not get_flag(510) then
        say("You see a friendly-looking farmer.")
        set_flag(510, true)
    else
        say("\"Good day, " .. local0 .. ".\"")
    end

    if get_flag(470) and get_flag(510) then
        add_answer("reconvert")
    end

    while true do
        local answer = get_answer()
        if answer == "name" then
            say("\"I am called Tolemac, " .. local0 .. ".\"")
            remove_answer("name")
            if get_flag(470) then
                add_answer("reconvert")
            end
        elseif answer == "job" then
            say("\"I help my brother tend our farm here in Moonglow.\"")
            add_answer({"Moonglow", "brother"})
        elseif answer == "brother" then
            say("\"My brother is Cubolt.\" He frowns for a moment. \"He can be a bit overbearing at times, trying to `take care' of me. But,\" he shrugs, \"he means well, perhaps. I know I've caused him a bit of trouble every now and then,\" he says with a grin, \"but he deserves it.\"")
            remove_answer("brother")
        elseif answer == "Moonglow" then
            say("\"Yes, " .. local0 .. ". That is the name of the town thou art in. Dost thou have questions about the townspeople?\"")
            add_answer("townspeople")
            remove_answer("Moonglow")
        elseif answer == "townspeople" then
            say("\"I know only a few people here, " .. local0 .. ". My brother, Cubolt, runs the farm with me. Morz helps us, too -- we've known him for many years. And now that I've joined The Fellowship, I've met a few more people. Rankin is branch head here in Moonglow, and Balayna is his assistant. If thou dost want to know about other people, thou mayest want to ask the bartender. His name is Phearcy.\"")
            add_answer({"Fellowship", "Rankin", "Balayna", "Morz"})
            remove_answer("townspeople")
        elseif answer == "Rankin" then
            say("\"Rankin is very intelligent. He is the one who persuaded me to join The Fellowship. I have much respect for him.\"")
            remove_answer("Rankin")
        elseif answer == "Balayna" then
            say("\"She is the branch clerk. Most of the time, she is friendly. Sometimes, however, she seems a little cold.\"")
            remove_answer("Balayna")
        elseif answer == "Morz" then
            say("\"Morz and I grew up together. He is very sensitive about his stutter, though, so I would not bring it up.\"")
            add_answer("stutter")
            remove_answer("Morz")
        elseif answer == "stutter" then
            say("\"It is difficult to get him to talk about it. I think it was caused by an accident he had when he was a child. I barely remember the incident. My brother might remember more.\"")
            remove_answer("stutter")
        elseif answer == "Fellowship" then
            say("\"Rankin or Balayna would be the best ones to ask, " .. local0 .. ", but I can tell thee our main tenets.~~\"We believe strongly in neo-realism, which is a form of optimistic outlook which may be reached through the triad of inner strength.~~\"I am hoping that soon I will be able to hear the    voice that comes with meeting one's higher potential.~~\"Also, " .. local0 .. ", The Fellowship sponsors many feasts and festivals. I strongly recommend that thou ask Rankin about joining.\"")
            remove_answer("Fellowship")
        elseif answer == "reconvert" then
            say("\"Reconvert? Why would I want to do that? Did my brother request this? He has always had a problem with letting me make mine own decisions. Nay, " .. local0 .. ". I will not abandon my beliefs. The Fellowship has done too much for my life.\"")
            local3 = get_answer()
            if local3 then
                say("\"And to think thou art a fellow member. There is no unity in thy speech!\"")
            end
            say("*")
            set_flag(469, true)
            return
        elseif answer == "bye" then
            say("\"'Til next time, " .. local0 .. ".\"*")
            break
        end
    end
    return
end