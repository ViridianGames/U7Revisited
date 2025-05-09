--- Best guess: Introduces a murder investigation, switching dialogue to an NPC (Petre) and prompting a search.
function func_0883(eventid, itemref)
    local var_0000, var_0001

    start_conversation()
    switch_talk_to(0, 12) --- Guess: Initiates dialogue
    var_0000 = check_npc_presence(11) --- Guess: Checks NPC presence
    if var_0000 then
        add_dialogue("@Petre here knows something about all of this.@")
        switch_talk_to(0, 11) --- Guess: Initiates dialogue
        add_dialogue("@I discovered poor Christopher and the Gargoyle Inamo early this morning.@")
        hide_npc(11) --- Guess: Hides NPC
    else
        switch_talk_to(0, 12) --- Guess: Initiates dialogue
        add_dialogue("@Petre the stables caretaker discovered poor Christopher and Inamo early this morning.@")
    end
    switch_talk_to(0, 12) --- Guess: Initiates dialogue
    add_dialogue("@The Mayor continues. 'Hast thou searched the stables?'@")
    calle_0885H() --- External call to evidence discussion
end