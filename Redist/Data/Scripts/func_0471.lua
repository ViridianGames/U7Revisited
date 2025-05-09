--- Best guess: Handles dialogue with Smith, a talking horse in Yew, who humorously discusses his lack of a job, interior decorating skills, and provides a cryptic clue about gargoyles and Rasputin in exchange for being left alone.
function func_0471(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006

    start_conversation()
    if eventid == 1 then
        switch_talk_to(113, 0)
        var_0000 = get_player_name()
        var_0001 = unknown_08F7H(1) --- Guess: Checks player status
        var_0002 = false
        add_answer({"bye", "job", "name"})
        if not get_flag(331) then
            add_dialogue("You see a horse. \"What else did you expect to see?\"")
            set_flag(331, true)
        else
            add_dialogue("\"What now, " .. var_0000 .. "?\" asks Smith.")
        end
        while true do
            var_0003 = get_answer()
            if var_0003 == "name" then
                add_dialogue("\"Yes, I have a name.\"")
                remove_answer("name")
                if var_0001 then
                    switch_talk_to(1, 0)
                    add_dialogue("\"Scoundrel! When thou art asked thy name, thou shouldst respond politely and accurately! The Avatar has just asked thee for -thy- name.\"")
                    switch_talk_to(113, 0)
                    add_dialogue("\"My name? You can call me what you want, but I will only respond to Smith.\"")
                    add_answer("Smith")
                    hide_npc(1)
                else
                    add_answer("-thy- name")
                end
            elseif var_0003 == "-thy- name" then
                add_dialogue("\"My name? You can call me what you want, but I will only respond to Smith.\"")
                add_answer("Smith")
                remove_answer("-thy- name")
            elseif var_0003 == "job" then
                add_dialogue("\"Job? -Job-? I'm a horse, what kind of job could I have?\" He looks off in the distance. \"I can see it now: Smith -- Baker extraordinaire.\"")
                add_dialogue("\"Actually, I have gotten quite good at interior decorating. See how I arranged my abode? You like it, don't you?\"")
                var_0003 = select_option()
                if var_0003 then
                    add_dialogue("\"Good. I will let you continue talking to me then! Which do you prefer, my living room or my bedroom?\"")
                    save_answers()
                    add_answer({"bedroom", "living room"})
                else
                    add_dialogue("\"That's funny, I feel the same way about you!\"")
                    abort()
                end
            elseif var_0003 == "bedroom" or var_0003 == "living room" then
                add_dialogue("\"You always did have bad taste!\"")
                remove_answer({"bedroom", "living room"})
                restore_answers()
            elseif var_0003 == "Smith" then
                if not var_0002 then
                    var_0004 = "still want"
                else
                    var_0004 = "want"
                end
                add_dialogue("\"Yep, that's what I told you to call me. Oh, I get it! You " .. var_0004 .. " something from me, don't you?\"")
                var_0003 = select_option()
                if var_0003 then
                    add_dialogue("\"I thought as much. You've always been a selfish one. What do you want? Now, let's see... Money? Advice? Happiness? No, you usually want a clue of some sort, don't you. Of course, you may have become altruistic over the past 200 years....\"")
                    add_dialogue("\"I know! You want to save Britannia!\"")
                    add_answer({"to save Britannia", "happiness", "a clue", "advice", "money"})
                else
                    add_dialogue("\"Then what are you talking to me for?\"")
                    abort()
                end
                remove_answer({"to save Britannia", "happiness", "a clue", "advice", "money"})
            elseif var_0003 == "money" then
                add_dialogue("\"From a horse? Right! Like I've got some to give you.\"")
                remove_answer({"to save Britannia", "happiness", "a clue", "advice", "money"})
            elseif var_0003 == "advice" then
                add_dialogue("\"Don't talk to horses!\"")
                abort()
            elseif var_0003 == "happiness" then
                add_dialogue("\"Who doesn't?\"")
                remove_answer({"to save Britannia", "happiness", "a clue", "advice", "money"})
            elseif var_0003 == "to save Britannia" then
                add_dialogue("\"You really expect me to believe that? You're just in this for the money.\"")
                remove_answer({"to save Britannia", "happiness", "a clue", "advice", "money"})
            elseif var_0003 == "a clue" then
                add_dialogue("\"Now we're getting to the nitty-gritty. O.K., I'll give you a clue, but what's in it for me? Let me guess. Money? Love? No, knowing you it's probably nothing. With any luck, you'll go away and leave me alone.\"")
                remove_answer({"to save Britannia", "happiness", "a clue", "advice", "money"})
                add_answer({"will not make you glue", "nothing", "love", "money"})
            elseif var_0003 == "nothing" then
                add_dialogue("\"I've already got that!\"")
                abort()
            elseif var_0003 == "money" then
                add_dialogue("\"Sure! Like I have a use for that!\"")
                abort()
            elseif var_0003 == "love" then
                add_dialogue("\"Sorry, I don't get into that.\"")
                abort()
            elseif var_0003 == "will not make you glue" then
                add_dialogue("\"Threats, huh? And how do you expect me to respond to that? With courtesy and open hooves?\"")
                add_dialogue("\"Tell you what: you go away and leave me alone, and I'll tell you a clue. Fair?\"")
                var_0003 = select_option()
                if var_0003 then
                    add_dialogue("\"Now we're talking! Done deal. Here we go.\" He checks around to make sure no else is within earshot. \"The gargoyles,\" he pauses, \"are not evil.\"")
                    add_dialogue("\"And Rasputin is a mean Martian. There, that's it! Now get!\"")
                    abort()
                else
                    add_dialogue("\"Fine. I'm not going to talk to you anyway!\"")
                    abort()
                end
                remove_answer("will not make you glue")
            elseif var_0003 == "bye" then
                add_dialogue("\"That's just fine. I was getting tired of you anyway.\"")
                if var_0001 then
                    switch_talk_to(1, 0)
                    add_dialogue("\"Why, how dare thou speakest to the Avatar in that manner, Smith!\"")
                    switch_talk_to(113, 0)
                    add_dialogue("\"And who are you? My master?\"")
                    switch_talk_to(1, 0)
                    add_dialogue("\"Why, as a matter of fact...\"")
                    switch_talk_to(113, 0)
                    add_dialogue("\"Sure, whatever.\"")
                    hide_npc(1)
                    add_dialogue("*")
                    abort()
                end
                break
            end
        end
    elseif eventid == 0 then
        abort()
    end
end