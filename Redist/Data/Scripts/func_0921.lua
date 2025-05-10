--- Best guess: Displays party member names for training selection, returning the selected NPC ID or 0 if "Nobody" is chosen.
function func_0921(eventid, objectref, arg1)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C

    start_conversation()
    add_dialogue("@One of you wishes to train?@")
    var_0001 = get_dialogue_choice() --- Guess: Gets dialogue choice
    if not var_0001 then
        add_dialogue("@Perhaps at a later time.@")
        var_000C = 0
    else
        add_dialogue("@Which of you wishes to train?@")
        var_0003 = get_party_members() --- Guess: Gets party members
        var_0004 = {}
        var_0005 = {}
        for _, var_0008 in ipairs({6, 7, 8, 3}) do
            if var_0008 ~= arg1 then
                table.insert(var_0004, get_player_name(var_0008)) --- Guess: Gets player name
                table.insert(var_0005, var_0008)
            end
        end
        var_0002 = var_0004
        var_0003 = var_0005
        var_0009 = var_0003
        var_000A = show_purchase_options(var_0002, "Nobody") --- Guess: Shows purchase options
        var_000B = var_000A == array_size(var_0002) + 1 and 0 or get_npc_id(var_0009[var_000A]) --- Guess: Gets NPC ID
        var_000C = var_000B
    end
    return var_000C
end