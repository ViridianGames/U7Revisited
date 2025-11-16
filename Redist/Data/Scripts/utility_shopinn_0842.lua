-- tavern buy
function utility_shopinn_0842()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F

    debug_print("Started 0842")
    var_0000 = get_player_name()
    var_0001 = is_player_female()
    var_0002 = true
    var_0004 = {616, 616, 377, 377, 377, 616, 377, 377, 0}
    var_0005 = {3, 5, 4, 31, 13, 0, 0, 8, 359}
    var_0006 = {2, 3, 2, 30, 3, 7, 2, 3, 0}
    while var_0002 do
        debug_print("0842 loop started")
        var_000B = get_purchase_option({"\"What wouldst thou like?\"", "ale, 2 gold per bottle", "wine, 3 gold per bottle", "cake, 2 gold for one portion", "Silverleaf, 30 gold for one portion", "flounder, 3 gold for one portion", "mead, 7 gold for one bottle", "bread, 2 gold for one loaf", "mutton, 3 gold for one portion", "nothing" })
        debug_print("Get_purchase_option returned" .. var_000B)
        if var_000B == 0 then
            add_dialogue("\"Nothing at all? Well, alright.\"")
            if not var_0001 then
                add_dialogue("She bats her eyelashes at you and grins.")
            end
            var_0002 = false
        else
        if var_000B == 5 and not get_flag(299) then
            add_dialogue("\"I have none to sell thee, " .. var_0000 .. ", for the logger will no longer supply it.\"")
        else
            var_000B = 9 - var_000B -- All the arrays are backwards, for some reason.
            amount = ask_number("\"How many wouldst thou like?\"", 0, 20, 1)
            var_000D = purchase_object(var_0004[var_000B], var_0005[var_000B], var_0006[var_000B], amount)
        end
        if var_000D == 0 then
            add_dialogue("\"Nothing at all? Well, alright.\"")
        elseif var_000D == 1 then
             add_dialogue("\"'Tis thine!\"")
        elseif var_000D == 2 then
             add_dialogue("\"Thou cannot possibly carry that much, " .. var_0000 .. "!\"")
        elseif var_000D == 3 then
             add_dialogue("\"Hmmm. Thou dost not have enough gold!\"")
        end
        var_0002 = ask_yes_no("\"Wouldst thou like something else?\"")
        end
    end
end