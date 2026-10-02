--- Best guess: Manages ship gangplank interactions, checking sail state and obstructions, displaying appropriate messages.
function object_gangplank_0781(eventid, objectref)
    if eventid == 1 then
        if not get_item_flag(10, objectref) then
            utility_apply_value_action_alt_1023("@The sails must be furled before the planks can be lowered.@", objectref)
        elseif not utility_gangplank_0809(objectref) then
            utility_apply_value_action_alt_1023("@I think the gangplank is blocked.@", objectref)
        end
    end
    return
end