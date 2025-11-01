--- Best guess: Manages Nelson's dialogue in Moonglow's Lycaeum, discussing his assistant Zelda's feelings, the North East sea, and showing off scholarly items.
function npc_nelson_0249(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011, var_0012, var_0013

    if eventid == 1 then
        switch_talk_to(249)
        var_0000 = get_player_name()
        var_0001 = get_lord_or_lady()
        start_conversation()
        add_answer({"bye", "job", "name"})
        if not get_flag(505) then
            add_dialogue("You see a scholarly-looking man with a friendly expression.")
            set_flag(505, true)
            set_flag(503, true)
        else
            add_dialogue("\"Salutations, " .. var_0000 .. ".\"")
            if not get_flag(502) then
                add_answer("North East sea")
            end
            if not get_flag(483) then
                add_answer("Zelda's response")
            end
        end
        while true do
            local answer = get_answer()
            if answer == "name" then
                add_dialogue("\"Thou mayest call me Nelson.\"")
                remove_answer("name")
                if not get_flag(502) then
                    add_answer("North East sea")
                end
            elseif answer == "job" then
                add_dialogue("\"I am the Lycaeum head here in Moonglow, but,\" he leans close to you, \"mine assistant, Zelda, does most of the work.\"")
                add_answer({"Zelda", "Moonglow"})
            elseif answer == "Zelda" then
                add_dialogue("\"She is an excellent assistant. The Lycaeum has never performed better. However, she is a little too stern, I believe, and,\" he leans in again, \"I think she is quite beautiful.\"")
                add_answer({"beautiful", "stern"})
                remove_answer("Zelda")
            elseif answer == "North East sea" then
                add_dialogue("\"I have heard the rumors of an island, but I know nothing else about it, I am afraid. Thou mightest wish to speak with Jillian -- she should know a little about the area.\"")
                remove_answer("North East sea")
            elseif answer == "stern" then
                add_dialogue("\"She has put an extraordinary amount of time and effort into ensuring the activities in this edifice happen smoothly. And,\" he adds, \"she takes it personally when they do not!\"")
                remove_answer("stern")
            elseif answer == "beautiful" then
                add_dialogue("\"Dost thou not agree? I am flushed whenever her fair presence passes by. But!\" he holds up his index finger, \"I fear she does not share a mutual attraction. And she is far too serious for me to feel comfortable with a proposal.\"")
                set_flag(476, true)
                if not get_flag(474) then
                    add_answer("Zelda's feelings")
                end
                remove_answer("beautiful")
            elseif answer == "Moonglow" then
                add_dialogue("\"I love the island and the people. Mostly the people.\"")
                add_answer("people")
                remove_answer("Moonglow")
            elseif answer == "people" then
                add_dialogue("\"Hast thou met my twin brother? He heads the Observatory here. And somewhere in the Lycaeum thou canst find Mariah. Sadly, she is not well up here.\" He touches his head.")
                add_dialogue("\"Jillian, the sage, also studies here in the Lycaeum. A good person to see about other residents of Moonglow would be the bartender at the Friendly Knave. Phearcy knows almost all of us here on the island.\"")
                add_dialogue("\"Oh, and thou must not forget the legend of Penumbra. 'Twas two hundred years ago she cast herself into a deep slumber. Now that I think about it, " .. var_0000 .. ", thou art the one she predicted would awaken her.\"")
                add_dialogue("\"Better hasten, " .. var_0001 .. ",\" he chuckles.")
                remove_answer("people")
                add_answer({"Penumbra", "Phearcy", "Jillian", "Mariah", "twin"})
            elseif answer == "twin" then
                add_dialogue("\"His name is Brion. People often mistake us for each other, but I think we are nothing alike -- he got all the looks -and- the brains!\"")
                remove_answer("twin")
            elseif answer == "Mariah" then
                add_dialogue("\"She was once an adept mage, but ever since the wizards began losing their, er, faculties, she followed suit.\"")
                remove_answer("Mariah")
            elseif answer == "Jillian" then
                add_dialogue("\"She rarely has time for visitors, but I know she takes on students every now and then.\"")
                remove_answer("Jillian")
            elseif answer == "Phearcy" then
                add_dialogue("\"That one keeps up on his politics, or rather, his gossip,\" he says, grinning. \"If thou dost want to learn about a resident of Moonglow, visit him.\"")
                remove_answer("Phearcy")
            elseif answer == "Penumbra" then
                add_dialogue("\"Interestingly enough, no one has ever discovered how to enter her house. I believe those mysterious signs on the door require one to have specific items to place next to the plaques.\"")
                remove_answer("Penumbra")
            elseif answer == "Zelda's response" then
                add_dialogue("He smiles broadly. \"Truly that was her response? I am pleased to no end! I thank thee, " .. var_0000 .. ", for bringing this joyful message.\"")
                remove_answer("Zelda's response")
            elseif answer == "Zelda's feelings" then
                add_dialogue("\"Oh. Oh well,\" he shrugs in an attempt at indifference. \"She was not truly important anyway.\"")
                remove_answer("Zelda's feelings")
            elseif answer == "bye" then
                if not get_flag(484) and not get_flag(485) and not get_flag(486) and not get_flag(487) then
                    add_dialogue("\"Good day, " .. var_0001 .. ". Thou of course dost have free reign of the Lycaeum.\"")
                    return
                else
                    add_dialogue("\"Of course thou mayest have free reign of the building. But first,\" he grins, \"let me show thee my...\"")
                    save_answers()
                    add_answer({"nothing", "book", "quill holder", "bookmark", "bookstand"})
                end
            elseif answer == "bookstand" then
                var_0002 = find_nearest(1, 697, 356)
                if var_0002 then
                    add_dialogue("\"This solid brass bookstand has matching, overhanging candleholder for late-night exploration in literature. I invented it myself.\"")
                else
                    add_dialogue("\"'Twas just here...\" he scratches his chin. \"Oh well, never mind.\"")
                end
                remove_answer("bookstand")
                set_flag(484, true)
            elseif answer == "bookmark" then
                var_0003 = false
                for i = 1, 5 do
                    var_0004 = find_nearby(0, 20, 675, objectref)
                    var_0007 = get_item_frame(var_0004)
                    if var_0007 == 4 then
                        var_0003 = true
                        break
                    end
                end
                if var_0003 then
                    add_dialogue("\"This,\" he says, holding a solid-gold sheet shaped like a maple leaf, \"I purchased at an auction for only half of its value.\"")
                else
                    add_dialogue("He appears upset. \"I knew someday that would be stolen,\" he says angrily.")
                    add_dialogue("\"I should have known better than to show it to every person who comes to visit.\"")
                end
                remove_answer("bookmark")
                set_flag(485, true)
            elseif answer == "quill holder" then
                var_0008 = false
                var_000C = false
                for i = 1, 5 do
                    var_0009 = find_nearby(0, 20, 675, objectref)
                    var_0007 = get_item_frame(var_0009)
                    if var_0007 == 3 then
                        var_0008 = true
                        break
                    end
                end
                for i = 1, 5 do
                    var_000D = find_nearby(0, 20, 675, objectref)
                    var_0007 = get_item_frame(var_000D)
                    if var_0007 == 5 then
                        var_000C = true
                        break
                    end
                end
                if var_0008 then
                    if var_000C then
                        add_dialogue("He shows you a serpent-shaped, oaken quill holder and its matching scroll opener. \"This I picked up while travelling through -- thou canst guess it -- Serpent's Hold.\"")
                    else
                        add_dialogue("He shows you a serpent-shaped, oaken quill holder. \"This I picked up while travelling through -- thou canst guess it -- Serpent's Hold. But,\" he appears puzzled, \"I could have sworn the matching letter opener was here as well. How odd.\"")
                    end
                else
                    add_dialogue("\"The quill holder is gone?\" he exclaims. \"And what about the...\" he seems to be searching for something.")
                    add_dialogue("\"The matching scroll opener is also missing!\"")
                end
                remove_answer("quill holder")
                set_flag(486, true)
            elseif answer == "book" then
                var_0010 = false
                for i = 1, 5 do
                    var_0011 = find_nearby(0, 20, 675, objectref)
                    var_0010 = get_item_quality(var_0011)
                    if var_0010 == 4 then
                        var_0010 = true
                        break
                    end
                end
                if var_0010 then
                    add_dialogue("He gingerly pulls out a leatherbound tome. From his robe, he removes a handkerchief and meticulously wipes away the dust.")
                    add_dialogue("\"This was given to me by Lord British himself. See, 'tis the first edition.\"")
                    add_dialogue("The book he carefully places in your palms is very old, and the gold leaf plating of the title has been almost entirely rubbed off. Turning the book right side up, you can read the title: \"Stranger in a Strange Land.\"")
                else
                    add_dialogue("\"'Tis not here... Oh well, Zelda must have put it back on the shelf.\" He sighs.")
                end
                remove_answer("book")
                set_flag(487, true)
            elseif answer == "nothing" then
                restore_answers()
            end
        end
    elseif eventid == 0 then
        utility_unknown_1070(249)
    end
    return
end