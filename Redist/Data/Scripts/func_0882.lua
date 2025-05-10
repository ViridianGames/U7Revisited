--- Best guess: Manages ferry interactions, checking barge and ferryman, initiating sitting actions.
function func_0882(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    if get_object_owner(objectref) then --- Guess: Gets item owner
        var_0001 = set_npc_location(16, 10, 961, objectref) --- Guess: Sets NPC location
        if var_0001 then
            if is_sitting(objectref) and get_object_owner(356) then --- Guess: Checks sitting status
                calle_061CH(var_0001) --- External call to unknown function
            else
                var_0002 = sit_down(objectref) --- Guess: Initiates sitting
                set_quest_flag(10, 356, true) --- Guess: Sets quest flag
                var_0003 = set_npc_location(0, 25, 155, 356) --- Guess: Sets NPC location
                if not var_0003 then
                    set_object_flag(20, var_0003, true) --- Guess: Sets item flag
                end
            end
        end
    end
end