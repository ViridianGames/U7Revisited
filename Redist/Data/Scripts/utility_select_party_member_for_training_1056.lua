--- Best guess: Prompts the player to select a party member for training and returns their ID.
---@return integer party_member_id The ID of the selected party member, or 0 if none selected
function utility_select_party_member_for_training_1056()
    debug_print("utility_select_party_member_for_training_1056()")
    local var_0000
    var_0000 = select_party_member_by_name("\"Which of you wishes to train?\"")
    debug_print("Party member selected" .. var_0000)
    return var_0000
end