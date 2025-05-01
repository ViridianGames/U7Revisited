-- Function 0854: Sell meat portions
function func_0854(eventid, itemref)
    local local0, local1, local2, local3, local4, local5

    local0 = get_player_name(eventid)
    ::start::
    add_dialogue(itemref, "\"How many portions wouldst thou wish to sell?\"")
    local1 = _AskNumber(0, 1, 10, 0)
    if local1 == 0 then
        add_dialogue(itemref, "\"Oh, my. We truly do need the meat. Well, perhaps next time.\"")
        return
    end
    local2 = check_gold(8, -359, 377, -357)
    if local2 < local1 then
        add_dialogue(itemref, "\"Thou cannot sell me what thou dost not have! Now, truly...!\"")
        goto start
    end
    add_dialogue(itemref, "\"Excellent! I accept the trade, " .. local0 .. ". Here is thy gold.\"")
    local3 = local1 * 5
    local4 = give_item(true, -359, -359, 644, local3)
    if not local4 then
        add_dialogue(itemref, "\"Oh, dear. Thou cannot possibly carry this much gold! Perhaps thou mayest return when thou hast dropped something else.\"")
        return
    end
    local5 = remove_gold(true, 8, -359, 377, local1)
end