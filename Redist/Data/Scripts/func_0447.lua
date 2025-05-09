--- Best guess: Handles dialogue with Inwisloklem, a gargoyle on the Great Council, discussing gargoyle heritage, integration efforts, and the Fellowship, with references to Miranda’s work on a new law.
function func_0447(eventid, itemref)
    start_conversation()
    if eventid == 1 then
        switch_talk_to(71, 0)
        add_answer({"bye", "job", "name"})
        if not get_flag(200) then
            add_dialogue("A winged gargoyle looks at you with interest and obvious intelligence.")
            add_dialogue("\"To welcome thee to Britain, Avatar!\"")
            set_flag(200, true)
        else
            add_dialogue("\"To greet thee again, Avatar!\" Inwisloklem smiles.")
        end
        while true do
            var_0000 = get_answer()
            if var_0000 == "name" then
                add_dialogue("\"To be called Inwisloklem.\"")
                remove_answer("name")
                add_answer("Inwisloklem")
            elseif var_0000 == "Inwisloklem" then
                add_dialogue("\"To mean `interpreter' in your language.\"")
                remove_answer("Inwisloklem")
            elseif var_0000 == "job" then
                add_dialogue("\"To be, indeed, an interpreter in my homeland. To be now on the Great Council to serve our most noble ruler, Lord British. To be honored as one of the two gargoyles on the Council.\"")
                add_answer({"Great Council", "gargoyles"})
            elseif var_0000 == "gargoyles" then
                add_dialogue("\"To be one of the surviving gargoyles, and to preserve our heritage is my life work. To tell you our race emigrated to Britannia many, many years ago. To have settled on the island known as Terfin.\"")
                add_answer({"Terfin", "surviving"})
                remove_answer("gargoyles")
            elseif var_0000 == "surviving" then
                add_dialogue("\"To be so many of my people killed two hundred years ago in the War of the False Prophet. To be the war that you ended by bringing peace between our races.\"")
                remove_answer("surviving")
            elseif var_0000 == "Terfin" then
                add_dialogue("\"To be a lonely place. To be desolate. To be not what humans call `homey'. To desire to establish a new way of life for gargoyles in Britannia, and to eliminate the hatred and misunderstanding of our race in humans. To know that ignorance breeds bigotry. To be one of those who are correcting this.\"")
                add_answer({"those", "way of life"})
                remove_answer("Terfin")
            elseif var_0000 == "way of life" then
                add_dialogue("\"To desire a world where humans and gargoyles could live together in peace as equals in Britannian society.\"")
                remove_answer("way of life")
            elseif var_0000 == "those" then
                add_dialogue("\"To be called The Fellowship.\"")
                add_answer("Fellowship")
                remove_answer("those")
            elseif var_0000 == "Fellowship" then
                add_dialogue("\"To be dedicated to promoting good will and trust in the land. To be thinking of joining the group soon!\"")
                remove_answer("Fellowship")
            elseif var_0000 == "Great Council" then
                add_dialogue("\"To create the laws of the land. To inform you that my colleague, Miranda, can tell you more of what we are doing now. To be unfortunate that most of the Council is away now.\"")
                add_answer({"away", "Miranda"})
                remove_answer("Great Council")
            elseif var_0000 == "Miranda" then
                add_dialogue("\"To inform you that Miranda is an intelligent woman who has great concern for the well being of all of Britannia's citizens. To be one of Lord British's most trusted advisors.\"")
                remove_answer("Miranda")
            elseif var_0000 == "away" then
                add_dialogue("\"To be on holiday at the moment. To have only Miranda and myself present to enact this new law.\"")
                add_answer("law")
                remove_answer("away")
            elseif var_0000 == "law" then
                add_dialogue("\"To tell you to ask Miranda about it, for she knows more than I.\"")
                remove_answer("law")
            elseif var_0000 == "bye" then
                break
            end
        end
        add_dialogue("\"To say farewell.\"")
    elseif eventid == 0 then
        unknown_092FH(71) --- Guess: Triggers gargoyle-specific event
    end
end