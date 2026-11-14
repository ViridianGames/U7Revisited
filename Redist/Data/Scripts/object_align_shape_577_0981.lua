--- Best guess: Aligns an object (shape 577) with another's frame and position, possibly for a puzzle or placement mechanic.
function object_align_shape_577_0981(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003

    if eventid == 1 then
        var_0000 = object_select_modal()
        var_0001 = get_object_shape(var_0000)
        var_0002 = get_object_position(var_0000)
        local prism_frame = get_object_frame(objectref)
        local target_frame = var_0000 and get_object_frame(var_0000) or nil
        if var_0001 == 577 and target_frame == prism_frame then
            console_log(string.format(
                "Prism %s: pedestal %s frame %s accepted (prism frame %s).",
                tostring(objectref), tostring(var_0000), tostring(target_frame), tostring(prism_frame)))
            var_0003 = set_last_created(objectref)
            if var_0003 then
                aidx(var_0002, 3, aidx(var_0002, 3) + 2)
                var_0003 = update_last_created(var_0002)
                local placed = get_object_position(objectref)
                if placed then
                    console_log(string.format(
                        "Prism %s placed at x=%.1f height=%.1f z=%.1f (pedestal x=%.1f height=%.1f z=%.1f).",
                        tostring(objectref), placed[1], placed[2], placed[3],
                        var_0002[1], var_0002[2], var_0002[3]))
                else
                    console_log("Prism " .. tostring(objectref) .. " was accepted, but it has no position after placing.")
                end
            else
                console_log("Prism " .. tostring(objectref) .. ": pedestal matched, but set_last_created failed.")
            end
        else
            console_log(string.format(
                "Prism %s: target %s is shape %s frame %s, prism frame %s. Not a matching pedestal.",
                tostring(objectref), tostring(var_0000), tostring(var_0001),
                tostring(target_frame), tostring(prism_frame)))
            -- calli 006A, 1 (unmapped)
            flash_mouse(0)
        end
        -- call [0000] (082EH, unmapped)
        var_0003 = mech_black_gate_prisms_0814(objectref)
    end
    return
end