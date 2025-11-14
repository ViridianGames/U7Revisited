--- Best guess: Manages a key, unlocking specific items (chests or doors) if quality matches, or relocking if already unlocked.
function object_doorkey_0641(eventid, objectref)
    local target_object, target_object_shape, this_object_quality, target_object_quality, var_0004, var_0005

    if eventid == 1 then
        target_object = object_select_modal()
        --coroutine.yield()
        --set_object_quality(objectref, 27)
        target_object_shape = get_object_shape(target_object)
        this_object_quality = get_object_quality(objectref)
        target_object_quality = get_object_quality(target_object)
        --  Lock/unlock doors
        if is_int_in_array(target_object_shape, {433, 432, 270, 376}) then
            if this_object_quality == target_object_quality then
                func_0815(target_object)
            end
        --  Locked chest
        elseif target_object_shape == 522 then
            if this_object_quality == target_object_quality then
                bark(target_object, "Unlocked")
                set_object_shape(target_object, 800)
                -- If the chest was Christopher's, set a plot flag
                if target_object_quality == 253 then
                    set_flag(62, true)
                end
            end
        -- Unlocked chest
        elseif target_object_shape == 800 then
            if this_object_quality == target_object_quality then
                var_0004 = get_container_objects(359, this_object_quality, 641, target_object)
                var_0005 = false
                while var_0004 and not var_0005 do
                    if var_0004 == target_object then
                        var_0005 = true
                    else
                        var_0004 = get_container(var_0004)
                    end
                end
                if var_0005 then
                    bark(356, "Key inside")
                else
                    close_gump(target_object)
                    set_object_shape(target_object, 522)
                    bark(target_object, "Locked")
                end
            end
        end
    end
end