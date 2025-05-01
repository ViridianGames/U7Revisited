-- Function 0895: Bollux golem dialogue
function func_0895(eventid, itemref)
    local local0, local1, local2, local3

    switch_talk_to(289, 0)
    say(itemref, "\"Bollux stares ahead, almost vacantly. Despite his features and lack of motion, it is apparent by his expression that some of Castambre's magic still resides within.\"")
    while local0 do
        local1 = _GetContainerItems(4, 243, 797, itemref)
        local2 = check_position(176, 1, 797, itemref)
        if _GetItemQuality(local2) == 243 then
            say(itemref, "\"Bollux turns to see Adjar standing nearby, quite alive. Instantly, Bollux's expression changes detectably.\"")
            _HideNPC(-289)
            switch_talk_to(289, 1)
            switch_talk_to(288, 0)
            say(itemref, "\"Adjhar simply smiles.~\"Greetings, brother.\"")
        end
        local0 = get_next_item() -- sloop
    end
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
            say(itemref, "\"I am here... to guard the Shrine... of Love.\"")
        elseif answer == "bye" then
            say(itemref, "\"Fare thee... well.\"*")
            return
        end
    end
    return
end