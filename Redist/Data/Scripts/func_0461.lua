--- Best guess: Handles dialogue with Mikos, the foreman of the Minoc mine, discussing the mine’s operations, machinery, miners (Owings, Malloy, and Fodus), and reacting defensively to mentions of the “silver fluid” Fodus referenced.
function func_0461(eventid, objectref)
    local var_0000, var_0001, var_0002

    start_conversation()
    if eventid == 0 then
        abort()
    end
    switch_talk_to(97, 0)
    var_0000 = unknown_003BH() --- Guess: Checks game state or timer
    if var_0000 == 7 then
        var_0001 = unknown_08FCH(81, 97) --- Guess: Checks NPC time interaction
        if var_0001 then
            add_dialogue("Mikos is lost in meditation at the Fellowship meeting and does not hear you.")
        else
            add_dialogue("\"I must run to the Fellowship meeting! I shall speak with thee another time!\"")
        end
        abort()
    end
    var_0002 = get_lord_or_lady()
    if not get_flag(284) then
        add_dialogue("A sneering man watches as you approach. His eyes shift back and forth suspiciously.")
        set_flag(284, true)
    else
        add_dialogue("Mikos heaves his shoulders and sighs. \"What dost thou want this time?\"")
    end
    add_answer({"bye", "job", "name"})
    if get_flag(263) then
        add_answer("silver fluid")
    end
    while true do
        var_0003 = get_answer()
        if var_0003 == "name" then
            add_dialogue("\"I am Mikos.\"")
            remove_answer("name")
        elseif var_0003 == "job" then
            add_dialogue("\"I am the foreman of the Minoc mine.\"")
            add_answer({"mine", "Minoc"})
        elseif var_0003 == "Minoc" then
            add_dialogue("He spits on the ground. \"A pox on them! Down here I am safe from all of their arguing. Next, they will be killing each other.\"")
            remove_answer("Minoc")
        elseif var_0003 == "mine" then
            add_dialogue("\"This mine is run by the Britannian Mining Company. It is inside what was once the dungeon Covetous. They mine for iron ore, lead and other minerals with highly trained miners and special mining machinery.\"")
            remove_answer("mine")
            add_answer({"machinery", "miners"})
        elseif var_0003 == "miners" then
            add_dialogue("\"Currently most of the miners are away as the machines are being repaired. Right now we have two engineers, Owings and Malloy, down in a branch of the main tunnel. Do not disturb them, for they are involved in a special project. We also have a gargoyle, Fodus, who is helping to maintain a semblance of the mine's usual operations.\"")
            remove_answer("miners")
            add_answer("Owings and Malloy")
        elseif var_0003 == "machinery" then
            add_dialogue("\"This place is full of machinery that is very dangerous if thou dost not know what thou art doing. Thou dost not wish to see what one of those digging contraptions can do to a man if he gets too close!\"")
            remove_answer("machinery")
        elseif var_0003 == "Owings and Malloy" then
            add_dialogue("Mikos shakes his head slowly. \"I am not sure where the Britannian Mining Company found them.\"")
            remove_answer("Owings and Malloy")
        elseif var_0003 == "silver fluid" then
            add_dialogue("You repeat the words to Mikos that you heard Fodus say. Mikos gives you a shocked look. \"I have no idea what he is talking about, but I would say it is typical for a gargoyle. Just trying to shirk of his duty. Say, thou hadst better leave this place if thou ist spending all thy time disrupting the work of the mine!\"")
            abort()
        elseif var_0003 == "bye" then
            break
        end
    end
    add_dialogue("\"Do not wander around down here, " .. var_0002 .. ". Thou shouldst leave right away.\"")
end