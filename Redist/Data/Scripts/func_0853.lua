--- Best guess: Handles a shop transaction for eclectic items, with quantity prompts for bulk items like oil flasks.
function func_0853()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C

    start_conversation()
    save_answers() --- Guess: Saves current answers
    var_0000 = true
    var_0001 = {"horn polish", "nail file", "wing scratcher", "jug", "jar", "bucket", "powder keg", "shovel", "bag", "oil flasks", "torch", "nothing"}
    var_0002 = {937, 937, 937, 6, 681, 810, 704, 625, 802, 782, 595, 0}
    var_0003 = {2, 5, 5, 2, 3, 3, 35, 14, 6, 72, 4, 0}
    var_0004 = {"", "a ", "a ", "a ", "a ", "a ", "a ", "a ", "a ", "a ", "a ", ""}
    var_0005 = 1
    var_0006 = {" per application", "", "", "", "", "", "", "", "", " per dozen", "", ""}
    var_0007 = {-359, -359, -359, -359, -359, -359, -359, -359, -359, -359, -359, 0}
    var_0008 = {1, 1, 1, 1, 1, 1, 1, 1, 1, 12, 1, 0}
    add_dialogue("@\"To make what purchase?\"@")
    while var_0000 do
        var_0009 = select_item(var_0001) --- Guess: Selects item
        if var_0009 == 1 then
            add_dialogue("@\"To be acceptable.\"@")
            var_0000 = false
        else
            var_000A = format_price_with_unit(var_0006[var_0009], var_0003[var_0009], var_0005, var_0001[var_0009], var_0004[var_0009]) --- Guess: Formats price with unit
            var_000B = 0
            add_dialogue("@\"" .. var_000A .. ". To be an acceptable price?\"@")
            var_000C = get_dialogue_choice() --- Guess: Gets player choice
            if var_000C then
                if var_0002[var_0009] == 595 or var_0002[var_0009] == 782 then
                    add_dialogue(var_0002[var_0009] == 782 and "@\"To want how many sets of twelve?\"@" or "@\"To want how many?\"@")
                    var_000B = process_purchase(false, 1, 20, var_0003[var_0009], var_0008[var_0009], var_0007[var_0009], var_0002[var_0009]) --- Guess: Processes bulk purchase
                else
                    var_000B = process_purchase(false, 1, 0, var_0003[var_0009], var_0008[var_0009], var_0007[var_0009], var_0002[var_0009]) --- Guess: Processes single purchase
                end
                if var_000B == 1 then
                    add_dialogue("@\"To accept!\"@")
                elseif var_000B == 2 then
                    add_dialogue("@\"To be unable to travel with that much weight!\"@")
                elseif var_000B == 3 then
                    add_dialogue("@\"To have not the money for that!\"@")
                end
                add_dialogue("@\"To make another purchase?\"@")
                var_0000 = get_dialogue_choice() --- Guess: Continues transaction
            end
        end
    end
    restore_answers() --- Guess: Restores saved answers
end