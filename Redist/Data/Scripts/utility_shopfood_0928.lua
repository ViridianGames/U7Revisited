--- Best guess: Manages a shop dialogue for purchasing food and drink items, handling item selection, pricing, and inventory checks.
function utility_shopfood_0928()
    start_conversation()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010, var_0011, var_0012, var_0013

    var_0000 = get_lord_or_lady()
    save_answers()
    var_0001 = true
    var_0002 = {"wine", "ale", "cake", "bread", "Silverleaf", "ham", "trout", "mead", "beef", "mutton", "nothing"}
    var_0003 = {616, 616, 377, 377, 377, 377, 377, 616, 377, 377, 0}
    var_0004 = {5, 3, 4, 0, 31, 11, 12, 0, 9, 8, 359}
    var_0005 = {4, 4, 2, 3, 45, 18, 4, 12, 18, 5, 0}
    var_0006 = ""
    var_0007 = 0
    var_0008 = {" for a bottle", " for a bottle", " for one piece", " for a loaf", " for one portion", " for one slice", " for one portion", " for a bottle", " for a rack", " for one portion", ""}
    var_0009 = 1
    add_dialogue("\"What wouldst thou like to buy?\"")
    while var_0001 do
        var_0010 = utility_unknown_1036(var_0002)
        if var_0010 == 1 then
            add_dialogue("\"Fine.\"")
            var_0001 = false
        elseif var_0010 == 7 then
            if not get_flag(299) then
                add_dialogue("\"'Tis all gone, " .. var_0000 .. ". And the logger will cut down no more Silverleaf trees. I expect it will become even more of a delicacy, and more expensive, if I can ever get any more to sell.\"")
            end
        else
            var_0011 = utility_shop_1051(var_0006, var_0002[var_0010], var_0007, var_0005[var_0010], var_0008[var_0010])
            var_0012 = 0
            add_dialogue("^" .. var_0011 .. " Does that sound like a fair price?")
            var_0013 = ask_yes_no()
            if not var_0013 then
                if var_0003[var_0010] == 377 then
                    add_dialogue("\"How many wouldst thou like?\"")
                    var_0012 = utility_shop_1016(true, 1, 20, var_0005[var_0010], var_0009, var_0004[var_0010], var_0003[var_0010])
                else
                    var_0012 = utility_shop_1016(true, 1, 0, var_0005[var_0010], var_0009, var_0004[var_0010], var_0003[var_0010])
                end
            end
            if var_0012 == 1 then
                add_dialogue("\"Done!\"")
            elseif var_0012 == 2 then
                add_dialogue("\"Thou cannot possibly carry that much!\"")
            elseif var_0012 == 3 then
                add_dialogue("\"Thou dost not have enough gold for that!\"")
            end
            add_dialogue("\"Wouldst thou like something else?\"")
            var_0001 = ask_yes_no()
        end
    end
    restore_answers()
    return
end