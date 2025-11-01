--- Best guess: Handles final dialogue with Adjhar after mastering the Principle of Love.
function utility_unknown_0915(eventid, objectref)
    start_conversation()
    switch_talk_to(0, 288) --- Guess: Initiates dialogue
    add_dialogue("@Adjhar appears to have resumed the stance of a more traditional golem guardian...@")
    add_answer({"bye", "job", "name"}) --- Guess: Adds dialogue options
    while true do
        if compare_answer("name", 1) then
            add_dialogue("@I am and always will be the one called Adjhar.@")
            remove_answer("name") --- Guess: Removes dialogue option
        elseif compare_answer("job", 1) then
            add_dialogue("@Now that thou hast mastered the Principle of Love, I no longer serve a function.@")
            remove_answer("job") --- Guess: Removes dialogue option
        elseif compare_answer("bye", 1) then
            add_dialogue("@Goodbye, Avatar. As always I thank thee for thy kindness in assisting two brothers in need...@")
            return
        end
    end
end