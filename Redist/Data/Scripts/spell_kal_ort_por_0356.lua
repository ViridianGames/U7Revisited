--- Recall (Kal Ort Por). Fourth Circle. Usecode Func0664 / object#(0x664).
--- Cast on a virtue stone (shape 330). The party teleports to the place
--- stored on that stone.

function spell_kal_ort_por_0356(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    local stone = click_on_item()
    bark(objectref, "@Kal Ort Por@")

    local shapeOk = stone and stone ~= 0 and get_object_shape(stone) == 330
    if not check_spell_requirements(objectref) or not shapeOk then
        execute_usecode_array(objectref, {17514, 17520, 7781})
        return
    end

    recall_virtue_stone(stone)
    -- Stored reversed: cast up, cast out, strike 2h.
    execute_usecode_array(objectref, {17514, 8048, 17519})
    obj_sprite_effect(objectref, 7)
end
