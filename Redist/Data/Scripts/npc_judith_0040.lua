--- Best guess: Handles dialogue with Judith, a music teacher and member of The Avatars, discussing her teaching, performances, and strained marriage to Patterson, the mayor.
function npc_judith_0040(eventid, objectref)
    local var_0000, var_0001

    start_conversation()
    if eventid == 1 then
        switch_talk_to(40, 0)
        var_0000 = get_schedule() --- Guess: Checks game state or timer
        if var_0000 == 7 then
            var_0001 = npc_id_in_party(54) --- Guess: Checks player status
            if var_0001 then
                add_dialogue("Judith is busy performing with The Avatars and cannot speak at the moment.")
            else
                add_dialogue("\"I must run! I am late for my performance with The Avatars! I shall talk with thee later!\"")
            end
            abort()
        end
        add_answer({"bye", "job", "name"})
        if not get_flag(169) then
            add_dialogue("You see an attractive middle-aged woman with music in her eyes.")
            set_flag(169, true)
        else
            add_dialogue("\"Hello!\" Judith says.")
        end
        while true do
            var_0000 = get_answer()
            if var_0000 == "name" then
                add_dialogue("\"I am Judith. And I already know who thou art!\"")
                remove_answer("name")
            elseif var_0000 == "job" then
                add_dialogue("\"I teach music at The Music Hall. I also fatten my purse a bit by playing with The Avatars!\"")
                add_answer({"The Avatars", "Music Hall", "music"})
            elseif var_0000 == "music" then
                add_dialogue("\"Music is my life. I know I will never be a famous bard, but I receive great pleasure from playing and performing. I enjoy teaching as well.\"")
                remove_answer("music")
                add_answer("teaching")
            elseif var_0000 == "Music Hall" then
                add_dialogue("\"Lord British appointed me music teacher a couple of years ago. It is a wonderful job!\"")
                remove_answer("Music Hall")
            elseif var_0000 == "The Avatars" then
                add_dialogue("\"We are a singing group. We play at the Blue Boar every evening. Please come and hear us! My pupil, Neno, is in the group. We hope to tour the country next year, if we can raise the funds.\"")
                remove_answer("The Avatars")
            elseif var_0000 == "teaching" then
                add_dialogue("\"It fulfills my life's purpose to teach others. It also gives me time away from home.\"")
                remove_answer("teaching")
                add_answer("home")
            elseif var_0000 == "home" then
                add_dialogue("\"Oh, I do not want to speak about mine home. Mine husband and I... well, we are not altogether... happy.\"")
                add_dialogue("\"I do not know why I am telling thee all of this!\"")
                remove_answer("home")
                add_answer("husband")
            elseif var_0000 == "husband" then
                add_dialogue("\"Thou mightest know him. He is Patterson, the Town Mayor. He is an intelligent and honest man, but we have our differences.\"")
                remove_answer("husband")
                add_answer("differences")
            elseif var_0000 == "differences" then
                add_dialogue("\"Well, for one thing, he is a member of that group, The Fellowship. Another thing is that he does not spend too much time at home. I cannot believe he works so much.\"")
                set_flag(129, true)
                remove_answer("differences")
                add_answer({"works", "Fellowship"})
            elseif var_0000 == "Fellowship" then
                add_dialogue("\"They seem to have taken over our lives. They seem to have taken over our country!\"")
                remove_answer("Fellowship")
            elseif var_0000 == "works" then
                add_dialogue("\"He is always saying he has to work late. Some nights he comes home before dawn. Other nights he is out the entire night.\"")
                add_dialogue("\"Well, I must not think about it. I only become saddened. I must concentrate on my music.\"")
                remove_answer("works")
            elseif var_0000 == "bye" then
                break
            end
        end
        add_dialogue("Judith goes back to her instrument after a smile and a wave.")
    elseif eventid == 0 then
        utility_unknown_1070(40) --- Guess: Triggers a game event
    end
end