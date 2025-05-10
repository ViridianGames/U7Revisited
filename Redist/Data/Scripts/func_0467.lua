--- Best guess: Handles dialogue with Thad, a zealous warrior in Yew, who is hostile to Fellowship members, discussing his quest to destroy the Fellowship, save his enchanted sister Millie, and his knowledge of Yew’s hunters.
function func_0467(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    start_conversation()
    if eventid == 1 then
        switch_talk_to(103, 0)
        var_0000 = unknown_0067H() --- Guess: Checks Fellowship membership
        if var_0000 then
            var_0001 = unknown_001BH(103) --- Guess: Gets object ref
            add_dialogue("The man scowls at you. \"Thou wearest the symbol of that most foul of groups, The Fellowship. Prepare to die!\"")
            unknown_003DH(2, var_0001) --- Guess: Initiates combat
            unknown_001DH(0, var_0001) --- Guess: Sets object behavior
            abort()
        end
        var_0002 = get_lord_or_lady()
        var_0003 = false
        if not get_flag(321) then
            add_dialogue("Eyeing you carefully, the man before you takes an aggressive stance.")
            set_flag(321, true)
        else
            add_dialogue("\"Good day, " .. var_0002 .. ",\" Thad says coolly.")
        end
        add_answer({"bye", "job", "name"})
        while true do
            var_0004 = get_answer()
            if var_0004 == "name" then
                add_dialogue("He stares at you for a moment. \"Thad is my name, " .. var_0002 .. ".\"")
                remove_answer("name")
            elseif var_0004 == "job" then
                add_dialogue("\"Job? I have not the time for a job. I am on a quest to rid this land of that which plagues it!\"")
                add_answer({"plague", "quest"})
            elseif var_0004 == "quest" then
                add_dialogue("\"I have devoted mine entire life to this, nothing will get in my way, not even Batlin.\"")
                remove_answer("quest")
                add_answer("Batlin")
            elseif var_0004 == "Batlin" then
                add_dialogue("\"He is the leader of the cursed organization, The Fellowship!\"")
                if not var_0003 then
                    add_answer("The Fellowship")
                end
                remove_answer("Batlin")
            elseif var_0004 == "plague" then
                add_dialogue("\"Surely thou hast heard of The Fellowship, a most foul and evil organization. It has even infested the lovely forest of Yew!\"")
                add_answer("Yew")
                if not var_0003 then
                    add_answer("The Fellowship")
                end
                remove_answer("plague")
            elseif var_0004 == "The Fellowship" then
                add_dialogue("\"I know little about their practices, but I do know they live outside the bounds of moral decency. They have kidnapped my beloved sister, Millie, and have cast a spell of enchantment. Now she lives as they do. I have vowed to remove this wicked spell and will slay the entire organization should that prove necessary!\"")
                add_dialogue("\"Thou, also, hast taken up a similar cause, I expect. Yes?\"")
                var_0004 = select_option()
                if var_0004 then
                    add_dialogue("\"Excellent.\" He shakes your hand. \"Thou art indeed a worthy warrior, " .. var_0002 .. ".\"")
                else
                    add_dialogue("\"No?\" He seems genuinely surprised. \"Then perhaps thou wilt consider taking up my quest in thine own manner.\"")
                    var_0005 = select_option()
                    if var_0005 then
                        add_dialogue("\"I expected as much. Thou art truly an honorable warrior.\"")
                    else
                        add_dialogue("\"What manner of scoundrel art thou? Remove thyself from my presence before I decide to smite thee from thy wretched life!\"")
                        abort()
                    end
                end
                var_0003 = true
                remove_answer("The Fellowship")
            elseif var_0004 == "Yew" then
                add_dialogue("\"I know the land, but not the people. There is nothing useful I have to tell thee.\" He appears thoughtful for a moment. \"Perhaps I can aid thee a bit. I do know that there are two hunters who sometimes frequent this area. One, a woman, carries a spear. The other is an archer. That is all I can tell thee.\"")
                remove_answer("Yew")
            elseif var_0004 == "bye" then
                break
            end
        end
        add_dialogue("\"May thine endeavors reach fruition, " .. var_0002 .. ".\"")
    elseif eventid == 0 then
        abort()
    end
end