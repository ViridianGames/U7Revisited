-- Function 0892: Adjhar golem post-quest dialogue
function func_0892(eventid, itemref)
    local local0, local1

    switch_talk_to(288, 0)
    add_dialogue(itemref, "\"Adjhar appears to have resumed the stance of a more traditional golem guardian -- staunch and unmoving. However, it is impossible to miss the glimmer of intelligence in his eyes.\"")
    add_answer({"bye", "job", "name"})
    local0 = false
    while true do
        local answer = get_answer()
        if answer == "name" then
            add_dialogue(itemref, "\"As thou must know by now, my creator chose to call me Adjhar.\"")
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue(itemref, "\"I was created to be one of many protectors to the Shrines of the Three Principles. However,\" he pauses, \"my duty also included being the keeper of the Talisman of Love.\"")
            remove_answer("job")
            add_answer("Talisman")
        elseif answer == "Talisman" then
            remove_answer("Talisman")
            add_dialogue(itemref, "\"Dost thou want the Talisman of Love?\"")
            if get_answer() then
                add_dialogue(itemref, "\"I was put here to protect the Shrines and prevent any from acquiring the Talisman. Any except the Avatar who demonstrated knowledge and understanding of Love. The Talisman is thine, Avatar.\"~He brings his stone hand to his heart and opens a panel on the front of his chest. Reaching inside with his other hand, he brings forth a beautiful yellow talisman.")
                local0 = call_0024H(955)
                _SetItemFrame(10, local0)
                local1 = call_0907H(_GetPlayerName(-356))
                if local1 then
                    add_dialogue(itemref, "\"He places the Talisman in your palm. ~\"Thou hast earned this and the honors and powers associated with it. Thou art truly an Avatar.\"")
                    set_flag(808, true)
                else
                    add_dialogue(itemref, "\"I am sorry, but thou must be less burdened to receive this one of three greatest of all blessings.\"")
                end
            else
                add_dialogue(itemref, "\"Thou art truly deserving of such an artifact. But if thou dost not wish to utilize the Shrines, I must respect thy wishes.\"")
            end
        elseif answer == "bye" then
            add_dialogue(itemref, "\"I bid thee farewell.\"*")
            if not get_flag(808) then
                add_dialogue(itemref, "\"Mark the wisdom of the Shrine of Love well, Avatar.\"*")
            end
            return
        end
    end
    if get_flag(808) and not get_flag(807) then
        call_06F9H(7, local0)
        return
    end
    return
end