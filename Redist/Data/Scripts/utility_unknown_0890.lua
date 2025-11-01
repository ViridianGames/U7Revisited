--- Best guess: Manages a merchant transaction, allowing the player to buy items with quantity and weight checks, using dialogue for negotiation.
function utility_unknown_0890()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C

    start_conversation()
    save_answers() --- Guess: Saves current answers
    var_0000 = true
    var_0001 = {"bedroll", "pick", "powder keg", "hoe", "shovel", "bag", "backpack", "oil flasks", "torch", "nothing"}
    var_0002 = {583, 624, 704, 626, 625, 802, 801, 782, 595, 0}
    var_0003 = {16, 12, 30, 10, 10, 3, 10, 48, 3, 0}
    var_0004 = {"a ", "a ", "a ", "a ", "a ", "a ", "a ", "", "a ", ""}
    var_0005 = 0
    var_0006 = {"", "", "", "", "", "", "", " for a dozen", "", ""}
    var_0007 = -359
    var_0008 = {1, 1, 1, 1, 1, 1, 1, 12, 1, 0}
    add_dialogue("@What can I sell to thee?@")
    while var_0000 do
        var_0009 = utility_unknown_1036(var_0001) --- External call to select item
        if var_0009 == 1 then
            add_dialogue("@Very good.@")
            var_0000 = false
        else
            var_000A = utility_shop_1051(var_0006[var_0009], var_0003[var_0009], var_0005, var_0001[var_0009], var_0004[var_0009]) --- External call to format price
            var_000B = 0
            add_dialogue("@^" .. var_000A .. ". Is that acceptable?@")
            var_000C = get_dialogue_choice() --- Guess: Gets player choice
            if var_000C then
                if var_0002[var_0009] == 595 or var_0002[var_0009] == 782 then
                    add_dialogue(var_0002[var_0009] == 782 and "@How many sets of twelve wouldst thou like?@" or "@How many wouldst thou like?@")
                    var_000B = utility_shop_1016(true, 1, 20, var_0003[var_0009], var_0008[var_0007], var_0007, var_0002[var_0009]) --- External call to process purchase
                else
                    var_000B = utility_shop_1016(false, 1, 0, var_0003[var_0009], var_0008[var_0007], var_0007, var_0002[var_0009]) --- External call to process purchase
                end
                if var_000B == 1 then
                    add_dialogue("@Very good!@")
                elseif var_000B == 2 then
                    add_dialogue("@I am sorry, but thou cannot possibly carry that much weight!@")
                elseif var_000B == 3 then
                    add_dialogue("@Thou dost not have enough gold for that,\" he says, shaking his head.~~\"Too many birds in the hand is worth a bush.\"@")
                end
                add_dialogue("@Wouldst thou care to purchase something else?@")
                var_0000 = get_dialogue_choice() --- Guess: Continues transaction
            end
        end
    end
    restore_answers() --- Guess: Restores saved answers
end