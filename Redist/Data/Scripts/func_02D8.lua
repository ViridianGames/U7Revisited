-- Function 02D8: NPC blacksmith dialogue
function func_02D8(eventid, itemref)
    if eventid ~= 1 then
        return
    end

    if _NPCInParty(-2) then
        switch_talk_to(2, 0)
        add_dialogue("\"Thou dost need a blacksmith to do that. I wager my dad could do it... I mean, could have... if he were still alive...\"")
        _HideNPC(-2)
    end

    return
end

-- Helper function
function add_dialogue(message)
    print(message) -- Adjust to your dialogue system
end