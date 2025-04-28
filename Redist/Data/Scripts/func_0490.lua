require "U7LuaFuncs"
-- Manages Rowena's dialogue in Skara Brae, as Horance's enthralled ghostly lady, covering her role in the Dark Tower and her detachment.
function func_0490(eventid, itemref)
    local local0, local1, local2, local3

    if eventid == 1 then
        if not get_flag(440) then
            switch_talk_to(-144, 0)
            say("The beautiful ghost looks through you with a slack look. Nothing you do seems to attract her attention.*")
            set_flag(423, false)
            return
        end
        if not get_flag(408) then
            add_answer("sacrifice")
        end
        local0 = is_player_female()
        local1 = get_player_name()
        if not get_flag(422) then
            switch_talk_to(-144, 1)
            apply_effect() -- Unmapped intrinsic
        end
        if not get_flag(426) then
            switch_talk_to(-144, 1)
            apply_effect() -- Unmapped intrinsic
        end
        if not get_flag(423) and not get_flag(425) then
            switch_talk_to(-144, 1)
            apply_effect() -- Unmapped intrinsic
        end
        local2 = get_part_of_day()
        local3 = get_schedule(-144)
        if local2 == 0 or local2 == 1 then
            if local3 == 14 then
                switch_talk_to(-144, 0)
                apply_effect() -- Unmapped intrinsic
            elseif local3 ~= 16 then
                switch_talk_to(-144, 0)
                apply_effect() -- Unmapped intrinsic
            end
        end
        switch_talk_to(-144, 0)
        if not get_flag(457) then
            say("You see a ghostly lady wearing a long, black gown. Something is a bit strange about the way she looks, but you can't quite place it. After a pause, she says, \"Greetings, " .. local1 .. ". I am Rowena, lady of this wondrous tower.\" She gestures around the room, indicating the moldering walls and cobwebbed rafters.")
            set_flag(457, true)
        else
            say("Rowena smiles in an abstract manner as you approach. \"Ah, thou hast returned, " .. local1 .. ". How may the lady of the tower be of assistance to thee?\"")
        end
        add_answer({"bye", "tower", "job", "name"})
        while true do
            local answer = get_answer()
            if answer == "name" then
                say("\"I am called... Rowena\"")
                remove_answer("name")
            elseif answer == "job" then
                say("She stares blankly for a second, then, as if on cue, \"I am the Mistress of the Tower. I tend to my Lord Horance's needs and keep our place looking respectable.\" It would appear that she's been falling behind in the latter duty.")
                add_answer("Horance")
            elseif answer == "tower" then
                say("After a moment, \"This is a lovely tower, dost thou not agree?\" Before you can answer, she continues.~~ \"Dost thou see the lovely rays of light playing across the flagstones of the floor? Water sparkles in the fountain. This is truly a beautiful place in which to live.\" Her eyes fix upon the floor.")
                remove_answer("tower")
            elseif answer == "Horance" then
                say("She blinks once, then, \"Horance... What a wonderful name. He found me lost and lonely and brought me here to be a lady. Is he not truly the most magnificent of Lords?\"")
                remove_answer("Horance")
            elseif answer == "bye" then
                say("She pauses. \"Goodbye, " .. local1 .. ". I hope thou hast enjoyed thy visit to our glorious tower. Please, return whenever thou wishest.\" You feel as if you've been speaking to a statue.*")
                break
            end
        end
    elseif eventid == 0 then
        return
    end
    return
end