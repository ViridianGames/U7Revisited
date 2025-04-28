require "U7LuaFuncs"
-- Function 0893: Adjhar golem final dialogue
function func_0893(eventid, itemref)
    _SwitchTalkTo(0, -288)
    say(itemref, "\"Adjhar appears to have resumed the stance of a more traditional golem guardian -- staunch and distant. However, it is impossible to miss the glimmer of intelligence in his eyes.\"")
    _AddAnswer({"bye", "job", "name"})
    while true do
        local answer = get_answer()
        if answer == "name" then
            say(itemref, "\"I am and always will be the one called Adjhar.\"")
            _RemoveAnswer("name")
        elseif answer == "job" then
            say(itemref, "\"Now that thou hast mastered the Principle of Love, I no longer serve a function.\"")
            _RemoveAnswer("job")
        elseif answer == "bye" then
            say(itemref, "\"Goodbye, Avatar. As always I thank thee for thy kindness in assisting two brothers in need. Forget not the lessons taught by the Shrines.\"*")
            return
        end
    end
    return
end