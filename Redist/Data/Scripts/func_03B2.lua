--- Best guess: Manages a guard NPC’s dialogue, responding gruffly to name and job queries, likely for immersion or quest interaction.
function func_03B2(eventid, objectref)
    local var_0000

    var_0000 = unknown_001CH(unknown_001BH(objectref))
    if eventid == 0 then
        return
    end
    switch_talk_to(0, 258)
    start_conversation()
    add_answer({"bye", "job", "name"})
    add_dialogue("You see a tough-looking guard who takes his job -very- seriously.")
    while true do
        local answer = get_answer()
        if answer == "name" then
            add_dialogue("\"I am a guard.\"")
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("The man looks at you like you are an ignoramus. \"I am a guard, idiot. Thou shouldst go about thy business.\"")
        elseif answer == "bye" then
            add_dialogue("\"Goodbye.\"")
            break
        end
    end
    return
end