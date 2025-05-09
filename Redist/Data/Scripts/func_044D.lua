--- Best guess: Manages Lord Heather’s dialogue, the Mayor of Cove, discussing the town, its romantic atmosphere, Nastassia’s melancholy, and a bill to address Lock Lake’s pollution, with flag-based interactions and companion dialogues.
function func_044D(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid ~= 1 then
        if eventid == 0 then
            unknown_092EH(77)
        end
        add_dialogue("\"Do come and visit again, Avatar!\"")
        return
    end

    start_conversation()
    switch_talk_to(0, 77)
    var_0000 = _IsPlayerFemale()
    add_answer({"bye", "job", "name"})
    if not get_flag(224) then
        add_answer("Nastassia")
    end
    if not get_flag(106) then
        add_answer({"Lock Lake", "bill"})
    end
    if not get_flag(234) then
        add_dialogue("This regal gentleman epitomizes a well-liked politician.")
        add_dialogue("\"Hello! Lord British sent word that thou might come to visit us. Welcome to Cove, Avatar!\"")
        set_flag(234, true)
    else
        add_dialogue("\"Hello again, Avatar!\" Lord Heather proclaims.")
    end
    while true do
        if cmps("name") then
            add_dialogue("\"I am Lord Heather. And I recognize thee, Avatar!\"")
            remove_answer("name")
        elseif cmps("job") then
            add_dialogue("\"I am the Town Mayor of Cove, home of the Shrine of Compassion.\"")
            add_answer({"Shrine", "Cove"})
        elseif cmps("Cove") then
            add_dialogue("\"It's a small place, I know. Many of our residents have moved away to the larger towns, especially Britain. But we have maintained a small core of loyal Covites.\"")
            remove_answer("Cove")
        elseif cmps("Shrine") then
            add_dialogue("\"We are proud of our Shrine. One of our residents takes good care of it. Thou must try and visit the Shrine if thou hast not already. It is a monument to all the lovers in town.\"")
            add_answer("lovers")
            remove_answer("Shrine")
        elseif cmps("lovers") then
            add_dialogue("\"Britain may be the city of Compassion, but Cove has become the city of Passion. Everyone here seems to fall in love rather easily. Thou wilt find that everyone loves someone. Almost everyone, that is.\"")
            remove_answer("lovers")
            add_answer({"almost everyone", "everyone"})
        elseif cmps("everyone") then
            add_dialogue("\"Well, let's see... I am in love with Jaana, our healer. And she is in love with me, of course. Then there is Zinaida, who runs the Emerald. She has an interest in De Maria, our local bard. And vice versa. Rayburt, our trainer, is courting Pamela, the innkeeper.\"")
            var_0001 = unknown_08F7H(-1)
            if var_0001 then
                switch_talk_to(0, -1)
                add_dialogue("\"Sounds like bad theatre to me!\"")
                hide_npc1)
                switch_talk_to(0, 77)
            end
            var_0002 = unknown_08F7H(-2)
            if var_0002 then
                switch_talk_to(0, -2)
                add_dialogue("\"Any wenches mine own age around here?\"")
                hide_npc2)
                switch_talk_to(0, 77)
            end
            set_flag(228, true)
            remove_answer("everyone")
            var_0003 = unknown_08F7H(-5)
            if var_0003 then
                add_dialogue("\"I see that thou art leaving Cove for a while, my dear?\"")
                switch_talk_to(0, -5)
                add_dialogue("\"Yes, milord. But I shall return. I promise thee.\"")
                switch_talk_to(0, 77)
                add_dialogue("\"I shall try not to worry about thee, but it will be difficult.\"")
                switch_talk_to(0, -5)
                add_dialogue("\"Do not worry. I shall be safe with the Avatar.\"")
                switch_talk_to(0, 77)
                add_dialogue("\"I do hope so.\" The Mayor embraces Jaana.")
                hide_npc5)
                switch_talk_to(0, 77)
            end
        elseif cmps("almost everyone") then
            add_dialogue("\"Except for Nastassia.\"")
            remove_answer("almost everyone")
            add_answer("Nastassia")
        elseif cmps("Nastassia") then
            if not get_flag(224) then
                add_dialogue("\"She is a lovely young woman who is always melancholy. De Maria can tell thee more about her. I suggest thou seekest him at the Emerald. 'Tis a sad but compelling tale.\"")
                set_flag(227, true)
            else
                if var_0000 then
                    var_0004 = "someone"
                else
                    var_0004 = "a man like thee"
                end
                add_dialogue("\"I do hope thou canst help her. She needs " .. var_0004 .. " to bring her out of her depression.\"")
            end
            remove_answer("Nastassia")
        elseif cmps("bill") then
            if not get_flag(222) then
                var_0005 = unknown_0931H(359, 4, 797, 1, 357)
                if var_0005 then
                    add_dialogue("\"'Tis about time that the government did something about the awful stench coming from that lake! I shall be happy to sign thy bill of law! Take it back to the Great Council post haste!\" Lord Heather signs the bill and hands it back to you.")
                    set_flag(222, true)
                else
                    add_dialogue("\"But thou dost not have a bill of law!\"")
                end
            else
                add_dialogue("\"I thought I already signed that bill!\"")
            end
            remove_answer("bill")
        elseif cmps("Lock Lake") then
            add_dialogue("\"It has gotten so putrid that on hot summer days the stink is suffocating. I believe that the Britannian Mining Company in Minoc is the source of the problem. Mining waste is being deposited in the Lake. Thou shouldst be glad it is nearly winter!\"")
            remove_answer("Lock Lake")
        elseif cmps("bye") then
            break
        end
    end
    return
end