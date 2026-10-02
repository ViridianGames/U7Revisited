--- Pool/Fountains (shape 893). Oracle: usecode.dc Func037D shape#(0x37D).
--- Quality selects the drink effect. Trinsic mayor's office:
---   north 998x2199 quality 4 → poison (flag 8)
---   south 998x2234 quality 3 → cure status (clears poison and related flags)
function object_pool_0893(eventid, objectref)
    if eventid == 2 then
        play_looping_sound_effect(objectref, 48)
        return
    end

    if eventid ~= 1 then
        return
    end

    local quality = get_object_quality(objectref)
    local target = object_select_modal()
    if not target or target == 0 then
        return
    end

    -- usecode: UI_play_sound_effect2(0x005A, item)
    play_sound_effect(90, objectref)

    local npc_number = get_npc_number(target)
    if npc_number < 0 or not npc_id_in_party(npc_number) then
        -- Engine-only guard (original usecode had none); avoid poisoning scenery.
        return
    end

    if quality == 1 then
        set_item_flag(target, 1)
    elseif quality == 2 then
        -- usecode: die_roll(1,10); heal/hurt by (13 - roll)
        local roll = die_roll(1, 10)
        utility_adjust_health_1066(13 - roll, target)
        bark(target, "@Ahh...@")
    elseif quality == 3 then
        -- Cure fountain / red potion clears
        clear_item_flag(target, 8) -- poison
        clear_item_flag(target, 7) -- paralysis
        clear_item_flag(target, 1)
        clear_item_flag(target, 2)
        clear_item_flag(target, 3)
        bark(target, "@Ahh...@")
    elseif quality == 4 then
        set_item_flag(target, 8) -- poison
        bark(target, "@Yuck!@")
    elseif quality == 5 then
        clear_item_flag(target, 1)
    elseif quality == 6 then
        set_item_flag(target, 9)
    elseif quality == 7 then
        cause_light(100)
    elseif quality == 8 then
        set_item_flag(target, 0) -- invisible
    end
end
