--- Best guess: Handles dialogue with Bollux after he loses his duty.
function utility_unknown_0918(eventid, objectref)
    start_conversation()
    switch_talk_to(289) --- Guess: Initiates dialogue
    add_dialogue("@The golem seems to have regained his staid composure...@")
    add_answer({"bye", "job", "name"}) --- Guess: Adds dialogue options
    while true do
        if compare_answer("name", 1) then
            remove_answer("name") --- Guess: Removes dialogue option
            if not get_flag(797) then
                add_dialogue("@He tilts his head and stares at you quizzicaly...@")
            else
                add_dialogue("@My master named me Bollux.@")
                set_flag(797, true)
            end
        elseif compare_answer("job", 1) then
            add_dialogue("@I am here to guard....' He pauses, obviously deep in thought.'I am without a duty now.@")
            remove_answer("job") --- Guess: Removes dialogue option
        elseif compare_answer("bye", 1) then
            add_dialogue("@Good... bye.@")
            return
        end
    end
end