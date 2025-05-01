-- Handles key usage on locked chests or doors, checking for matching quality.
function func_0281H(eventid, itemref)
    if eventid ~= 1 then
        return
    end
    local target = item_select_modal() -- TODO: Implement LuaItemSelectModal for callis 0033.
    set_stat(itemref, 27) -- Sets quality to 27.
    local item_type = get_item_type(target) -- TODO: Implement LuaGetItemType for callis 0011.
    local key_quality = get_item_quality(itemref) -- TODO: Implement LuaGetItemQuality for callis 0014.
    local target_quality = get_item_quality(target)
    local door_types = {376, 270, 432, 433} -- 0178H, 010EH, 01B0H, 01B1H.
    if (in_array(door_types, get_item_type(target[1]))) and key_quality == target_quality then
        call_script(0x0815, target) -- TODO: Map 0815H (unlock action).
    end
    if item_type == 522 and key_quality == target_quality then -- 020AH: Locked chest.
        bark(target, "Unlocked") -- TODO: Implement LuaItemSay for calli 0040.
        set_item_type(target, 800) -- 0320H: Unlocked chest.
        if target_quality == 253 then
            set_flag(0x003E, true)
        end
    elseif item_type == 800 and key_quality == target_quality then -- 0320H: Unlocked chest.
        local items = get_container_items(target, 641, key_quality, -359) -- TODO: Implement LuaGetContainerItems for callis 002A.
        local found = false
        local current = items
        while current do
            if current == target then
                found = true
                break
            end
            current = get_wearer(current) -- TODO: Implement LuaGetWearer for callis 006E.
        end
        if found then
            bark(356, "Key inside")
        else
            lock_item(target) -- TODO: Implement LuaLockItem for calli 0080.
            set_item_type(target, 522) -- 020AH: Locked chest.
            bark(target, "Locked")
        end
    end
end