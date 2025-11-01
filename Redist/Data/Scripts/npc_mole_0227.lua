--- Best guess: Manages Mole's dialogue in Buccaneer's Den, a retired pirate reflecting on his past and Fellowship membership, with a focus on his strained relationship with Blacktooth.
function npc_mole_0227(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006

    if eventid == 1 then
        switch_talk_to(0, 227)
        var_0000 = get_lord_or_lady()
        var_0001 = is_player_wearing_fellowship_medallion()
        var_0002 = get_npc_name(227)
        start_conversation()
        add_answer({"bye", "job", "name"})
        if not get_flag(679) and not get_flag(677) then
            add_answer("He misses thee")
        end
        if not get_flag(688) then
            add_dialogue("You see an aging pirate who might have looked extremely dangerous at one time.")
            set_flag(688, true)
        else
            add_dialogue("\"What is it?\" Mole asks.")
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"My name be Mole, it be! Do not ask me how I came by it. 'Tis a long story.\"")
                remove_answer("name")
                add_answer("story")
            elseif answer == "job" then
                add_dialogue("\"For years and years I roamed the seas, pillaging and raping and terrorizing. Now that I am past the age of fifty, I want to live the rest of my life in relative peace and quiet here on Buccaneer's Den.\"")
                add_answer({"Buccaneer's Den", "peace and quiet"})
            elseif answer == "story" then
                add_dialogue("\"Thou dost really want to hear it? 'Tis very long.\"")
                if ask_yes_no() then
                    add_dialogue("\"All right. I was born in a cave. So my mother named me Mole.\"")
                    var_0003 = npc_id_in_party(1)
                    if var_0003 then
                        switch_talk_to(0, 1)
                        add_dialogue("\"I thought thou said it was a long story.\"")
                        hide_npc(1)
                        switch_talk_to(0, 227)
                    end
                else
                    add_dialogue("\"Very well. How 'bout if I just say that I was born in a cave, so my mother named me Mole.\"")
                end
                add_dialogue("Mole shrugs. \"I thought I would make a long story short.\"")
                remove_answer("story")
            elseif answer == "peace and quiet" then
                add_dialogue("\"It is a good life. I grew weary of pirating. I grew weary of the salt water and the raw meat and the sewage on deck and the parrot droppings and the fact that every other word one heard was 'Har!'\"")
                remove_answer("peace and quiet")
            elseif answer == "Buccaneer's Den" then
                add_dialogue("\"I spend my time at the House of Games or the Fallen Virgin. I love the sound of the die as it bounces against the felt. I love the taste of warm ale as it splashes down my throat! And... I have The Fellowship.\"")
                remove_answer("Buccaneer's Den")
                add_answer("Fellowship")
            elseif answer == "Fellowship" then
                add_dialogue("\"The group has given me a new lease on life. I thought I had mates when I was an active pirate, but they were nothing compared to my brothers in The Fellowship.\"")
                if var_0001 then
                    add_dialogue("\"Say, I see that thou art a member! Thou must be of sound character!\"")
                end
                add_dialogue("\"Mine old mates, like my friend Blacktooth, have fallen by the wayside.\"")
                remove_answer("Fellowship")
                add_answer({"mates", "Blacktooth"})
            elseif answer == "Blacktooth" then
                add_dialogue("\"Blacktooth lives here on the island. We used to be the same link on a chain, knowest what I mean? But since I joined The Fellowship, he does not give me the shadow of a sundial! He acts as though I had the plague or something. I do not understand it. Makes me want to cut something up into mincemeat!\"")
                remove_answer("Blacktooth")
            elseif answer == "mates" then
                add_dialogue("\"Blacktooth was like my brother. Not like my brothers in The Fellowship, but a 'real' brother, knowest what I mean? We did 'everything' together. We would share booty! We would share wenches! We did it all!\"")
                remove_answer("mates")
                add_answer("brother")
            elseif answer == "brother" then
                add_dialogue("\"Well, he is not a brother now! He hates me! If he wants nothing to do with me, so be it!\" But Mole quickly adds, \"He does not realize what I did for him. I made his life livable! Who was it that nursed him when he had scurvy? Me! Who was it that patched him up when he was sliced to bits by that butcher Silverbeard? Me!\"")
                remove_answer("brother")
                add_answer({"Silverbeard", "life"})
            elseif answer == "Silverbeard" then
                add_dialogue("\"Oh, he was some old pirate with a temper. He's probably dead now, if he knows what's good for him!\"")
                remove_answer("Silverbeard")
            elseif answer == "life" then
                add_dialogue("\"Yes, it was a different life in those days...\" Mole reflects on some past memory as his eyes glaze over temporarily. Finally he says, \"I may have dwelt too strongly on my Fellowship business. Perhaps I pushed him too hard. I am sorry. If he would give me another chance I would probably leave The Fellowship. They are not as wonderful as I made them sound. They are more crooked than the pirates I used to sail with!\" Mole frowns. \"Thou hast put me in a foul mood.\"")
                remove_answer("life")
                set_flag(679, true)
                if not get_flag(677) then
                    add_answer("He misses thee")
                    remove_answer("life")
                else
                    add_dialogue("*")
                    return
                end
            elseif answer == "He misses thee" then
                add_dialogue("You tell Mole what Blacktooth said. A change comes over the salty pirate, as if you had just given him a bouquet of flowers.")
                add_dialogue("\"Thou must be kidding me! Blackie misses me? I thought he hated mine innards! I shall have to go for a little walk and maybe I will run across that old dog! I thank thee, stranger, for imparting this information to me.\"")
                add_dialogue("With that, Mole turns away from you, doing a little jaunt.")
                remove_answer("He misses thee")
                set_schedule_type(12, var_0002)
                return
            elseif answer == "bye" then
                add_dialogue("\"Goodbye, stranger.\"")
                break
            end
        end
    elseif eventid == 0 then
        var_0004 = get_schedule_type(get_npc_name(227))
        if var_0004 == 11 then
            var_0005 = random2(4, 1)
            if var_0005 == 1 then
                var_0006 = "@Har!@"
            elseif var_0005 == 2 then
                var_0006 = "@Avast!@"
            elseif var_0005 == 3 then
                var_0006 = "@Blast!@"
            elseif var_0005 == 4 then
                var_0006 = "@Damn parrot droppings...@"
            end
            bark(227, var_0006)
        else
            utility_unknown_1070(227)
        end
    end
    return
end