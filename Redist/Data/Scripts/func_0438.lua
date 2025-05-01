-- Manages Diane's dialogue in Britain, covering stable operations, horse and carriage sales, and local connections.
function func_0438(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6

    if eventid == 1 then
        switch_talk_to(56, 0)
        local0 = get_player_name()
        local1 = get_item_type()
        local2 = get_party_size()

        add_answer({"bye", "job", "name"})

        if local1 then
            add_answer("Fellowship")
        end

        if not get_flag(185) then
            say("You see a pleasant-looking young peasant woman.")
            set_flag(185, true)
        else
            say("\"Greetings to thee, " .. local0 .. ",\" says Diane.")
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                say("\"My name is Diane.\"")
                remove_answer("name")
            elseif answer == "job" then
                say("\"My job is to oversee the stables here in Britain and sell thee a horse and carriage if thou dost want one.\"")
                add_answer({"carriage", "Britain", "stables"})
            elseif answer == "stables" then
                say("\"Here thou wilt find a selection of the finest horses produced by Lord British's personal horse breeder. If thou dost wish to buy one, I am sure we can come to some sort of arrangement. They come with a carriage, of course.\"")
                remove_answer("stables")
            elseif answer == "Britain" then
                say("\"Britain is such a grand city, but it can be somewhat disconcerting if thou dost not know anyone. Fortunately, I know many people here.\"")
                remove_answer("Britain")
                add_answer("people")
            elseif answer == "carriage" then
                say("\"The horse and carriage combination sells for 120 gold. Thou shalt find it in a small shelter just south of the stables, across the street. Dost thou want a title?\"")
                local3 = get_answer()
                if local3 then
                    local4 = get_gold(-359, -359, 644, -357) -- Unmapped intrinsic
                    if local4 >= 120 then
                        local5 = add_item(-359, 29, 797, 1) -- Unmapped intrinsic
                        if local5 then
                            say("\"Very good. Here is thy title.\"")
                            remove_gold(-359, -359, 644, 120) -- Unmapped intrinsic
                        else
                            say("\"Oh, my. Thine hands are too full to take the title!\"")
                        end
                    else
                        say("\"Oh. Thou dost not have enough gold to buy the title.\"")
                    end
                else
                    say("\"Some other time, then.\"")
                end
                remove_answer("carriage")
            elseif answer == "people" then
                say("\"I have many friends in Britannia. Among them are Greg, James, Brownie and Mack.\"")
                remove_answer("people")
                add_answer({"Mack", "Brownie", "James", "Greg"})
            elseif answer == "Greg" then
                say("\"Greg runs a shop that sells provisions. If thou art planning any sort of expedition he is just the person to see. He seems to be lucky. Perhaps some of it will rub off on thee.\"")
                remove_answer("Greg")
            elseif answer == "James" then
                say("\"James, who runs an inn not far from here, wanted a life of adventure. His family wanted him to run the inn after his father died and he has been discontent ever since. Still, I think he fancies Cynthia who works at the Mint.\"")
                remove_answer("James")
            elseif answer == "Brownie" then
                say("\"Brownie is a decent and honest man who would have made a much better mayor than Patterson if thou dost want mine opinion. He uses our horses to plow his fields in the spring.\"")
                remove_answer("Brownie")
            elseif answer == "Mack" then
                say("\"One word of warning about Mack. Do not let him start talking about the sky. Other than that he is perfectly fine, I can assure thee.\"")
                remove_answer("Mack")
            elseif answer == "Fellowship" then
                say("Diane notices your Fellowship medallion. \"It is odd. If thou dost not mind me saying so, thou dost not seem like a Fellowship member. There is something about thee. I cannot place it.\"")
            elseif answer == "bye" then
                say("\"Good day to thee, " .. local0 .. ".\"*")
                break
            end
        end
    elseif eventid == 0 then
        switch_talk_to(56)
    end
    return
end