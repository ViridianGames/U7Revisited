require "U7LuaFuncs"
-- Manages Judith's dialogue in Britain, covering music teaching, The Avatars performances, and marriage issues with Patterson.
function func_0428(eventid, itemref)
    local local0, local1

    if eventid == 1 then
        switch_talk_to(-40, 0)
        local0 = get_schedule()

        if local0 == 7 then
            local1 = get_item_type(-54)
            if local1 then
                say("Judith is busy performing with The Avatars and cannot speak at the moment.*")
                return
            else
                say("\"I must run! I am late for my performance with The Avatars! I shall talk with thee later!\"*")
                return
            end
        end

        add_answer({"bye", "job", "name"})

        if not get_flag(169) then
            say("You see an attractive middle-aged woman with music in her eyes.")
            set_flag(169, true)
        end
        say("\"Hello!\" Judith says.")

        while true do
            local answer = get_answer()
            if answer == "name" then
                say("\"I am Judith. And I already know who thou art!\"")
                remove_answer("name")
            elseif answer == "job" then
                say("\"I teach music at The Music Hall. I also fatten my purse a bit by playing with The Avatars!\"")
                add_answer({"The Avatars", "Music Hall", "music"})
            elseif answer == "music" then
                say("\"Music is my life. I know I will never be a famous bard, but I receive great pleasure from playing and performing. I enjoy teaching as well.\"")
                remove_answer("music")
                add_answer("teaching")
            elseif answer == "Music Hall" then
                say("\"Lord British appointed me music teacher a couple of years ago. It is a wonderful job!\"")
                remove_answer("Music Hall")
            elseif answer == "The Avatars" then
                say("\"We are a singing group. We play at the Blue Boar every evening. Please come and hear us! My pupil, Neno, is in the group. We hope to tour the country next year, if we can raise the funds.\"")
                remove_answer("The Avatars")
            elseif answer == "teaching" then
                say("\"It fulfills my life's purpose to teach others. It also gives me time away from home.\"")
                remove_answer("teaching")
                add_answer("home")
            elseif answer == "home" then
                say("\"Oh, I do not want to speak about mine home. Mine husband and I... well, we are not altogether... happy.\"")
                remove_answer("home")
                add_answer("husband")
            elseif answer == "husband" then
                say("\"Thou mightest know him. He is Patterson, the Town Mayor. He is an intelligent and honest man, but we have our differences.~~\"I do not know why I am telling thee all of this!\"")
                remove_answer("husband")
                add_answer("differences")
            elseif answer == "differences" then
                say("\"Well, for one thing, he is a member of that group, The Fellowship. Another thing is that he does not spend too much time at home. I cannot believe he works so much.\"")
                set_flag(129, true)
                remove_answer("differences")
                add_answer({"works", "Fellowship"})
            elseif answer == "Fellowship" then
                say("\"They seem to have taken over our lives. They seem to have taken over our country!\"")
                remove_answer("Fellowship")
            elseif answer == "works" then
                say("\"He is always saying he has to work late. Some nights he comes home before dawn. Other nights he is out the entire night.~~\"Well, I must not think about it. I only become saddened. I must concentrate on my music.\"")
                remove_answer("works")
            elseif answer == "bye" then
                say("Judith goes back to her instrument after a smile and a wave.*")
                break
            end
        end
    elseif eventid == 0 then
        switch_talk_to(-40)
    end
    return
end