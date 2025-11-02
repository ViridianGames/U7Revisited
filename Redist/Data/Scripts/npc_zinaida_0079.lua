--- Best guess: Manages Zinaida's dialogue, the owner of The Emerald in Cove, discussing her tavern, her love for De Maria, and the polluted Lock Lake, with flag-based food and drink transactions.
function npc_zinaida_0079(eventid, objectref)
    local var_0000

    if eventid ~= 1 then
        if eventid == 0 then
            utility_unknown_1070(79)
        end
        add_dialogue("\"Come again soon!\"")
        return
    end

    start_conversation()
    switch_talk_to(79)
    var_0000 = get_schedule_type(get_npc_name(79))
    add_answer({"bye", "job", "name"})
    if not get_flag(228) then
        add_answer("De Maria")
    end
    if not get_flag(236) then
        add_dialogue("This beautiful, earthy woman in her forties gives you a friendly smile.")
        set_flag(236, true)
    else
        add_dialogue("\"Hello,\" Zinaida says.")
    end
    if not get_flag(228) then
        add_answer("De Maria")
    end
    set_flag(241, true)
    while true do
        if cmps("name") then
            add_dialogue("\"I am Zinaida,\" she says with a curtsey.")
            remove_answer("name")
        elseif cmps("job") then
            add_dialogue("\"I am the owner and manager of The Emerald.\"")
            if var_0000 == 23 then
                add_dialogue("\"If I can help thee with food or drink, please say so. I have never had a dissatisfied customer.\"")
                add_answer({"buy", "food", "drink"})
            else
                add_dialogue("\"Please come to the pub when it is open and I shall be happy to serve thee!\"")
            end
        elseif cmps("food") then
            add_dialogue("\"The Emerald is pleased to serve thee the finest cuisine this side of Britain. Thou mightest wish to try the special -- Silverleaf.\"")
            add_answer("Silverleaf")
        elseif cmps("Silverleaf") then
            add_dialogue("She winks at you. \"Some say it is a powerful aphrodisiac... It is delicious, regardless. It comes from the root of an exotic tree growing somewhere in Britannia.\"")
            remove_answer("Silverleaf")
        elseif cmps("drink") then
            add_dialogue("\"The Emerald serves only the best wine and ale. I cannot recommend the water, however. Thanks to Lock Lake.\"")
            add_answer("Lock Lake")
        elseif cmps("buy") then
            utility_unknown_1105()
        elseif cmps("De Maria") then
            add_dialogue("\"He is the light of my life. A finer man does not exist.\" She beams.")
            remove_answer("De Maria")
        elseif cmps("Lock Lake") then
            add_dialogue("\"The stench has made our water taste terrible. That mining company must cease pouring their sewage into what was once a fine lake!\"")
            remove_answer("Lock Lake")
        elseif cmps("bye") then
            break
        end
    end
    return
end