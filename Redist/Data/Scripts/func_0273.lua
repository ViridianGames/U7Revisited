-- Manages lockpick usage on chests or doors, with chance of success or breaking.
function func_0273H(eventid, itemref)
    if eventid ~= 1 then
        return
    end
    local target = item_select_modal() -- TODO: Implement LuaItemSelectModal for callis 0033.
    set_stat(itemref, 27) -- Sets quality to 27.
    local item_type = get_item_type(target) -- TODO: Implement LuaGetItemType for callis 0011.
    local quality = get_item_quality(target) -- TODO: Implement LuaGetItemQuality for callis 0014.
    local dex = get_npc_property(-356, 1) -- TODO: Implement LuaGetNPCProperty for callis 0020.
    local success = random(1, 30) < dex
    if item_type == 522 then -- 020AH: Locked chest.
        if quality == 0 and success then
            set_item_type(target, 800) -- 0320H: Unlocked chest.
            bark(target, "Unlocked") -- TODO: Implement LuaItemSay for calli 0040.
            return
        end
        if quality == 255 and success then
            local keg = find_object_by_type(704) -- 02C0H: Powder keg.
            if keg then
                local pos = get_item_info(target)
                update_container(pos)
                use_item()
                explode(keg, keg, 704) -- TODO: Implement LuaExplode for callis 0054.
            end
            if success then
                set_item_type(target, 800)
                bark(target, "Unlocked")
            else
                bark(target, "Pick broke")
                call_script(0x0925, itemref) -- TODO: Map 0925H.
            end
        else
            bark(target, "Pick broke")
            call_script(0x0925, itemref)
        end
    end
    local door_types = {376, 270, 432, 433} -- 0178H, 010EH, 01B0H, 01B1H.
    for _, door_type in ipairs(door_types) do
        if item_type == door_type then
            if quality == 0 then
                local frame = call_script(0x081B, target) -- TODO: Map 081BH.
                if frame % 4 == 2 then
                    if success then
                        call_script(0x081C, target, 0) -- TODO: Map 081CH.
                        bark(target, "Unlocked")
                    else
                        bark(target, "Pick broke")
                        call_script(0x0925, itemref)
                    end
                end
            else
                add_dialogue(0, "Strange that did not work.")
            end
            return
        end
    end
    add_dialogue(0, "Try those on a locked chest or door.")
end