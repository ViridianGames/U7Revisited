-- Handles potion or reagent usage, with dialogue and stat modifications.
function func_0154H(eventid, itemref)
    if eventid ~= 1 then
        return
    end
    call_script(0x08FA, itemref) -- TODO: Map 08FAH (possibly item check).
    local frame = get_item_frame(itemref) -- TODO: Implement LuaGetItemFrame for callis 0012.
    local obj = item_select_modal() -- TODO: Implement LuaItemSelectModal for callis 0033.
    local wearer = get_wearer(obj) -- TODO: Implement LuaGetWearer for callis 0031.
    set_stat(itemref, 90) -- Sets quality to 90.
    if wearer then
        set_stat(68, 1) -- Apply effect (calli 000F).
        if frame == 0 then
            set_item_quality(obj, 1) -- TODO: Implement LuaSetItemQuality for calli 0089.
        elseif frame == 1 then
            local effect = random(3, 12) -- Random effect value.
            call_script(0x092A, obj, effect) -- TODO: Map 092AH.
        elseif frame == 2 then
            set_item_quality(obj, 8)
            set_item_quality(obj, 7)
            set_item_quality(obj, 1)
            set_item_quality(obj, 2)
            set_item_quality(obj, 3)
        elseif frame == 3 then
            set_item_quality(obj, 8)
        elseif frame == 4 then
            set_item_quality(obj, 1)
            if get_item_quality(obj) == -150 then -- TODO: Implement LuaGetItemQuality for callis 003A.
                set_item_status(obj, 7) -- TODO: Implement LuaSetItemStatus for calli 001D.
            end
        elseif frame == 5 then
            set_item_quality(obj, 9)
        elseif frame == 6 then
            set_stat(100, 1) -- Apply effect (calli 0057).
        elseif frame == 7 then
            set_item_quality(obj, 0)
        elseif frame >= 8 then
            say(0, "What is this!") -- Dialogue for invalid frame.
            return
        end
    else
        local effect = random(1, 3)
        if effect == 1 then
            call_script(0x0909) -- TODO: Map 0909H.
            local gender = is_player_female() and "lady" or "lord"
            say(0, "Those are expensive, " .. gender .. "! Plese waste them not!") -- Concatenated dialogue.
        else
            call_script(0x08FD, 60) -- TODO: Map 08FDH.
        end
    end
    call_script(0x0925, itemref) -- TODO: Map 0925H.
end