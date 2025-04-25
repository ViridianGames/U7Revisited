-- Manages Syria's dialogue in Jhelom, covering her mercenary background, the honor flag, and Sprellic's duel.
function func_047E(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6

    if eventid == 1 then
        switch_talk_to(-126, 0)
        local0 = get_player_name()
        local1 = get_party_size()
        local2 = get_item_type(-126)
        local3 = get_item_type(-125)
        local4 = get_item_type(-127)
        local5 = switch_talk_to(-125)

        add_answer({"bye", "job", "name"})

        if not get_flag(360) and local1 == 4 and not get_flag(362) then
            add_answer("return flag")
        end

        if local1 == 4 then
            if not get_flag(360) then
                say("\"I see that coward Sprellic has given thee the flag so that it may be returned to us. Thou hadst better hand it over.\"")
                local6 = remove_item(-359, -359, -359, 286, 1) -- Unmapped intrinsic
                if local6 then
                    say("She takes the banner from you.")
                    say("\"This matter is now settled. But tell that worm Sprellic from me that he had better keep his hands off of other people's property in the future.\"*")
                    set_flag(362, true)
                    set_flag(356, true)
                    apply_effect(100) -- Unmapped intrinsic 0911
                    return
                else
                    say("\"It has come to our attention that thou hast been given our honor flag. Apparently Sprellic gave it to thee to return to us. If thou dost wish to keep it then our quarrel is now with thee.\"")
                    apply_effect(100) -- Unmapped intrinsic 0911
                    set_schedule(3, local2)
                    set_schedule(3, local4)
                    set_schedule(3, local3)
                    set_schedule(0, local2)
                    set_schedule(0, local4)
                    set_schedule(0, local3)
                    return
                end
            elseif get_flag(368) and not get_flag(360) then
                say("\"Thou mayest fight for Sprellic, but I fight for honor!\"*")
                apply_effect(100) -- Unmapped intrinsic 0911
                set_schedule(3, local2)
                set_schedule(3, local4)
                set_schedule(3, local3)
                set_schedule(0, local2)
                set_schedule(0, local4)
                set_schedule(0, local3)
                return
            end
        end

        if not get_flag(376) then
            say("Standing before you is a statuesque fighting woman with eyes that radiate a familiarity with danger.")
            set_flag(376, true)
        else
            say("\"It seems we meet again,\" says Syria.")
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                say("\"I am Syria, a fighter from the south.\"")
                remove_answer("name")
            elseif answer == "job" then
                say("\"Currently I am resting from my last voyage as a mercenary. I am studying in Jhelom with the fighting trainer De Snel at the Library of Scars.\"")
                add_answer({"Library of Scars", "De Snel", "Jhelom"})
            elseif answer == "Jhelom" then
                say("\"This is a city of fighters and duels. If thou dost not like it the way it is, then leave. Duels are fought here for many reasons. I have mine own reasons for fighting them.\"")
                add_answer("duels")
                remove_answer("Jhelom")
            elseif answer == "duels" then
                if not get_flag(356) then
                    say("\"There is no question that Sprellic is the one who took the honor flag of our school. If he does not wish to fight the duels then he has only to return it.\"")
                    add_answer({"return", "Sprellic"})
                else
                    say("\"A pity we could not teach that little fool a lesson. Still, we have regained our honor and that is enough. For now.\"")
                    add_answer("Sprellic")
                end
                remove_answer("duels")
            elseif answer == "return" then
                say("\"Since Sprellic has not done this, it proves that he is sincere in the grievous insult that he has made against us.\"*")
                if local5 then
                    switch_talk_to(-125, 0)
                    say("\"And I shall grievously insult him-- through his heart!\"*")
                    hide_npc(-125)
                    switch_talk_to(-126, 0)
                end
                remove_answer("return")
            elseif answer == "Sprellic" then
                if not get_flag(356) then
                    say("\"I was on guard when Sprellic took our club's honor flag. I saw him take it but I lost him in the shadows of the night. My punishment was ten lashes for allowing the thief to escape. I mean to repay him for that.\"")
                else
                    say("\"A pity we could not teach that little fool a lesson. Perhaps we have anyway. For his sake, he had better have learned it well.\"")
                end
                remove_answer("Sprellic")
            elseif answer == "Library of Scars" then
                say("\"The Library of Scars is the greatest guild of fighters in Britannia.\"*")
                if local5 then
                    switch_talk_to(-125, 0)
                    say("\"Here! Here!\"*")
                    hide_npc(-125)
                    switch_talk_to(-126, 0)
                end
                remove_answer("Library of Scars")
            elseif answer == "De Snel" then
                say("\"Master De Snel teaches a style of pure fighting which takes thee beyond all previous disciplines that thou mayest have learned. He is a great man.\"")
                remove_answer("De Snel")
            elseif answer == "return flag" then
                say("\"I understand that coward Sprellic has given thee the flag so that it may be returned to us. Thou hadst better hand it over.\"")
                local6 = remove_item(-359, -359, -359, 286, 1) -- Unmapped intrinsic
                if local6 then
                    say("She takes the banner from you.")
                    say("\"This matter is now settled. But tell that worm Sprellic from me that he had better keep his hands off of other people's property in the future.\"")
                    set_flag(362, true)
                    set_flag(356, true)
                    apply_effect(100) -- Unmapped intrinsic 0911
                    return
                else
                    say("\"It has come to our attention that thou hast been given our honor flag. Apparently Sprellic gave it to thee to return to us. If thou dost wish to keep it then our quarrel is now with thee.\"")
                    if local1 ~= 4 then
                        say("\"Meet us at the dueling area at next noon!\"*")
                    else
                        say("\"Prepare to die!\"*")
                        apply_effect(100) -- Unmapped intrinsic 0911
                        set_schedule(3, local2)
                        set_schedule(3, local4)
                        set_schedule(3, local3)
                        set_schedule(0, local2)
                        set_schedule(0, local4)
                        set_schedule(0, local3)
                    end
                    return
                end
                remove_answer("return flag")
            elseif answer == "bye" then
                say("\"We do not appreciate people who interfere in our private matters. We shall be watching thee.\"*")
                break
            end
        end
    elseif eventid == 0 then
        switch_talk_to(-126)
    end
    return
end