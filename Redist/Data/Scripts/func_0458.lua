--- Best guess: Handles dialogue with Seara, a clockmaker in Minoc’s Artist’s Guild, discussing the Guild, the murders of Frederico and Tania, Sasha’s involvement with the Fellowship, and the controversy over Owen’s monument.
function func_0458(eventid, itemref)
    local var_0000, var_0001, var_0002

    start_conversation()
    if eventid == 1 then
        switch_talk_to(88, 0)
        var_0000 = get_lord_or_lady()
        var_0001 = unknown_0067H() --- Guess: Checks Fellowship membership
        var_0002 = unknown_003BH() --- Guess: Checks game state or timer
        if not get_flag(275) then
            add_dialogue("You see a handsome, creative-looking young man.")
            set_flag(275, true)
        else
            add_dialogue("\"Greetings, " .. var_0000 .. ",\" says Seara.")
        end
        add_answer({"bye", "job", "name"})
        while true do
            var_0003 = get_answer()
            if var_0003 == "name" then
                add_dialogue("\"I am called Seara, " .. var_0000 .. ". A pleasure to meet thee.\"")
                remove_answer("name")
            elseif var_0003 == "job" then
                if not get_flag(287) then
                    add_dialogue("\"I am a member of our local Artist's Guild here in Minoc.\"")
                    add_answer({"Minoc", "Artist's Guild"})
                else
                    add_dialogue("\"Please, " .. var_0000 .. ", now is not the time to speak in such a casual way! Why, not far from this very spot there have been not one, but two murders committed!\"")
                    set_flag(287, true)
                    add_answer("murders")
                end
            elseif var_0003 == "Artist's Guild" then
                add_dialogue("\"Yes, we have an Artist's Guild here in Minoc. I am a member. The other members are Xanthia and Gladstone. Thou canst purchase some of the finest crafts available anywhere in Britannia there. I, for example, make clocks.\"")
                add_answer({"clocks", "Gladstone", "Xanthia"})
                remove_answer("Artist's Guild")
            elseif var_0003 == "Xanthia" then
                add_dialogue("\"Xanthia is a very talented young woman. She makes very elaborate and distinctive candelabras.\"")
                remove_answer("Xanthia")
            elseif var_0003 == "Gladstone" then
                add_dialogue("\"Gladstone is a sculptor and a glassblower. He also is in charge of most of the business decisions for the Guild.\"")
                remove_answer("Gladstone")
            elseif var_0003 == "clocks" then
                add_dialogue("\"I make all types of clocks and watches that tell the time reliably to the second. I would be happy to sell thee one but right now I have a two year backlog to fill.\"")
                remove_answer("clocks")
            elseif var_0003 == "Minoc" then
                add_dialogue("\"Until the monument was to be built and now these murders I believed this town to be a good place to live.\"")
                remove_answer("Minoc")
                add_answer({"murders", "monument"})
            elseif var_0003 == "murders" then
                add_dialogue("\"It is horrible. Frederico and Tania were looking for their son, Sasha. He had run away to join the Fellowship. How could this have happened to them?\" Seara slowly shakes his head.")
                remove_answer("murders")
                add_answer("Sasha")
            elseif var_0003 == "Sasha" then
                if not get_flag(255) then
                    add_dialogue("\"I met him a few weeks ago when he came to town looking for the local Fellowship branch. I once let him stay the night at the Guild Hall. He said his father would beat him if he knew he was thinking of joining The Fellowship and I believed him. Sasha's father could be a cruel man. He is basically a good lad, just looking for the truth like a lot of us are. Unfortunately, he is looking in the wrong place.\"")
                    remove_answer("Sasha")
                    add_answer({"Fellowship", "gypsies"})
                    set_flag(255, true)
                else
                    add_dialogue("\"I have not seen or heard of Sasha since we last spoke of him. I do not know if he ever joined The Fellowship.\"")
                    remove_answer("Sasha")
                    add_answer("Fellowship")
                end
            elseif var_0003 == "gypsies" then
                add_dialogue("\"Their camp is just outside of town. There are not too many of them left. I understand that Sasha's aunt, Margareta, is an amazing fortune teller. For a few gold coins, she can tell thee many things that may be very useful to thee.\"")
                remove_answer("gypsies")
            elseif var_0003 == "Fellowship" then
                if var_0001 then
                    add_dialogue("\"No offense intended to thee, but I do not share thy beliefs. In fact I think few of the members of thy Fellowship are sincere in all their talk of unity, trust and worthiness. But Sasha is old enough to make up his mind for himself, though I regret not sending him home that night.\"")
                else
                    unknown_0919H() --- Guess: Explains Fellowship philosophy
                    add_dialogue("\"No, I am not a member or anything like that, but I have heard the basic speech from Sasha so many times that I have it memorized. I never tried to dissuade him from joining The Fellowship even though I have no belief in it. I think Sasha is old enough to start making his decisions for himself. Now I truly regret not sending him home the moment I saw him.\"")
                    remove_answer("philosophy")
                end
                remove_answer("Fellowship")
            elseif var_0003 == "monument" then
                add_dialogue("\"That shipwright Owen is a self-righteous fool. His statue will be nothing more than a monument to all the hurtful bad feelings he has caused in this town. I cannot believe that such a meaningless and obvious charade could jeopardize our Guild's future.\"")
                remove_answer("monument")
                add_answer("future")
            elseif var_0003 == "future" then
                add_dialogue("\"Thou hadst best ask Gladstone about that.\"")
                remove_answer("future")
            elseif var_0003 == "bye" then
                break
            end
        end
        add_dialogue("\"A pleasant day to thee, " .. var_0000 .. ". Do come see us again.\"")
    elseif eventid == 0 then
        unknown_092EH(88) --- Guess: Triggers a game event
    end
end