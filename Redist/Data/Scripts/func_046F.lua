--- Best guess: Manages Gharl’s dialogue, a troll prisoner, discussing his life of hunting and eating, now limited to sleeping in jail, with a flag-based food offering that reveals a secret about a troll ally.
function func_046F(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid ~= 1 then
        if eventid == 0 then
            return
        end
    end

    start_conversation()
    switch_talk_to(0, 111)
    var_0000 = unknown_0908H()
    var_0001 = get_lord_or_lady()
    add_answer({"bye", "job", "name"})
    if not get_flag(329) then
        add_dialogue("You see a troll, sulking in his cell. As he breathes, you can see his ribs protrude out from under his hide.")
    else
        add_dialogue("\"What you want?\" growls Gharl.")
    end
    while true do
        if cmps("name") then
            add_dialogue("\"I Gharl.\"")
            remove_answer("name")
        elseif cmps("job") then
            add_dialogue("He shakes his head. \"No job. Hunt. Eat. Sleep. Now,\" he gestures around the cell, \"no hunt, no eat, just sleep.\"")
            add_answer({"sleep", "eat", "hunt"})
        elseif cmps("hunt") then
            add_dialogue("\"I good hunter. Catch many things.\"")
            remove_answer("hunt")
        elseif cmps("sleep") then
            add_dialogue("\"I still do that,\" he says, shrugging. \"But not as good as when home.\"")
            remove_answer("sleep")
            add_answer("home")
        elseif cmps("home") then
            add_dialogue("He stares at you oddly and says, \"With other trolls, fleshface! Under bridges.\"")
            remove_answer("home")
        elseif cmps("eat") then
            add_dialogue("\"No eat.\" He shakes his head. \"Not feed. Hate jailer!\" he growls.")
            remove_answer("eat")
            add_answer("offer food")
        elseif cmps("offer food") then
            add_dialogue("\"You give me food?\" His face displays a mixture of surprise and hope. \"You give me food, I tell you secret. Yes?\"")
            var_0002 = unknown_090AH()
            if var_0002 then
                var_0003 = unknown_002BH(0, 359, 359, 377, 1)
                if var_0003 then
                    add_dialogue("He quickly devours the food.~~\"I thank. You want secret?\"")
                    add_answer("secret")
                else
                    add_dialogue("\"You taunt me. I not like you.\"")
                    return
                end
            else
                add_dialogue("\"Go away.\"")
                return
            end
            remove_answer("offer food")
        elseif cmps("secret") then
            add_dialogue("\"Trolls have powerful ally. He warn us in head when trouble around corner.\"")
            remove_answer("secret")
        elseif cmps("bye") then
            break
        end
    end
    add_dialogue("He grunts and turns away.")
    return
end