--- Best guess: Manages Tolemac's dialogue, a Moonglow farmer and Fellowship member, discussing his farm, brother Cubolt, and friend Morz, with flag-based reactions to reconversion attempts and Fellowship membership.
function npc_tolemac_0157(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid ~= 1 then
        if eventid == 0 then
            utility_unknown_1070(157)
        end
        return
    end

    start_conversation()
    switch_talk_to(157)
    var_0000 = get_lord_or_lady()
    var_0001 = get_schedule(157)
    add_answer({"bye", "Fellowship", "job", "name"})
    if get_flag(469) then
        add_dialogue("\"Get thee away! I'll hear no more of thy lies!\"")
        return
    end
    if var_0001 == 7 then
        var_0002 = utility_unknown_1020(-250, 157)
        if var_0002 then
            add_dialogue("\"I am trying to pay attention!\" he says, glaring at you.")
        else
            add_dialogue("\"Sorry, " .. var_0000 .. ", I cannot talk now. I must get to the Fellowship meeting!\"")
        end
        return
    end
    if not get_flag(510) then
        add_dialogue("You see a friendly-looking farmer.")
        set_flag(510, true)
    else
        add_dialogue("\"Good day, " .. var_0000 .. ".\"")
    end
    if get_flag(470) and get_flag(510) then
        add_answer("reconvert")
    end
    while true do
        if cmps("name") then
            add_dialogue("\"I am called Tolemac, " .. var_0000 .. ".\"")
            remove_answer("name")
            if not get_flag(470) then
                add_answer("reconvert")
            end
        elseif cmps("job") then
            add_dialogue("\"I help my brother tend our farm here in Moonglow.\"")
            add_answer({"Moonglow", "brother"})
        elseif cmps("brother") then
            add_dialogue("\"My brother is Cubolt.\" He frowns for a moment. \"He can be a bit overbearing at times, trying to `take care' of me. But,\" he shrugs, \"he means well, perhaps. I know I've caused him a bit of trouble every now and then,\" he says with a grin, \"but he deserves it.\"")
            remove_answer("brother")
        elseif cmps("Moonglow") then
            add_dialogue("\"Yes, " .. var_0000 .. ". That is the name of the town thou art in. Dost thou have questions about the townspeople?\"")
            add_answer("townspeople")
            remove_answer("Moonglow")
        elseif cmps("townspeople") then
            add_dialogue("\"I know only a few people here, " .. var_0000 .. ". My brother, Cubolt, runs the farm with me. Morz helps us, too -- we've known him for many years. And now that I've joined The Fellowship, I've met a few more people. Rankin is branch head here in Moonglow, and Balayna is his assistant. If thou dost want to know about other people, thou mayest want to ask the bartender. His name is Phearcy.\"")
            add_answer({"Fellowship", "Rankin", "Balayna", "Morz"})
            remove_answer("townspeople")
        elseif cmps("Rankin") then
            add_dialogue("\"Rankin is very intelligent. He is the one who persuaded me to join The Fellowship. I have much respect for him.\"")
            remove_answer("Rankin")
        elseif cmps("Balayna") then
            add_dialogue("\"She is the branch clerk. Most of the time, she is friendly. Sometimes, however, she seems a little cold.\"")
            remove_answer("Balayna")
        elseif cmps("Morz") then
            add_dialogue("\"Morz and I grew up together. He is very sensitive about his stutter, though, so I would not bring it up.\"")
            add_answer("stutter")
            remove_answer("Morz")
        elseif cmps("stutter") then
            add_dialogue("\"It is difficult to get him to talk about it. I think it was caused by an accident he had when he was a child. I barely remember the incident. My brother might remember more.\"")
            remove_answer("stutter")
        elseif cmps("Fellowship") then
            add_dialogue("\"Rankin or Balayna would be the best ones to ask, " .. var_0000 .. ", but I can tell thee our main tenets.~~\"We believe strongly in neo-realism, which is a form of optimistic outlook which may be reached through the triad of inner strength.~~\"I am hoping that soon I will be able to hear the voice that comes with meeting one's higher potential.~~\"Also, " .. var_0000 .. ", The Fellowship sponsors many feasts and festivals. I strongly recommend that thou ask Rankin about joining.\"")
            remove_answer("Fellowship")
        elseif cmps("reconvert") then
            add_dialogue("\"Reconvert? Why would I want to do that? Did my brother request this? He has always had a problem with letting me make mine own decisions. Nay, " .. var_0000 .. ". I will not abandon my beliefs. The Fellowship has done too much for my life.\"")
            var_0003 = is_player_wearing_fellowship_medallion()
            if var_0003 then
                add_dialogue("\"And to think thou art a fellow member. There is no unity in thy speech!\"")
            end
            add_dialogue("*")
            set_flag(469, true)
            return
        elseif cmps("bye") then
            break
        end
    end
    add_dialogue("\"'Til next time, " .. var_0000 .. ".\"")
end