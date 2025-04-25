-- Manages a cannon interaction, playing music and triggering effects if conditions are met.
function func_0378H(eventid, itemref)
    if eventid == 1 then
        if get_item_frame(itemref) == 1 then
            play_music(48, 0)
            local items = find_items(itemref, 888, 125, 0) -- TODO: Implement LuaFindItems for callis 0035.
            local objects = call_script(0x093C, itemref) -- TODO: Map 093CH (possibly get objects).
            if #objects == 1 then
                local cannon_pos = get_item_info(itemref)
                local object_pos = get_item_info(objects[1])
                local aligned = cannon_pos[1] < object_pos[1]
                local flag_check = get_flag(0x0197)
                if aligned == flag_check then
                    local target = find_items(-356, 155, 100, 0)
                    if target then
                        apply_effect(target, 0) -- TODO: Implement LuaApplyEffect for calli 0092.
                        call_script(0x061C, get_item_state(target)) -- TODO: Map 061CH (possibly trigger effect).
                    end
                end
            end
        else
            play_music(24, 0)
        end
    end
end