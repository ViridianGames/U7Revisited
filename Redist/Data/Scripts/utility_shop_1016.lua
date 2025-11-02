--- Best guess: Manages item purchasing by NPCs, calculating quantity, checking gold, distributing items among party members, and returning a status code (0-3).
function utility_shop_1016(var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006)
    local var_0007, var_0008, var_0009, var_0010, var_0011, var_0012, var_0013, var_0014, var_0015, var_0016, var_0017, var_0018

    var_0007 = get_party_gold()
    if var_0002 == 0 then
        var_0008 = 1
    else
        var_0008 = input_numeric_value(1, 1, var_0002, var_0001)
    end
    if var_0004 > 1 then
        var_0009 = var_0004 * var_0008
    else
        var_0009 = var_0008
    end
    if var_0008 == 0 then
        var_0010 = 0
    elseif var_0007 >= var_0003 * var_0008 then
        var_0011 = add_party_items(var_0000, var_0005, 359, var_0006, var_0009)
        if var_0011 then
            var_0010 = 1
            var_0012 = remove_party_items(true, 359, 359, 644, var_0003 * var_0008)
            var_0013 = 0
            var_0014 = false
            for _, var_0017 in ipairs(var_0000) do
                var_0018 = get_npc_number(var_0017)
                remove_item(var_0017)
                if var_0018 ~= 356 then
                    var_0013 = var_0013 + 1
                    switch_talk_to(var_0018)
                    var_0014 = true
                    if var_0004 == 1 then
                        add_dialogue("\"I will carry that.\"")
                    elseif var_0013 == 1 then
                        add_dialogue("\"I will carry some.\"")
                    else
                        add_dialogue("\"I will carry some, as well.\"")
                    end
                    hide_npc(var_0018)
                end
            end
            if var_0014 then
                reset_conv_face()
            end
        else
            var_0010 = 2
        end
    else
        var_0010 = 3
    end
    return var_0010
end