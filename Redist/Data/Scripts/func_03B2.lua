require "U7LuaFuncs"
-- Function 03B2: Guard NPC dialogue
function func_03B2(eventid, itemref)
    -- Local variable (1 as per .localc)
    local local0

    if eventid == 0 then
        return -- abrt
    end

    local0 = callis_001C(callis_001B(itemref))
    _SwitchTalkTo(0, -258)
    say("You see a tough-looking guard who takes his job -very- seriously.")

    while true do
        _AddAnswer({"bye", "job", "name"})
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"I am a guard.\"")
            _RemoveAnswer("name")
        elseif answer == "job" then
            say("The man looks at you like you are an ignoramus. \"I am a guard, idiot. Thou shouldst go about thy business.\"")
        elseif answer == "bye" then
            say("\"Goodbye.\"")
            break
        end

        -- Note: Original has 'db 40' here, possibly a debug artifact, ignored
    end

    return
end

-- Helper functions
function say(message)
    print(message) -- Adjust to your dialogue system
end

function wait_for_answer()
    return "bye" -- Placeholder
end