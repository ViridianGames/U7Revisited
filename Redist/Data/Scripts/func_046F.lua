-- Manages Gharl's dialogue in a jail cell, covering his hunting lifestyle and a secret about a troll ally.
function func_046F(eventid, itemref)
    local local0, local1, local2, local3

    if eventid == 1 then
        switch_talk_to(-111, 0)
        local0 = get_answer({"Avatar"})
        local1 = get_player_name()

        add_answer({"bye", "job", "name"})

        if not get_flag(329) then
            say("You see a troll, sulking in his cell. As he breathes, you can see his ribs protrude out from under his hide.")
        else
            say("\"What you want?\" growls Gharl.")
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                say("\"I Gharl.\"")
                remove_answer("name")
            elseif answer == "job" then
                say("He shakes his head. \"No job. Hunt. Eat. Sleep. Now,\" he gestures around the cell, \"no hunt, no eat, just sleep.\"")
                add_answer({"sleep", "eat", "hunt"})
            elseif answer == "hunt" then
                say("\"I good hunter. Catch many things.\"")
                remove_answer("hunt")
            elseif answer == "sleep" then
                say("\"I still do that,\" he says, shrugging. \"But not as good as when home.\"")
                remove_answer("sleep")
                add_answer("home")
            elseif answer == "home" then
                say("He stares at you oddly and says, \"With other trolls, fleshface! Under bridges.\"")
                remove_answer("home")
            elseif answer == "eat" then
                say("\"No eat.\" He shakes his head. \"Not feed. Hate jailer!\" he growls.")
                remove_answer("eat")
                add_answer("offer food")
            elseif answer == "offer food" then
                say("\"You give me food?\" His face displays a mixture of surprise and hope. \"You give me food, I tell you secret. Yes?\"")
                local2 = get_answer()
                if local2 then
                    local3 = remove_item(-359, -359, 377, 1) -- Unmapped intrinsic
                    if local3 then
                        say("He quickly devours the food.~~\"I thank. You want secret?\"")
                        add_answer("secret")
                    else
                        say("\"You taunt me. I not like you.\"*")
                        return
                    end
                else
                    say("\"Go away.\"*")
                    return
                end
                remove_answer("offer food")
            elseif answer == "secret" then
                say("\"Trolls have powerful ally. He warn us in head when trouble around corner.\"")
                remove_answer("secret")
            elseif answer == "bye" then
                say("He grunts and turns away.*")
                break
            end
        end
    elseif eventid == 0 then
        return
    end
    return
end