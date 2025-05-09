--- Best guess: Initiates the quest to restore Adjhar, offering a book and discussing golem creation.
function func_0894(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    if eventid == 1 then
        switch_talk_to(0, 289) --- Guess: Initiates dialogue
        if get_flag(804) and not get_flag(796) then
            add_dialogue("@I -must- return his life to him. He -will- have a new heart!...@")
        end
        if not get_flag(808) then
            calle_0896H() --- External call to Bollux dialogue
        end
        if not get_flag(795) then
            calle_0895H() --- External call to Bollux dialogue
        end
        if not get_flag(789) then
            set_flag(789, true)
            add_dialogue("@The stone statue stands with a lowered head...@")
            say_with_newline("@Why, by the stars, I believe it is a creature!@") --- Guess: Says with newline
            add_dialogue("@Slowly, as if with great effort, it raises it head.@")
            switch_talk_to(0, 289) --- Guess: Initiates dialogue
            var_0001 = get_item_frame(select_party_member(40, 414, 356)) --- Guess: Selects party member
            if var_0001 == 4 or var_0001 == 5 then
                add_dialogue("@What dost thou... want?' it asks slowly.@")
            else
                add_dialogue("@Help him?' it asks carefully, pointing to the fallen statue lying beside it.@")
                add_answer("help") --- Guess: Adds dialogue option
            end
            add_answer("Creature?") --- Guess: Adds dialogue option
        else
            add_dialogue("@In what way may I assist thee?@")
        end
        add_answer({"bye", "job", "name"}) --- Guess: Adds dialogue options
        var_0002 = false
        var_0003 = false
        while true do
            switch_talk_to(0, 289) --- Guess: Initiates dialogue
            if compare_answer("name", 1) then
                remove_answer("name") --- Guess: Removes dialogue option
                if not get_flag(797) then
                    add_dialogue("@He tilts his head and stares at you quizzicaly...@")
                else
                    add_dialogue("@My master named me Bollux.@")
                    set_flag(797, true)
                end
                if not var_0003 then
                    add_answer("master") --- Guess: Adds dialogue option
                end
            elseif compare_answer("job", 1) then
                add_dialogue("@I am a guardian of the Shrines of the Principles.@")
                add_answer("guardian") --- Guess: Adds dialogue option
            elseif compare_answer("guardian", 1) then
                remove_answer("guardian") --- Guess: Removes dialogue option
                add_dialogue("@We were... created to protect the Shrines of the Principles...@")
            elseif compare_answer("Creature?", 1) then
                remove_answer("Creature?") --- Guess: Removes dialogue option
                add_dialogue("@We are called stone golems... because we are made out of stone and rock.@")
                if not var_0002 then
                    add_answer("made") --- Guess: Adds dialogue option
                    var_0002 = true
                end
                add_answer("stone") --- Guess: Adds dialogue option
            elseif compare_answer("master", 2) or compare_answer("Astelleron", 2) then
                remove_answer({"master", "Astelleron"}) --- Guess: Removes dialogue options
                var_0003 = true
                add_dialogue("@Astelleron made us. He is our master.@")
                if not var_0002 then
                    add_answer("made") --- Guess: Adds dialogue option
                    var_0002 = true
                end
            elseif compare_answer("stone", 1) then
                remove_answer("stone") --- Guess: Removes dialogue option
                add_dialogue("@We were... fashioned... out of the rock from the quarry on this small island.@")
            elseif compare_answer("made", 1) then
                var_0002 = true
                remove_answer("made") --- Guess: Removes dialogue option
                add_dialogue("@I know nothing about the process, but Astelleron once told me he used something called... magic...@")
                add_answer({"lonely", "magic"}) --- Guess: Adds dialogue options
                if not var_0003 then
                    add_answer("Astelleron") --- Guess: Adds dialogue option
                end
            elseif compare_answer("magic", 1) then
                remove_answer("magic") --- Guess: Removes dialogue option
                add_dialogue("@I do not know what... it is, but there are many books in his house...@")
                add_answer("books") --- Guess: Adds dialogue option
            elseif compare_answer("books", 1) then
                remove_answer("books") --- Guess: Removes dialogue option
                if not get_flag(803) then
                    add_dialogue("@I have a book here that Adjhar said told about... our... creation...@")
                    var_0004 = add_item_to_inventory(359, 144, 642, 1) --- Guess: Adds item to inventory
                    if var_0004 then
                        add_dialogue("@He hands to you a very old tome...@")
                        add_answer("blood") --- Guess: Adds dialogue option
                        set_flag(803, true)
                    else
                        add_dialogue("@Thou art... carrying too much. Put something down and I can give this to you.@")
                    end
                else
                    add_dialogue("@There are several... more books lying about the house...@")
                end
            elseif compare_answer("lonely", 1) then
                remove_answer("lonely") --- Guess: Removes dialogue option
                add_dialogue("@Astelleron said it was how... a person feels when no one is around...@")
            elseif compare_answer("help", 1) then
                remove_answer("help") --- Guess: Removes dialogue option
                add_dialogue("@My companion... Adjhar... He is dying. Thou must help repair him...@")
                if not get_flag(803) then
                    add_dialogue("@I have a book here that Adjhar said told about... our... creation...@")
                    var_0004 = add_item_to_inventory(359, 144, 642, 1) --- Guess: Adds item to inventory
                    if var_0004 then
                        add_dialogue("@He hands to you a very old tome...@")
                        add_answer("blood") --- Guess: Adds dialogue option
                        set_flag(803, true)
                    else
                        add_dialogue("@Thou art... carrying too much. Put something down and I can give this to you.@")
                    end
                end
                add_answer("Adjhar") --- Guess: Adds dialogue option
            elseif compare_answer("Adjhar", 1) then
                remove_answer("Adjhar") --- Guess: Removes dialogue option
                add_dialogue("@He is my brother... and my friend. We protected the... Shrines together...@")
            elseif compare_answer("blood", 1) then
                remove_answer("blood") --- Guess: Removes dialogue option
                add_dialogue("@I did not... understand the book, but I remember... blood...@")
            elseif compare_answer("bye", 1) then
                add_dialogue("@Good... bye.@")
                return
            end
        end
    end
end