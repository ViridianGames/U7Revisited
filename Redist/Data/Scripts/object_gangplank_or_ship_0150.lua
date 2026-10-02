function object_gangplank_or_ship_0150(eventid, objectref)
    if eventid == 1 then
        if not get_item_flag(10, objectref) then
            utility_apply_value_action_alt_1023("@The sails must be furled before the planks are raised.@")
        elseif not utility_gangplank_0809(objectref) then
            utility_apply_value_action_alt_1023("@I think the gangplank is blocked.@")
        elseif not in_gump_mode() then
            close_gumps()
        end
    end
end