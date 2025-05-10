--- Best guess: Handles a complex dialogue tree (states 1-29) with Guardian/Time Lord interactions, guiding the Avatar through choices.
function func_0614(eventid, objectref)
    local var_0000

    start_conversation()
    switch_talk_to(277, 0)
    var_0000 = unknown_0069H() --- Guess: Gets dialogue state
    if var_0000 == 1 then
        add_dialogue("\"Yes, rest, my friend. Rest and heal, so that you are strong and able to face the perils before you. Pleasant dreams!\"")
        hide_npc(277)
    elseif var_0000 == 2 then
        add_dialogue("\"Go inside. Tell them you are the Avatar!\"")
        hide_npc(277)
    elseif var_0000 == 3 then
        add_dialogue("\"Thank you for the information in the notebook, Avatar! It was most useful! Ha ha ha ha ha!\"")
        hide_npc(277)
    elseif var_0000 == 4 then
        add_dialogue("\"Do not go in! It is a trap! Do you not see? It is a trap!\"")
        hide_npc(277)
    elseif var_0000 == 5 then
        add_dialogue("\"You are not going to trust the Time Lord are you? Careful, my friend -- do not believe him!\"")
        hide_npc(277)
    elseif var_0000 == 6 then
        add_dialogue("\"Do not go in! You will surely die!\"")
        hide_npc(277)
    elseif var_0000 == 7 then
        add_dialogue("\"Avatar, you are not welcome here!\"")
        hide_npc(277)
    elseif var_0000 == 8 then
        add_dialogue("\"Are you sure? Think again!\"")
        hide_npc(277)
    elseif var_0000 == 9 then
        add_dialogue("\"At least one sign is true, and at least one sign is false.\"")
        hide_npc(277)
    elseif var_0000 == 10 then
        add_dialogue("\"Two of these signs are either true or false!\"")
        hide_npc(277)
    elseif var_0000 == 11 then
        add_dialogue("\"No no no! Think again!\"")
        hide_npc(277)
    elseif var_0000 == 12 then
        add_dialogue("\"Each sign could be either true or false!\"")
        hide_npc(277)
    elseif var_0000 == 13 then
        add_dialogue("\"Stop the Avatar! I will come through the Black Gate now! Do not let him near!\"")
        hide_npc(277)
    elseif var_0000 == 14 then
        add_dialogue("\"So, Avatar! The moment of truth has come! You can destroy the Black Gate, but you will never return to your beloved Earth. Or you can come through now and go home! It is your choice!\"")
        hide_npc(277)
    elseif var_0000 > 17 and var_0000 < 22 then
        add_dialogue("\"Ha ha ha ha ha ha!\"")
        hide_npc(277)
    elseif var_0000 == 22 then
        add_dialogue("\"Poor Avatar... poor, poor Avatar...\"")
        hide_npc(277)
    elseif var_0000 == 23 then
        add_dialogue("\"Well done, my friend! You are truly an Avatar!\"")
        hide_npc(277)
    elseif var_0000 == 24 then
        add_dialogue("\"You are travelling in the wrong direction, my friend!\"")
        hide_npc(277)
    elseif var_0000 == 25 then
        add_dialogue("\"Go away!!\"")
        hide_npc(277)
    elseif var_0000 == 26 then
        add_dialogue("\"That is precisely the thing to do, Avatar!\"")
        hide_npc(277)
    elseif var_0000 == 27 then
        add_dialogue("\"You had best not do that, Avatar!\"")
        hide_npc(277)
    elseif var_0000 == 28 then
        add_dialogue("\"Do you really know where you are going, Avatar?\"")
        hide_npc(277)
    elseif var_0000 == 29 then
        add_dialogue("\"Yes, that is the proper direction to travel, Avatar.\"")
        hide_npc(277)
    else
        add_dialogue("\"Ho ho ha ha heh heh heh!\"")
    end
end