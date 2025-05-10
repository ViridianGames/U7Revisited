--- Best guess: Handles dialogue with Nell, a chambermaid at Lord British’s castle, discussing her family, fiance Carrocio, and her secret pregnancy, with trust-based dialogue depending on the player’s identity.
function func_0448(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    start_conversation()
    if eventid == 1 then
        var_0000 = get_player_name()
        var_0001 = "Avatar"
        switch_talk_to(72, 0)
        if not get_flag(120) then
            var_0002 = var_0000
        end
        if not get_flag(121) then
            var_0002 = var_0001
        end
        if get_flag(119) then
            add_dialogue("Nell will not speak to you.")
            abort()
        end
        if not get_flag(201) then
            add_dialogue("You see a servant girl who looks at you in wonder. \"Thou dost look familiar. Who art thou?\"")
            var_0003 = ask_answer({var_0001, var_0000})
            if var_0003 == var_0000 then
                add_dialogue("\"Oh. Hello. I am Nell.\"")
                set_flag(120, true)
            else
                add_dialogue("\"I thought so! I have seen thy portrait before. And I had heard that thou wouldst be visiting! I'm Nell.\"")
                set_flag(121, true)
            end
            if not get_flag(120) then
                var_0002 = var_0000
            end
            if not get_flag(121) then
                var_0002 = var_0001
            end
            set_flag(201, true)
        else
            add_dialogue("\"Hello, " .. var_0002 .. ".\"")
        end
        add_answer({"bye", "job", "name"})
        while true do
            var_0004 = get_answer()
            if var_0004 == "name" then
                add_dialogue("\"I told thee my name is Nell.\"")
                remove_answer("name")
            elseif var_0004 == "job" then
                add_dialogue("\"I am a chambermaid. I am responsible for keeping the castle tidy. Just a servant girl, really.\"")
                add_answer({"servant", "castle"})
            elseif var_0004 == "castle" then
                add_dialogue("\"It is very large. Keeps me very busy. Thou wouldst not believe how dusty it gets.\"")
                remove_answer("castle")
            elseif var_0004 == "servant" then
                add_dialogue("\"I suppose I'll always be a servant. My parents are servants. My brother is a servant. My fiance is a servant. My child will probably be a servant.\"")
                add_answer({"child", "fiance", "brother", "parents"})
                remove_answer("servant")
            elseif var_0004 == "parents" then
                add_dialogue("\"They work in the castle as well. Boots is my mother. Bennie is my father. They have been here for years. I was born in this castle and played in the nursery.\"")
                remove_answer("parents")
            elseif var_0004 == "brother" then
                add_dialogue("\"Thou mightest run into him. He is also a servant in the castle. Charles. Other than not being as smart as I am, he is all right. For a bumbling ass, that is!\" She laughs.")
                set_flag(118, true)
                remove_answer("brother")
            elseif var_0004 == "fiance" then
                add_dialogue("\"That would be Carrocio, that dear man who runs the Punch and Judy Show. He writes the loveliest love poetry. We are getting married as soon as Carrocio can afford a wedding ring.\"")
                set_flag(117, true)
                remove_answer("fiance")
            elseif var_0004 == "child" then
                add_dialogue("Nell looks worried. \"Shhh! I do not want anyone to know. 'Tis not showing yet, is it? Carrocio and I are getting married as soon as possible. He -is- the father. I think. Then again, it could be... no, probably not him. Or could it be...? Hmmm. That would be interesting! Wait! What am I saying? The father is most definitely Carrocio! Please do not tell anyone. 'Twould be embarrassing. All right?\"")
                var_0004 = select_option()
                if var_0004 then
                    add_dialogue("\"I know I can trust thee, " .. var_0002 .. ".\"")
                else
                    add_dialogue("\"But thou wouldst ruin my reputation! Please -- a servant girl needs all the self-esteem she can get without that burden!\" Nell turns away from you.")
                    set_flag(119, true)
                    abort()
                end
                remove_answer("child")
                set_flag(122, true)
            elseif var_0004 == "bye" then
                break
            end
        end
        add_dialogue("\"Goodbye, " .. var_0002 .. ".\"")
    elseif eventid == 0 then
        unknown_092EH(72) --- Guess: Triggers a game event
    end
end