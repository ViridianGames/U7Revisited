-- Function 0893: Adjhar golem final dialogue
function func_0893(eventid, itemref)
    switch_talk_to(288, 0)
    add_dialogue(itemref, "\"Adjhar appears to have resumed the stance of a more traditional golem guardian -- staunch and distant. However, it is impossible to miss the glimmer of intelligence in his eyes.\"")
    add_answer({"bye", "job", "name"})
    while true do
        local answer = get_answer()
        if answer == "name" then
            add_dialogue(itemref, "\"I am and always will be the one called Adjhar.\"")
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue(itemref, "\"Now that thou hast mastered the Principle of Love, I no longer serve a function.\"")
            remove_answer("job")
        elseif answer == "bye" then
            add_dialogue(itemref, "\"Goodbye, Avatar. As always I thank thee for thy kindness in assisting two brothers in need. Forget not the lessons taught by the Shrines.\"*")
            return
        end
    end
    return
end