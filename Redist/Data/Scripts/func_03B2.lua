-- Function 03B2: Guard NPC dialogue
function func_03B2(eventid, itemref)
    -- Local variable (1 as per .localc)
    local local0

    if eventid == 0 then
        return -- abrt
    end

    local0 = callis_001C(callis_001B(itemref))
    switch_talk_to(258, 0)
    add_dialogue("You see a tough-looking guard who takes his job -very- seriously.")

    while true do
        add_answer({"bye", "job", "name"})
        local answer = wait_for_answer()

        if answer == "name" then
            add_dialogue("\"I am a guard.\"")
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue("The man looks at you like you are an ignoramus. \"I am a guard, idiot. Thou shouldst go about thy business.\"")
        elseif answer == "bye" then
            add_dialogue("\"Goodbye.\"")
            break
        end

        -- Note: Original has 'db 40' here, possibly a debug artifact, ignored
    end

    return
end

-- Helper functions
function add_dialogue(message)
    print(message) -- Adjust to your dialogue system
end

function wait_for_answer()
    return "bye" -- Placeholder
end