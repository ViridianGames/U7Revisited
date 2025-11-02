--- Best guess: Handles dialogue with Neno, an ambitious bard and member of The Avatars, boasting about his talent and aspirations to perform solo and tour Britannia.
function npc_neno_0039(eventid, objectref)
    local var_0000, var_0001

    start_conversation()
    if eventid == 1 then
        switch_talk_to(39)
        var_0000 = get_schedule(39) --- Guess: Checks game state or timer
        if var_0000 == 7 then
            var_0001 = npc_id_in_party(54) --- Guess: Checks player status
            if var_0001 then
                add_dialogue("Neno is busy performing with The Avatars and cannot speak at the moment.")
            else
                add_dialogue("\"I must get to my performance at The Blue Boar! The Avatars are playing tonight!\"")
            end
            abort()
        end
        add_answer({"bye", "job", "name"})
        if not get_flag(168) then
            add_dialogue("You see a handsome and flamboyant musician.")
            set_flag(168, true)
        else
            add_dialogue("\"Hello,\" Neno says.")
        end
        while true do
            var_0000 = get_answer()
            if var_0000 == "name" then
                add_dialogue("The musician nods at you. \"I am Neno.\"")
                remove_answer("name")
            elseif var_0000 == "job" then
                add_dialogue("\"I am studying to be the greatest bard that Britannia has ever known. I probably already -am- the greatest bard Britannia has ever known.\" You note that Neno is not at all modest.")
                add_answer({"studying", "bard"})
            elseif var_0000 == "bard" then
                add_dialogue("\"It is a great honor to be a bard. Thou art someone who gives pleasure to other people, while at the same time fulfilling a creative urge within thyself. It is truly magical. I know this from mine experience playing with The Avatars.\"")
                remove_answer("bard")
                add_answer("The Avatars")
            elseif var_0000 == "studying" then
                add_dialogue("\"The Music Hall provides a great environment for study. Judith is a wonderful teacher, and the opportunities here are of the highest quality. One day I shall travel the world and entertain the common folk and nobles alike.\"")
                remove_answer("studying")
                add_answer("entertain")
            elseif var_0000 == "entertain" then
                add_dialogue("\"It is my dream to be famous throughout the land. I shall tour the country every year, and play in the largest pubs in every town.\" He winks at you. \"I shall be assured of wooing the women, dost thou not think?\"")
                remove_answer("entertain")
            elseif var_0000 == "The Avatars" then
                add_dialogue("\"'Tis a singing group I play with. We play at The Blue Boar every evening. Please, come listen to us.\" Neno leans in to whisper, \"But I plan to begin performing alone very soon. I am obviously the most talented member of the quartet.\"")
                remove_answer("The Avatars")
            elseif var_0000 == "bye" then
                break
            end
        end
        add_dialogue("\"Farewell! Thou must watch the postings for our performance dates!\"")
    elseif eventid == 0 then
        utility_unknown_1070(39) --- Guess: Triggers a game event
    end
end