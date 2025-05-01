-- Function 0896: Bollux golem post-event dialogue
function func_0896(eventid, itemref)
    switch_talk_to(289, 0)
    add_dialogue(itemref, "\"The golem seems to have regained his staid composure. However, life is still evident within his gem-like eyes.\"")
    add_answer({"bye", "job", "name"})
    while true do
        local answer = get_answer()
        if answer == "name" then
            remove_answer("name")
            if not get_flag(797) then
                add_dialogue(itemref, "\"He tilts his head and stares at you quizzically.~ \"I apologize. Did I not already tell thee my master called me Bollux?\"")
            else
                add_dialogue(itemref, "\"My master named me Bollux.\"")
                set_flag(797, true)
            end
        elseif answer == "job" then
            add_dialogue(itemref, "\"I am here to guard....\" He pauses, obviously deep in thought.\"I am without a duty now.\"")
            remove_answer("job")
        elseif answer == "bye" then
            add_dialogue(itemref, "\"Good... bye.\"*")
            return
        end
    end
    return
end