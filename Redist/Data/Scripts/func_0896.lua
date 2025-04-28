require "U7LuaFuncs"
-- Function 0896: Bollux golem post-event dialogue
function func_0896(eventid, itemref)
    _SwitchTalkTo(0, -289)
    say(itemref, "\"The golem seems to have regained his staid composure. However, life is still evident within his gem-like eyes.\"")
    _AddAnswer({"bye", "job", "name"})
    while true do
        local answer = get_answer()
        if answer == "name" then
            _RemoveAnswer("name")
            if not get_flag(797) then
                say(itemref, "\"He tilts his head and stares at you quizzically.~ \"I apologize. Did I not already tell thee my master called me Bollux?\"")
            else
                say(itemref, "\"My master named me Bollux.\"")
                set_flag(797, true)
            end
        elseif answer == "job" then
            say(itemref, "\"I am here to guard....\" He pauses, obviously deep in thought.\"I am without a duty now.\"")
            _RemoveAnswer("job")
        elseif answer == "bye" then
            say(itemref, "\"Good... bye.\"*")
            return
        end
    end
    return
end