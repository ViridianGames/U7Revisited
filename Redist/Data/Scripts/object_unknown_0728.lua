--- Best guess: Manages an NPC (ID -2, likely Spark) commenting on needing a blacksmith, possibly for a quest-related item.
function object_unknown_0728(eventid, objectref)
    if eventid == 1 then
        if not npc_in_party(2) then
            switch_talk_to(2)
            start_conversation()
            add_dialogue("\"Thou dost need a blacksmith to do that. I wager my dad could do it... I mean, could have... if he were still alive...\"")
            hide_npc(2)
        end
    end
    return
end