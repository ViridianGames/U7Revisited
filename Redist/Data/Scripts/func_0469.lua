--- Best guess: Handles dialogue with Sir Jeff, the High Court official at Yew’s Abbey prison, discussing his judicial role, the prisoners (a pirate and a troll), and his distrust of the jailer Goth.
function func_0469(eventid, objectref)
    local var_0000, var_0001

    start_conversation()
    if eventid == 1 then
        switch_talk_to(105, 0)
        var_0000 = get_lord_or_lady()
        add_answer({"bye", "job", "name"})
        if not get_flag(323) then
            add_dialogue("The man greets you with stern, suspicious eyes.")
            set_flag(323, true)
        else
            add_dialogue("\"What is thy business, " .. var_0000 .. "?\"")
        end
        while true do
            var_0001 = get_answer()
            if var_0001 == "name" then
                add_dialogue("\"I am Sir Jeff, " .. var_0000 .. ".\"")
                remove_answer("name")
            elseif var_0001 == "job" then
                add_dialogue("\"I am the High Court official at the prison here in the Abbey.\"")
                add_answer({"Abbey", "official"})
            elseif var_0001 == "official" then
                add_dialogue("\"I am the judiciary part of Britannia's government. It is my job to see that criminals are brought to justice.\"")
                add_answer("criminals")
                remove_answer("official")
            elseif var_0001 == "criminals" then
                add_dialogue("\"We have two prisoners already, but there are many scoundrels who still roam free.\"")
                add_answer({"scoundrels", "prisoners"})
                remove_answer("criminals")
            elseif var_0001 == "prisoners" then
                add_dialogue("\"Thou, of course, hast never met them,\" he says, his brow narrowing, \"but we have a pirate, and,\" he pauses, \"a troll. If thou dost wish to see them, speak with Goth, the jailer.\"")
                add_answer("Goth")
                remove_answer("prisoners")
            elseif var_0001 == "scoundrels" then
                add_dialogue("\"See for thyself, the posted bills for known villains are in the log book in the courtroom.\"")
                remove_answer("scoundrels")
            elseif var_0001 == "Goth" then
                add_dialogue("\"He has only been working here for a few weeks, but I already know he is not trustworthy. There is something obviously unscrupulous about him. He is not a friend of thine, is he?\"")
                var_0001 = select_option()
                if var_0001 then
                    add_dialogue("\"I suspected as much.\" He turns away from you.")
                    abort()
                else
                    add_dialogue("\"No,\" he says, watching you closely, \"of course he is not.\"")
                end
                remove_answer("Goth")
            elseif var_0001 == "Abbey" then
                add_dialogue("\"The monks live and study there, but they do little more than winemaking. Well, I know one of them tends the garden.\"")
                remove_answer("Abbey")
            elseif var_0001 == "bye" then
                break
            end
        end
        add_dialogue("\"Keep thine heart and mind on the straight path, " .. var_0000 .. ".\"")
    elseif eventid == 0 then
        abort()
    end
end