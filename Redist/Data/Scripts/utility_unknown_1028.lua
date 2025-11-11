--- Best guess: Similar to func_0903, with item-based "Oink" dialogue or action performance.
---@param npc_id integer The NPC ID to check and perform actions on
---@param message string|table The message or data to process (can be string or table)
function utility_unknown_1028(npc_id, message)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if not npc_id_in_party(npc_id) then --- Guess: Checks if NPC is in party
        if not check_object_flag(objectref, 25) then --- Guess: Checks item flag
            bark(objectref, "@Oink@") --- Guess: Item says dialogue
        else
            var_0002 = 0
            for _, var_0005 in ipairs({3, 4, 5, 0}) do
                perform_action(npc_id, var_0005, var_0002) --- Guess: Performs action
                var_0002 = var_0002 + 17
            end
        end
    end
end