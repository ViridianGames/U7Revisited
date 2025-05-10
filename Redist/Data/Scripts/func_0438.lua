--- Best guess: Handles dialogue with Diane, who manages the stables in Britain, selling horses and carriages, and discussing her friends (Greg, James, Brownie, Mack) and the Fellowship.
function func_0438(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006

    start_conversation()
    if eventid == 1 then
        switch_talk_to(56, 0)
        var_0000 = get_lord_or_lady()
        var_0001 = unknown_0067H() --- Guess: Checks Fellowship membership
        var_0002 = unknown_003BH() --- Guess: Checks game state or timer
        add_answer({"bye", "job", "name"})
        if var_0001 then
            add_answer("Fellowship")
        end
        if not get_flag(185) then
            add_dialogue("You see a pleasant-looking young peasant woman.")
            set_flag(185, true)
        else
            add_dialogue("\"Greetings to thee, " .. var_0000 .. ",\" says Diane.")
        end
        while true do
            var_0003 = get_answer()
            if var_0003 == "name" then
                add_dialogue("\"My name is Diane.\"")
                remove_answer("name")
            elseif var_0003 == "job" then
                add_dialogue("\"My job is to oversee the stables here in Britain and sell thee a horse and carriage if thou dost want one.\"")
                add_answer({"carriage", "Britain", "stables"})
            elseif var_0003 == "stables" then
                add_dialogue("\"Here thou wilt find a selection of the finest horses produced by Lord British's personal horse breeder. If thou dost wish to buy one, I am sure we can come to some sort of arrangement. They come with a carriage, of course.\"")
                remove_answer("stables")
            elseif var_0003 == "Britain" then
                add_dialogue("\"Britain is such a grand city, but it can be somewhat disconcerting if thou dost not know anyone. Fortunately, I know many people here.\"")
                remove_answer("Britain")
                add_answer("people")
            elseif var_0003 == "carriage" then
                add_dialogue("\"The horse and carriage combination sells for 120 gold. Thou shalt find it in a small shelter just south of the stables, across the street. Dost thou want a title?\"")
                var_0003 = select_option()
                if var_0003 then
                    var_0004 = unknown_0028(359, 359, 644, 357) --- Guess: Checks player inventory or gold
                    if var_0004 >= 120 then
                        var_0005 = unknown_002C(false, 359, 29, 797, 1) --- Guess: Checks inventory space
                        if var_0005 then
                            add_dialogue("\"Very good. Here is thy title.\"")
                            var_0006 = unknown_002B(true, 359, 359, 644, 120) --- Guess: Deducts gold and adds title
                        else
                            add_dialogue("\"Oh, my. Thine hands are too full to take the title!\"")
                        end
                    else
                        add_dialogue("\"Oh. Thou dost not have enough gold to buy the title.\"")
                    end
                else
                    add_dialogue("\"Some other time, then.\"")
                end
                remove_answer("carriage")
            elseif var_0003 == "people" then
                add_dialogue("\"I have many friends in Britannia. Among them are Greg, James, Brownie and Mack.\"")
                remove_answer("people")
                add_answer({"Mack", "Brownie", "James", "Greg"})
            elseif var_0003 == "Greg" then
                add_dialogue("\"Greg runs a shop that sells provisions. If thou art planning any sort of expedition he is just the person to see. He seems to be lucky. Perhaps some of it will rub off on thee.\"")
                remove_answer("Greg")
            elseif var_0003 == "James" then
                add_dialogue("\"James, who runs an inn not far from here, wanted a life of adventure. His family wanted him to run the inn after his father died and he has been discontent ever since. Still, I think he fancies Cynthia who works at the Mint.\"")
                remove_answer("James")
            elseif var_0003 == "Brownie" then
                add_dialogue("\"Brownie is a decent and honest man who would have made a much better mayor than Patterson if thou dost want mine opinion. He uses our horses to plow his fields in the spring.\"")
                remove_answer("Brownie")
            elseif var_0003 == "Mack" then
                add_dialogue("\"One word of warning about Mack. Do not let him start talking about the sky. Other than that he is perfectly fine, I can assure thee.\"")
                remove_answer("Mack")
            elseif var_0003 == "Fellowship" then
                add_dialogue("Diane notices your Fellowship medallion. \"It is odd. If thou dost not mind me saying so, thou dost not seem like a Fellowship member. There is something about thee. I cannot place it.\"")
            elseif var_0003 == "bye" then
                break
            end
        end
        add_dialogue("\"Good day to thee, " .. var_0000 .. ".\"")
    elseif eventid == 0 then
        unknown_092EH(56) --- Guess: Triggers a game event
    end
end