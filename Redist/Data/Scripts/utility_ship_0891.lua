--- Best guess: Depicts a Fellowship ceremony led by Elynor, with members sharing testimonials, advancing the Fellowship narrative.
function utility_ship_0891()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    start_conversation()
    add_dialogue("@With Elynor standing before the gathered members of The Fellowship, the ceremony begins. \"My brothers in The Fellowship, I greet you on this occasion and thank you for your attendance. The events which have transpired in this town threaten to drive us apart. I do not need to remind you that the first value of the Triad of Inner Strength states that we must Strive For Unity. Now is the time when all those who hate and fear us may be conspiring against us.\"@")
    add_dialogue("@\"There are those who fear awareness for it illuminates their own limitations. There are those who despise change for the better because they have spent their whole lives teaching themselves to love the mediocrity with which they have surrounded themselves. These are the people who perceive our Fellowship as a threat.\"@")
    add_dialogue("@\"And there are those who are very uncertain about the merits of our Fellowship. Those who have heard the words of those who are against us but who see with their own eyes the substantial good that The Fellowship does and the difference it makes in the lives of its members every single day. Those undecided may still be brought into our family. We must Trust Our Brothers-yet-to-be. But most importantly, we must keep our enemies from spreading their prejudices against us. To do that we must show their beliefs to be untrue.\"@")
    add_dialogue("@\"We must prove ourselves worthy of the trust we would have our fellow citizens place in us. Once we have sufficiently displayed this worthiness, it will only be a matter of time before we receive our reward of trust. It is as inevitable as night following day. As our enemies will one day receive their own inevitable reward for which they have made themselves worthy.\"@")
    add_dialogue("@\"Now I would like to hear from our members who have gathered here this evening. Share with us how The Fellowship has helped thee!\"@")
    var_0000 = check_dialogue_target(-82) --- Guess: Checks if Gregor is present
    if var_0000 then
        switch_talk_to(0, -82) --- Guess: Switches to Gregor
        add_dialogue("@\"The Fellowship has improved mine ability to run my business,\" says Gregor.@")
        hide_npc(82) --- Guess: Hides Gregor
    end
    var_0001 = check_dialogue_target(-90) --- Guess: Checks if Owen is present
    if var_0001 then
        switch_talk_to(0, -90) --- Guess: Switches to Owen
        add_dialogue("@\"The Fellowship has taught me how to face mine own potential for greatness unquestioningly,\" says Owen.@")
        switch_talk_to(0, -81) --- Guess: Switches to Elynor
        add_dialogue("@\"Thank thee for sharing, brother!\"@")
        hide_npc(90) --- Guess: Hides Owen
    end
    var_0002 = check_dialogue_target(-91) --- Guess: Checks if Burnside is present
    if var_0002 then
        switch_talk_to(0, -91) --- Guess: Switches to Burnside
        add_dialogue("@You notice that Burnside has apparently nodded off. After a nudge from the person next to him, his eyes pop open. \"Umm... what was that question again...?\" he asks sheepishly.@")
        hide_npc(91) --- Guess: Hides Burnside
    end
    var_0003 = check_dialogue_target(-93) --- Guess: Checks if William is present
    if var_0003 then
        switch_talk_to(0, -93) --- Guess: Switches to William
        add_dialogue("@\"The Fellowship has helped me to have more courage to deal with the unexpected terrors of life,\" says William.@")
        hide_npc(93) --- Guess: Hides William
    end
    var_0004 = check_dialogue_target(-97) --- Guess: Checks if Mikos is present
    if var_0004 then
        switch_talk_to(0, -97) --- Guess: Switches to Mikos
        add_dialogue("@\"The Fellowship has helped me to have the firm hand that is necessary as the supervisor of the mine,\" says Mikos.@")
        hide_npc(97) --- Guess: Hides Mikos
    end
    var_0005 = check_dialogue_target(-2) --- Guess: Checks if Spark is present
    if var_0005 then
        switch_talk_to(0, -2) --- Guess: Switches to Spark
        add_dialogue("@\"Everything about this Fellowship gives me the creeps!\" says Spark.@")
        hide_npc(2) --- Guess: Hides Spark
    end
    var_0006 = check_dialogue_target(-1) --- Guess: Checks if Iolo is present
    if var_0006 then
        switch_talk_to(0, -1) --- Guess: Switches to Iolo
        add_dialogue("@\"Elynor is certainly going out of her way to make them feel like they are persecuted,\" says Iolo.@")
        hide_npc(1) --- Guess: Hides Iolo
    end
    var_0007 = check_dialogue_target(-3) --- Guess: Checks if Shamino is present
    if var_0007 then
        switch_talk_to(0, -3) --- Guess: Switches to Shamino
        add_dialogue("@\"These Fellowship members seem fixated upon their own personal gain and very little else,\" says Shamino.@")
        hide_npc(3) --- Guess: Hides Shamino
    end
    var_0008 = check_dialogue_target(-4) --- Guess: Checks if another NPC is present
    if var_0008 then
        switch_talk_to(0, -4) --- Guess: Switches to NPC
        add_dialogue("@\"Why are these people so fascinated by The Fellowship anyway? I do not understand it.\"@")
        hide_npc(4) --- Guess: Hides NPC
    end
    switch_talk_to(0, -81) --- Guess: Switches back to Elynor
    add_dialogue("@With that Elynor is once again the center of attention of the meeting. \"Let us now begin our evening's meditations.\" After a few minutes of silence you begin to realize that this meditation is going to continue for quite some time and that now might be a good time to leave inconspicuously.@")
    abort() --- Guess: Aborts script
end