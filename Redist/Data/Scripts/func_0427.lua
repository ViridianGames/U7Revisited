-- Manages Neno's dialogue in Britain, covering bard ambitions, music studies, and The Avatars performances.
function func_0427(eventid, itemref)
    local local0, local1

    if eventid == 1 then
        switch_talk_to(39, 0)
        local0 = get_schedule()

        if local0 == 7 then
            local1 = get_item_type(-54)
            if local1 then
                add_dialogue("Neno is busy performing with The Avatars and cannot speak at the moment.*")
                return
            else
                add_dialogue("\"I must get to my performance at The Blue Boar! The Avatars are playing tonight!\"*")
                return
            end
        end

        add_answer({"bye", "job", "name"})

        if not get_flag(168) then
            add_dialogue("You see a handsome and flamboyant musician.")
            set_flag(168, true)
        end
        add_dialogue("\"Hello,\" Neno says.")

        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("The musician nods at you. \"I am Neno.\"")
                remove_answer("name")
            elseif answer == "job" then
                add_dialogue("\"I am studying to be the greatest bard that Britannia has ever known. I probably already -am- the greatest bard Britannia has ever known.\" You note that Neno is not at all modest.")
                add_answer({"studying", "bard"})
            elseif answer == "bard" then
                add_dialogue("\"It is a great honor to be a bard. Thou art someone who gives pleasure to other people, while at the same time fulfilling a creative urge within thyself. It is truly magical. I know this from mine experience playing with The Avatars.\"")
                remove_answer("bard")
                add_answer("The Avatars")
            elseif answer == "studying" then
                add_dialogue("\"The Music Hall provides a great environment for study. Judith is a wonderful teacher, and the opportunities here are of the highest quality. One day I shall travel the world and entertain the common folk and nobles alike.\"")
                remove_answer("studying")
                add_answer("entertain")
            elseif answer == "entertain" then
                add_dialogue("\"It is my dream to be famous throughout the land. I shall tour the country every year, and play in the largest pubs in every town.\" He winks at you. \"I shall be assured of wooing the women, dost thou not think?\"")
                remove_answer("entertain")
            elseif answer == "The Avatars" then
                add_dialogue("\"'Tis a singing group I play with. We play at The Blue Boar every evening. Please, come listen to us.\" Neno leans in to whisper, \"But I plan to begin performing alone very soon. I am obviously the most talented member of the quartet.\"")
                remove_answer("The Avatars")
            elseif answer == "bye" then
                add_dialogue("\"Farewell! Thou must watch the postings for our performance dates!\"*")
                break
            end
        end
    elseif eventid == 0 then
        switch_talk_to(39)
    end
    return
end