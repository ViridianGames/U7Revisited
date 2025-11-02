--- Best guess: Handles dialogue with Geoffrey, Captain of the Guard and Lord British's bodyguard, discussing his role, past adventures, and advice on gaining experience, with comments on Nystul's mental state.
function npc_geoffrey_0064(eventid, objectref)
    local var_0000

    start_conversation()
    if eventid == 1 then
        switch_talk_to(64)
        var_0000 = get_player_name()
        add_answer({"bye", "job", "name"})
        if not get_flag(153) then
            add_answer("Nystul")
        end
        if not get_flag(193) then
            add_dialogue("You see your former companion and friend, Geoffrey, Captain of the Guard.")
            set_flag(193, true)
        else
            add_dialogue("\"Yes, " .. var_0000 .. "?\" Geoffrey asks.")
        end
        while true do
            var_0000 = get_answer()
            if var_0000 == "name" then
                add_dialogue("Geoffrey chuckles. \"Art thou joking? I am Geoffrey!\"")
                remove_answer("name")
            elseif var_0000 == "job" then
                add_dialogue("\"These days I remain in my position as Captain of the Guard. I am Lord British's personal bodyguard, and I am in charge of security at the castle. I do not have much time or use for adventuring now.\"")
                add_answer("adventuring")
            elseif var_0000 == "adventuring" then
                add_dialogue("\"I have aged a bit over the last 200 years. I am afraid I shall not be joining thee this time. But my thoughts are with thee, and if I may offer some assistance, I shall be glad to do so.\"")
                remove_answer("adventuring")
                add_answer({"assistance", "aged"})
            elseif var_0000 == "aged" then
                add_dialogue("\"Yes, it has been a long time by Britannian reckoning since I have seen mine homeland. When thou hast finished with thy business, do come back and tell me news of what is happening in our homeworld.\"")
                remove_answer("aged")
            elseif var_0000 == "assistance" then
                add_dialogue("\"Mine advice to thee is to build up thine experience and skills as soon as possible. Thou hast been away from Britannia for a long time. Thou mightest not be in the same shape thou wert in at the end of thy last adventure here.\"")
                remove_answer("assistance")
                add_answer({"shape", "experience"})
            elseif var_0000 == "shape" then
                add_dialogue("\"It is apparently another difference in our two worlds. Whenever thou shalt return it is as if thy physical body has arrived here for the first time. It is the reason why many of thine own companions have chosen to stay here even though they have aged in Britannian time.\"")
                remove_answer("shape")
            elseif var_0000 == "experience" then
                add_dialogue("\"Go and search for monsters. Vanquish them. Take their gold! Gain experience! Use that experience when thou dost visit trainers. Increase thy strength, dexterity, and intelligence, as well as thy combat skill and ability to perform magic. Thou wilt be lost without this necessary evolution of experience!\"")
                remove_answer("experience")
            elseif var_0000 == "Nystul" then
                if not get_flag(3) then
                    add_dialogue("\"He is quite looney. If thou dost ask me, I believe all the mages in the land are afflicted. Take a look and find out for thyself.\"")
                else
                    add_dialogue("\"He is much better now!\"")
                end
                remove_answer("Nystul")
            elseif var_0000 == "bye" then
                break
            end
        end
        add_dialogue("\"Have courage. Have faith. Be strong. Be wise.\"")
    elseif eventid == 0 then
        utility_unknown_1070(64) --- Guess: Triggers a game event
    end
end