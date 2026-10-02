--- Best guess: Retrieves a value and applies an action to an item using that value, likely for item manipulation or quest progression.
---@param message string The message or text to process
function utility_apply_value_action_1022(message)
    local var_0001

    var_0001 = utility_random_npc_id_0901_0902_1024()
    npc_pig_oink_item_1028(var_0001, message)
end