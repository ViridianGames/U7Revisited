--- Best guess: Manages Syria's dialogue, a fighter at the Library of Scars in Jhelom, discussing her role, the stolen honor flag, and duels with Sprellic, with flag-based flag return and combat triggers.
function npc_syria_0126(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006

    if eventid ~= 1 then
        if eventid == 0 then
            utility_unknown_1070(126)
        end
        return
    end

    start_conversation()
    switch_talk_to(126)
    var_0000 = get_lord_or_lady()
    var_0001 = get_schedule()
    var_0002 = get_npc_name(126)
    var_0003 = get_npc_name(125)
    var_0004 = get_npc_name(127)
    var_0005 = npc_id_in_party(125)
    add_answer({"bye", "job", "name"})
    if not get_flag(360) and var_0001 ~= 4 then
        if not get_flag(362) then
            add_answer("return flag")
        end
    end
    if var_0001 == 4 then
        if not get_flag(360) then
            add_dialogue("\"I see that coward Sprellic has given thee the flag so that it may be returned to us. Thou hadst better hand it over.\"")
            var_0006 = remove_party_items(359, 359, 359, 286, 1)
            if var_0006 then
                add_dialogue("She takes the banner from you.")
                add_dialogue("\"This matter is now settled. But tell that worm Sprellic from me that he had better keep his hands off of other people's property in the future.\"")
                set_flag(362, true)
                set_flag(356, true)
                utility_unknown_1041(100)
                return
            else
                add_dialogue("\"It has come to our attention that thou hast been given our honor flag. Apparently Sprellic gave it to thee to return to us. If thou dost wish to keep it then our quarrel is now with thee.\"")
                utility_unknown_1041(100)
                set_alignment(3, var_0002)
                set_alignment(3, var_0004)
                set_alignment(3, var_0003)
                set_schedule_type(0, var_0002)
                set_schedule_type(0, var_0004)
                set_schedule_type(0, var_0003)
                return
            end
        end
        if get_flag(368) and not get_flag(360) then
            add_dialogue("\"Thou mayest fight for Sprellic, but I fight for honor!\"")
            utility_unknown_1041(100)
            set_alignment(3, var_0002)
            set_alignment(3, var_0004)
            set_alignment(3, var_0003)
            set_schedule_type(0, var_0002)
            set_schedule_type(0, var_0004)
            set_schedule_type(0, var_0003)
            return
        end
    else
        if get_flag(368) and not get_flag(360) then
            add_dialogue("\"Meet us at the dueling area at next noon!\"")
            return
        end
        if not get_flag(360) then
            add_dialogue("\"It has come to our attention that thou hast been given our honor flag. Apparently Sprellic gave it to thee to return to us. If thou dost wish to keep it then our quarrel is now with thee.\"")
            add_dialogue("\"Prepare to die!\"")
            utility_unknown_1041(100)
            set_alignment(3, var_0002)
            set_alignment(3, var_0004)
            set_alignment(3, var_0003)
            set_schedule_type(0, var_0002)
            set_schedule_type(0, var_0004)
            set_schedule_type(0, var_0003)
            return
        end
    end
    if not get_flag(376) then
        add_dialogue("Standing before you is a statuesque fighting woman with eyes that radiate a familiarity with danger.")
        set_flag(376, true)
    else
        add_dialogue("\"It seems we meet again,\" says Syria.")
    end
    while true do
        if cmps("name") then
            add_dialogue("\"I am Syria, a fighter from the south.\"")
            remove_answer("name")
        elseif cmps("job") then
            add_dialogue("\"Currently I am resting from my last voyage as a mercenary. I am studying in Jhelom with the fighting trainer De Snel at the Library of Scars.\"")
            add_answer({"Library of Scars", "De Snel", "Jhelom"})
        elseif cmps("Jhelom") then
            add_dialogue("\"This is a city of fighters and duels. If thou dost not like it the way it is, then leave. Duels are fought here for many reasons. I have mine own reasons for fighting them.\"")
            add_answer("duels")
            remove_answer("Jhelom")
        elseif cmps("duels") then
            if not get_flag(356) then
                add_dialogue("\"There is no question that Sprellic is the one who took the honor flag of our school. If he does not wish to fight the duels then he has only to return it.\"")
                add_answer({"return", "Sprellic"})
            else
                add_dialogue("\"A pity we could not teach that little fool a lesson. Still, we have regained our honor and that is enough. For now.\"")
                add_answer("Sprellic")
            end
            remove_answer("duels")
        elseif cmps("return") then
            add_dialogue("\"Since Sprellic has not done this, it proves that he is sincere in the grievous insult that he has made against us.\"")
            if var_0005 then
                switch_talk_to(125)
                add_dialogue("\"And I shall grievously insult him-- through his heart!\"")
                _hide_npc(125)
                switch_talk_to(126)
            end
            remove_answer("return")
        elseif cmps("Sprellic") then
            if not get_flag(356) then
                add_dialogue("\"I was on guard when Sprellic took our club's honor flag. I saw him take it but I lost him in the shadows of the night. My punishment was ten lashes for allowing the thief to escape. I mean to repay him for that.\"")
            else
                add_dialogue("\"A pity we could not teach that little fool a lesson. Perhaps we have anyway. For his sake, he had better have learned it well.\"")
            end
            remove_answer("Sprellic")
        elseif cmps("Library of Scars") then
            add_dialogue("\"The Library of Scars is the greatest guild of fighters in Britannia.\"")
            if var_0005 then
                switch_talk_to(125)
                add_dialogue("\"Here! Here!\"")
                _hide_npc(125)
                switch_talk_to(126)
            end
            remove_answer("Library of Scars")
        elseif cmps("De Snel") then
            add_dialogue("\"Master De Snel teaches a style of pure fighting which takes thee beyond all previous disciplines that thou mayest have learned. He is a great man.\"")
            remove_answer("De Snel")
        elseif cmps("return flag") then
            add_dialogue("\"I understand that coward Sprellic has given thee the flag so that it may be returned to us. Thou hadst better hand it over.\"")
            var_0006 = remove_party_items(359, 359, 359, 286, 1)
            if var_0006 then
                add_dialogue("She takes the banner from you.")
                add_dialogue("\"This matter is now settled. But tell that worm Sprellic from me that he had better keep his hands off of other people's property in the future.\"")
                set_flag(362, true)
                set_flag(356, true)
                utility_unknown_1041(100)
            else
                add_dialogue("\"It has come to our attention that thou hast been given our honor flag. Apparently Sprellic gave it to thee to return to us. If thou dost wish to keep it then our quarrel is now with thee.\"")
                if var_0001 ~= 4 then
                    add_dialogue("\"Meet us at the dueling area at next noon!\"")
                else
                    add_dialogue("\"Prepare to die!\"")
                    utility_unknown_1041(100)
                    set_alignment(3, var_0002)
                    set_alignment(3, var_0004)
                    set_alignment(3, var_0003)
                    set_schedule_type(0, var_0002)
                    set_schedule_type(0, var_0004)
                    set_schedule_type(0, var_0003)
                end
            end
            remove_answer("return flag")
        elseif cmps("bye") then
            break
        end
    end
    add_dialogue("\"We do not appreciate people who interfere in our private matters. We shall be watching thee.\"")
    return
end