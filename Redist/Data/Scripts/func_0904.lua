--- Best guess: Similar to func_0903, with item-based "Oink" dialogue or action performance.
function func_0904(eventid, objectref, arg1, arg2)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if not npc_in_party(arg1) then --- Guess: Checks if NPC is in party
        if not check_object_flag(objectref, 25) then --- Guess: Checks item flag
            bark(objectref, "@Oink@") --- Guess: Item says dialogue
        else
            var_0002 = 0
            for _, var_0005 in ipairs({3, 4, 5, 0}) do
                perform_action(arg1, var_0005, var_0002) --- Guess: Performs action
                var_0002 = var_0002 + 17
            end
        end
    end
end