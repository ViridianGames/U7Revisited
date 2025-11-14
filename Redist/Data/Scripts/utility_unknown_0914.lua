--- Best guess: Manages post-quest dialogue with Adjhar, offering the Talisman of Love.
function utility_unknown_0914(eventid, objectref)
    local var_0000, var_0001, var_0002

    start_conversation()
    switch_talk_to(288) --- Guess: Initiates dialogue
    add_dialogue("@Adjhar appears to have resumed the stance of a more traditional golem guardian...@")
    add_answer({"bye", "job", "name"}) --- Guess: Adds dialogue options
    var_0000 = false
    while true do
        if compare_answer("name", 1) then
            add_dialogue("@As thou must know by now, my creator chose to call me Adjhar.@")
            remove_answer("name") --- Guess: Removes dialogue option
        elseif compare_answer("job", 1) then
            add_dialogue("@I was created to be one of many protectors to the Shrines of the Three Principles...@")
            remove_answer("job") --- Guess: Removes dialogue option
            add_answer("Talisman") --- Guess: Adds dialogue option
        elseif compare_answer("Talisman", 1) then
            add_dialogue("@Dost thou want the Talisman of Love?@")
            remove_answer("Talisman") --- Guess: Removes dialogue option
            if get_dialogue_choice() then --- Guess: Gets dialogue choice
                add_dialogue("@I was put here to protect the Shrines and prevent any from acquiring the Talisman...@")
                var_0000 = set_object_shape(955, objectref) --- Guess: Sets item type
                set_object_frame(10, var_0000) --- Guess: Sets item frame
                var_0001 = add_object_to_party(get_object_owner(356)) --- Guess: Adds item to party
                if var_0001 then
                    add_dialogue("@He places the Talisman in your palm...@")
                    set_flag(808, true)
                    break
                else
                    add_dialogue("@I am sorry, but thou must be less burdened to receive this one of three greatest of all blessings.@")
                end
            else
                add_dialogue("@Thou art truly deserving of such an artifact...@")
            end
        elseif compare_answer("bye", 1) then
            add_dialogue("@I bid thee farewell.@")
            if not get_flag(808) then
                add_dialogue("@Mark the wisdom of the Shrine of Love well, Avatar.@")
            end
            return
        end
    end
    if get_flag(808) and not get_flag(807) then
        utility_event_0505(7, var_0000) --- External call to unknown function
        return
    end
end