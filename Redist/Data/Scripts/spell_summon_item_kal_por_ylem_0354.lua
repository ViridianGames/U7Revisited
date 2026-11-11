--- Mark (Kal Por Ylem). Fourth Circle. Usecode Func0662 / object#(0x662).
--- Only a virtue stone (shape 330) accepts the mark. The stone stores the
--- Avatar's current position. Each stone keeps its own place.

function spell_summon_item_kal_por_ylem_0354(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    local stone = click_on_item()
    if not stone or stone == 0 or get_object_shape(stone) ~= 330 then
        execute_usecode_array(objectref, {17514, 17520, 7781})
        return
    end

    bark(objectref, "@Kal Por Ylem@")
    -- Flag 0x39 (57): Codex attunement. Original Mark fails while it is set.
    if not check_spell_requirements(objectref) or get_flag(57) then
        execute_usecode_array(objectref, {17514, 17520, 7781})
        return
    end

    mark_virtue_stone(stone)
    -- Stored reversed: sfx 67, cast up, cast out, strike 2h.
    execute_usecode_array(objectref, {17514, 8048, 17519, 67, 17496})
    obj_sprite_effect(objectref, 13)
end
