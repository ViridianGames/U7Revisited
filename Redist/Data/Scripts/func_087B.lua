-- Manages a Fellowship meeting led by Elynor, including member testimonials.
function func_087B()
    local local0, local1, local2, local3, local4, local5, local6, local7, local8

    add_dialogue("With Elynor standing before the gathered members of The Fellowship, the ceremony begins. \"My brothers in The Fellowship, I greet you on this occasion and thank you for your attendance. The events which have transpired in this town threaten to drive us apart. I do not need to remind you that the first value of the Triad of Inner Strength states that we must Strive For Unity. Now is the time when all those who hate and fear us may be conspiring against us.\"")
    add_dialogue("\"There are those who fear awareness for it illuminates their own limitations. There are those who despise change for the better because they have spent their whole lives teaching themselves to love the mediocrity with which they have surrounded themselves. These are the people who perceive our Fellowship as a threat.\"")
    add_dialogue("\"And there are those who are very uncertain about the merits of our Fellowship. Those who have heard the words of those who are against us but who see with their own eyes the substantial good that The Fellowship does and the difference it makes in the lives of its members every single day. Those undecided may still be brought into our family. We must Trust Our Brothers-yet-to-be. But most importantly, we must keep our enemies from spreading their prejudices against us. To do that we must show their beliefs to be untrue.\"")
    add_dialogue("\"We must prove ourselves worthy of the trust we would have our fellow citizens place in us. Once we have sufficiently displayed this worthiness, it will only be a matter of time before we receive our reward of trust. It is as inevitable as night following day. As our enemies will one day receive their own inevitable reward for which they have made themselves worthy.\"")
    add_dialogue("\"Now I would like to hear from our members who have gathered here this evening. Share with us how The Fellowship has helped thee!\"")
    local0 = external_08F7H(-82) -- Unmapped intrinsic
    if not local0 then
        switch_talk_to(82, 0)
        add_dialogue("\"The Fellowship has improved mine ability to run my business,\" says Gregor.*")
        hide_npc(82)
    end
    local1 = external_08F7H(-90) -- Unmapped intrinsic
    if not local1 then
        switch_talk_to(90, 0)
        add_dialogue("\"The Fellowship has taught me how to face mine own potential for greatness unquestioningly,\" says Owen.*")
        switch_talk_to(81, 0)
        add_dialogue("\"Thank thee for sharing, brother!\"*")
        hide_npc(90)
    end
    local2 = external_08F7H(-91) -- Unmapped intrinsic
    if not local2 then
        switch_talk_to(91, 0)
        add_dialogue("You notice that Burnside has apparently nodded off. After a nudge from the person next to him, his eyes pop open. \"Umm... what was that question again...?\" he asks sheepishly.*")
        hide_npc(91)
    end
    local3 = external_08F7H(-93) -- Unmapped intrinsic
    if not local3 then
        switch_talk_to(93, 0)
        add_dialogue("\"The Fellowship has helped me to have more courage to deal with the unexpected terrors of life,\" says William.*")
        hide_npc(93)
    end
    local4 = external_08F7H(-97) -- Unmapped intrinsic
    if not local4 then
        switch_talk_to(97, 0)
        add_dialogue("\"The Fellowship has helped me to have the firm hand that is necessary as the supervisor of the mine,\" says Mikos.*")
        hide_npc(97)
    end
    local5 = external_08F7H(-2) -- Unmapped intrinsic
    if not local5 then
        switch_talk_to(2, 0)
        add_dialogue("\"Everything about this Fellowship gives me the creeps!\" says Spark.*")
        hide_npc(2)
    end
    local6 = external_08F7H(-1) -- Unmapped intrinsic
    if not local6 then
        switch_talk_to(1, 0)
        add_dialogue("\"Elynor is certainly going out of her way to make them feel like they are persecuted,\" says Iolo.*")
        hide_npc(1)
    end
    local7 = external_08F7H(-3) -- Unmapped intrinsic
    if not local7 then
        switch_talk_to(3, 0)
        add_dialogue("\"These Fellowship members seem fixated upon their own personal gain and very little else,\" says Shamino.*")
        hide_npc(3)
    end
    local8 = external_08F7H(-4) -- Unmapped intrinsic
    if not local8 then
        switch_talk_to(4, 0)
        add_dialogue("\"Why are these people so fascinated by The Fellowship anyway? I do not understand it.\"*")
        hide_npc(4)
    end
    switch_talk_to(81, 0)
    add_dialogue("With that Elynor is once again the center of attention of the meeting. \"Let us now begin our evening's meditations.\" After a few minutes of silence you begin to realize that this meditation is going to continue for quite some time and that now might be a good time to leave inconspicuously.*")
    abort()
    return
end