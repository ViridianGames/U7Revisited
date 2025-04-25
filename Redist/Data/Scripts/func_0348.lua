-- Manages flying carpet usage, allowing takeoff or landing with safety checks.
function func_0348H(eventid, itemref)
    local state = get_item_state(itemref) -- TODO: Implement LuaGetItemState for callis 0058.
    if eventid == 1 and state ~= 0 then
        if not get_item_shape(itemref, 10) then
            if call_script(0x080D) then -- TODO: Map 080DH (possibly check sitting).
                call_script(0x0812, state) -- TODO: Map 0812H (possibly toggle state).
            else
                if not call_script(0x08B3, itemref) then -- TODO: Map 08B3H (possibly sit down).
                    use_item() -- TODO: Implement LuaUseItem for calli 007E.
                end
            end
        elseif get_item_shape(itemref, 21) then
            set_item_quality(itemref, 10)
            set_item_quality(itemref, 26)
            local arr = {7736, 17441, 17419, -2, 10}
            execute_action(state, arr) -- TODO: Implement LuaExecuteAction for callis 0001.
            play_music(255, 0)
        else
            say(0, "I do not believe that we can land here safely.")
        end
    end
end