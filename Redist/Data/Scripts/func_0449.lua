--- Best guess: Handles dialogue with Charles, a servant in Lord British’s castle, discussing his family, unrequited love for Jeanette, and Nell’s engagement, offering wine and reacting to news about Jeanette and Nell’s pregnancy.
function func_0449(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0007

    start_conversation()
    if eventid == 1 then
        switch_talk_to(73, 0)
        add_answer({"bye", "job", "name"})
        if not get_flag(118) then
            add_answer("Nell")
        end
        if not get_flag(125) then
            add_answer("Jeanette")
        end
        if not get_flag(126) then
            add_answer("Thou art in luck")
        end
        if not get_flag(202) then
            add_dialogue("You see a young peasant with a tray of wine glasses.")
            set_flag(202, true)
        else
            add_dialogue("\"Hello, Avatar.\"")
        end
        while true do
            var_0000 = get_answer()
            if var_0000 == "name" then
                add_dialogue("\"I am Charles.\"")
                remove_answer("name")
            elseif var_0000 == "job" then
                add_dialogue("\"I am a servant in Lord British's castle. I serve as a gentleman's gentleman, among other things. Right now I am serving wine.\"")
                add_answer({"wine", "servant"})
            elseif var_0000 == "servant" then
                add_dialogue("\"My family has been employed by Lord British for many years. My father, Bennie, once held the position I now hold. He is the head servant. I shall be head servant one day, I suppose. Then perhaps my sweetheart will love me.\"")
                remove_answer("servant")
                add_answer({"sweetheart", "family"})
            elseif var_0000 == "family" then
                add_dialogue("\"Thou wilt encounter them. My mother cooks in the kitchen. My prudish sister is the chambermaid.\"")
                remove_answer("family")
            elseif var_0000 == "sweetheart" then
                add_dialogue("Charles sighs. He is clearly smitten. \"She is Jeanette. She works in the Blue Boar. But I am afraid I am not 'up to her standards'. I believe she has her eye set on someone else. I do not know what to do about it.\"")
                set_flag(123, true)
                remove_answer("sweetheart")
                add_answer("Jeanette")
            elseif var_0000 == "Jeanette" then
                add_dialogue("\"She does not love me, I know. She would rather marry a rich man. I have not a chance.\"")
                remove_answer("Jeanette")
            elseif var_0000 == "Thou art in luck" then
                add_dialogue("You tell Charles what Jeanette said.")
                add_dialogue("\"Really? Thou dost mean I have a chance?\" Charles becomes so excited he nearly drops his tray. \"Oh, I thank thee, Avatar, for giving me this hopeful news! I must run and send her flowers or some gift! I must declare my love!\" He turns away from you, obviously walking on clouds.")
                abort()
            elseif var_0000 == "Nell" then
                add_dialogue("\"She is engaged to the carousel manager. It is hard to get used to. I have always been overly protective of my little sister. I would wager she has never even been kissed! Not even by Carrocio! That is mainly because I have looked after her all this time. I would smite anyone who laid a hand on her! Besides, Nell has always been chaste and prudish. She would never think to allow a man to kiss her.\"")
                remove_answer("Nell")
                set_flag(124, true)
                if not get_flag(122) then
                    add_answer("child")
                end
            elseif var_0000 == "child" then
                add_dialogue("You remember what Nell told you about her 'condition'. Do you mention it to Charles?")
                var_0001 = select_option()
                if var_0001 then
                    add_dialogue("You tell Charles what Nell revealed in confidence.")
                    add_dialogue("Charles is wide-eyed and shocked. \"Why, that hussy! My sister! She is nothing more than a tramp! And wait until I get mine hands on Carrocio!\"")
                    add_dialogue("Charles turns away. There is murder in his eyes.")
                    set_flag(137, true)
                    abort()
                else
                    add_dialogue("Your conscience rests easy, knowing that you resisted the temptation to carry tales.")
                    remove_answer("child")
                end
            elseif var_0000 == "wine" then
                add_dialogue("\"Wouldst thou like some wine?\"")
                var_0001 = select_option()
                if var_0001 then
                    var_0002 = get_party_members()
                    var_0003 = 0
                    for _ = 1, var_0002 do
                        var_0003 = var_0003 + 1
                    end
                    var_0007 = unknown_002CH(true, 0, 359, 628, var_0003) --- Guess: Checks inventory space
                    if var_0007 then
                        add_dialogue("\"'Tis on the house.\" Charles hands you and your friends glasses of wine.")
                    else
                        add_dialogue("\"Oops. Thou art carrying too much. Ask me again when thou dost not have thine hands full!\"")
                    end
                else
                    add_dialogue("\"Some other time, then.\"")
                end
                remove_answer("wine")
            elseif var_0000 == "bye" then
                break
            end
        end
        add_dialogue("Charles nods his head at you, then goes about his business.")
    elseif eventid == 0 then
        unknown_092EH(73) --- Guess: Triggers a game event
    end
end