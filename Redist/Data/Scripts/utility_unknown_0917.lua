--- Best guess: Manages dialogue with Bollux after restoration, acknowledging Adjhar's revival.
function utility_unknown_0917(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    start_conversation()
    switch_talk_to(289) --- Guess: Initiates dialogue
    add_dialogue("@Bollux stares ahead, almost vacantly...@")
    var_0000 = set_npc_location(0, 40, 1015, objectref) --- Guess: Sets NPC location
    for _, var_0003 in ipairs({1, 2, 3, 0}) do
        if get_containerobject_s(4, 243, 797, objectref) or get_object_quality(set_npc_location(176, 1, 797, objectref)) == 243 then
            add_dialogue("@Bollux turns to see Adjar standing nearby, quite alive...@")
            hide_npc(289) --- Guess: Hides NPC
            switch_talk_to(1, 289) --- Guess: Initiates dialogue
            switch_talk_to(288) --- Guess: Initiates dialogue
            add_dialogue("@Adjhar simply smiles.~'Greetings, brother.'@")
        end
    end
    add_answer({"bye", "job", "name"}) --- Guess: Adds dialogue options
    while true do
        if compare_answer("name", 1) then
            remove_answer("name") --- Guess: Removes dialogue option
            if not get_flag(797) then
                remove_answer("name") --- Guess: Removes dialogue option
                add_dialogue("@He tilts his head and stares at you quizzicaly...@")
            else
                add_dialogue("@My master named me Bollux.@")
                set_flag(797, true)
            end
        elseif compare_answer("job", 1) then
            add_dialogue("@I am here... to guard the Shrine... of Love.@")
        elseif compare_answer("bye", 1) then
            add_dialogue("@Fare thee... well.@")
            return
        end
    end
end