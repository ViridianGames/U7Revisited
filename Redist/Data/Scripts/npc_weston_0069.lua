--- Best guess: Handles dialogue with Weston, a prisoner in Britain's jail, discussing his theft of apples, poverty in Paws, and social inequities, asking the player to appeal to Lord British for his release.
function npc_weston_0069(eventid, objectref)
    local var_0000, var_0001

    start_conversation()
    if eventid == 0 then
        abort()
    end
    switch_talk_to(69)
    var_0000 = get_lord_or_lady()
    add_answer({"bye", "job", "name"})
    var_0001 = find_nearest(1, 394, 356) --- Guess: Checks player identity
    if not get_flag(198) then
        add_dialogue("You see a thoroughly disheartened young man who is miserably languishing behind bars.")
        set_flag(198, true)
    else
        add_dialogue("\"Hello again, " .. var_0000 .. ",\" says Weston.")
    end
    while true do
        var_0002 = get_answer()
        if var_0002 == "name" then
            add_dialogue("\"I am Weston.\"")
            remove_answer("name")
        elseif var_0002 == "job" then
            add_dialogue("\"I have none so long as I am left to rot here in this prison.\"")
            if var_0001 then
                switch_talk_to(258)
                add_dialogue("\"Thy job is to pay for the crime thou hast committed.\"")
                hide_npc(258)
                switch_talk_to(69)
            end
            add_answer("prison")
        elseif var_0002 == "prison" then
            add_dialogue("\"My crime was stealing apples from the Royal Orchards. This I did and I admit it freely. If given the same set of circumstances I would do it again.\"")
            if var_0001 then
                switch_talk_to(258)
                add_dialogue("\"A-ha! Not only an unrepentant criminal but also a potential professional thief! Looks like this one has ended in the right place and just in the nick o' time.\"")
                hide_npc(258)
                switch_talk_to(69)
            end
            remove_answer("prison")
            add_answer({"circumstances", "stealing apples"})
        elseif var_0002 == "stealing apples" then
            add_dialogue("\"I had offered to buy them first, but Figg, the caretaker of the orchard, set an exorbitant price which I am certain he would have pocketed for himself. So, yes, I admit to stealing them.\"")
            if var_0001 then
                switch_talk_to(258)
                add_dialogue("\"See how the common criminal blames his type of immoral behavior on others, all the while denying it in himself! This one is irredeemable, he is.\"")
                hide_npc(258)
                switch_talk_to(69)
            end
            remove_answer("stealing apples")
            add_answer({"admit", "Figg"})
        elseif var_0002 == "Figg" then
            add_dialogue("\"He gives baskets of fruit free to The Fellowship without Lord British's consent, I am quite certain.\"")
            set_flag(148, true)
            if var_0001 then
                switch_talk_to(258)
                add_dialogue("\"Thou shouldst not listen to this obvious slander, " .. var_0000 .. "! It is hearsay!\"")
                hide_npc(258)
                switch_talk_to(69)
            end
            remove_answer("Figg")
        elseif var_0002 == "admit" then
            add_dialogue("\"Mine only regrets are that I did not try to steal something bigger and that I did not get away with it.\"")
            remove_answer("admit")
        elseif var_0002 == "circumstances" then
            add_dialogue("\"I am not from Britain, " .. var_0000 .. ". I am from Paws and it is another reason why they believe I can be trifled with.\"")
            if var_0001 then
                switch_talk_to(258)
                add_dialogue("\"This prisoner is from Paws! I bloody knew it! To his credit he was in town nearly an entire day before he stole something. For a citizen of Paws that is as honest as they come!\"")
                hide_npc(258)
                switch_talk_to(69)
            end
            remove_answer("circumstances")
            add_answer("Paws")
        elseif var_0002 == "Paws" then
            add_dialogue("\"Paws is a town where thou mayest feel the icy grip of poverty about thine heart.\"")
            remove_answer("Paws")
            add_answer({"poverty", "town"})
            if var_0001 then
                switch_talk_to(258)
                add_dialogue("\"Oh bloody 'ell! Now I suppose he is going to go and tell us his whole pathetic life's story! Couldst thou wait until I get out mine handkerchief so I do not interrupt thee with all my wailing!\"")
                hide_npc(258)
                switch_talk_to(69)
            end
        elseif var_0002 == "town" then
            add_dialogue("\"Not so long ago Paws was a thriving rustic coastal village. But as Britain grew larger most of our local businesses moved there. We became a farming town and the seven year drought gave us a lashing that we have yet to recover from.\"")
            remove_answer("town")
        elseif var_0002 == "poverty" then
            add_dialogue("\"I do not wish to bemoan my fate, but my family lives in Paws -- my wife Alina and my child Cassie. They were starving and I came to Britain to get food for them.\"")
            if var_0001 then
                switch_talk_to(258)
                add_dialogue("\"Oh, now! Do not go and bring up poverty as an excuse as to why thou hast turned to crime! My father was so poor he and his family had to eat dirt. But he still raised me proper. Beat the stuffings out of me if he ever so much as imagined I did anything wrong, I can tell thee that!\"")
                hide_npc(258)
                switch_talk_to(69)
            end
            remove_answer("poverty")
            add_answer({"starving", "family"})
        elseif var_0002 == "family" then
            add_dialogue("\"I do not want any mercy for myself. I have admitted my guilt. But my life does not only belong to myself. It belongs to my wife and family as well. Without me they will suffer unbearable hardships, such as they might not survive.\"")
            remove_answer("family")
        elseif var_0002 == "starving" then
            add_dialogue("\"Although there are fools who will speak otherwise, the people of Britannia are being crushed by the vicious tyranny of the class system. While a few have more than they could ever enjoy, there are many who go to sleep hungry every night. My wife and daughter to name two of them.\"")
            if var_0001 then
                switch_talk_to(258)
                add_dialogue("\"Oh, that reminds me it is nearly time for my meal break! The trout is supposed to be delicious today at the Farmer's Market.\"")
                hide_npc(258)
                switch_talk_to(69)
            end
            remove_answer("starving")
            add_answer({"class system", "fools"})
        elseif var_0002 == "fools" then
            add_dialogue("\"Fools like our good friend the guard would have us believe that nothing has changed in Britannia for over two hundred years. That we can live our lives as if all of our problems do not exist. I say to thee that it is people like that who cause our problems in the first place.\"")
            remove_answer("fools")
        elseif var_0002 == "class system" then
            add_dialogue("\"While I am certain Lord British is a just and fair ruler, he must be quite unaware of all that goes on in his kingdom. Surely he would not tolerate such inequity.\"")
            if var_0001 then
                switch_talk_to(258)
                add_dialogue("\"All right! That is enough noise out of thee! All day long yakkata-yakkata about the awful terrible class system! Why, the next thing thou knowest thou shalt be sayin' society is to blame for thy crimes. Not a word from anybody about any appreciation for keeping the laws and order. No, of course not! But all the pity in the world for the dangerous lawbreakers who are the real threat to society.\"")
                hide_npc(258)
                switch_talk_to(69)
            end
            add_dialogue("\"Wouldst thou speak with Lord British about me? I would bet that he is completely unaware of my case! Please! Wilt thou speak with him?\"")
            var_0002 = select_option()
            if var_0002 then
                add_dialogue("\"Oh, I thank thee, Avatar! My fate and the fates of my wife and daughter are in thine hands!\"")
                set_flag(205, true)
            else
                add_dialogue("Weston lowers his head. \"Then why art thou speaking with me? Go away and leave me to my misery.\"")
                abort()
            end
            remove_answer("class system")
        elseif var_0002 == "bye" then
            break
        end
    end
    add_dialogue("\"I thank thee for visiting me.\"")
end