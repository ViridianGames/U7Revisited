--- Bucket (shape 810): ground pickup → green use cursor → use on well to fill.
--- Frame 0 = empty, frame 1 = water (models bucket_810x00 / x01).
--- Keeps extended use targets (troughs, NPCs, etc.) from the decompiled script.

local function bucket_fill_from_well(bucket, well)
    if not bucket or not well then
        return
    end
    local fr = get_object_frame(bucket) or 0
    if fr ~= 0 then
        item_say("@The bucket is full.@", get_npc_name(-356))
        return
    end

    -- Prefer associated pump/well piece (470) when targeting a 740 well surround.
    local target = well
    if get_object_shape(well) == 740 then
        local near = find_nearest(well, 470, 3)
        if near then
            target = near
        end
    end

    -- Walk next to the well, then run bucket event 9 (fill). Fun=810, usecode item=bucket.
    local ok = utility_position_0808(target, {-5, -5, -1, 1, -2, -1}, {-1, -1, 0, 1, -2, 1}, 0, 810, bucket, 9)
    if not ok then
        -- path_run rejected all stands — try fill if already adjacent.
        object_bucket_0810(9, bucket)
    end
end

local function bucket_use_on_target(bucket, target)
    if not target or target == 0 then
        return
    end
    local shape = get_object_shape(target)
    local fr = get_object_frame(bucket) or 0

    -- Wells
    if shape == 740 or shape == 470 then
        bucket_fill_from_well(bucket, target)
        return
    end

    -- Avatar drink
    if shape == 721 or shape == 989 then
        if fr == 0 then
            item_say("@The bucket is empty.@", get_npc_name(-356))
        else
            item_say("@Ahhh, how refreshing.@", get_npc_name(-356))
            set_object_frame(bucket, 0)
        end
        return
    end

    if fr == 0 then
        item_say("@The bucket is empty.@", get_npc_name(-356))
    else
        item_say("@Nothing happens.@", get_npc_name(-356))
    end
end

local function bucket_enter_use_mode(bucket)
    close_gumps()
    -- Green use cursor; resumes with selected object id (or 0 if cancelled).
    local target = object_select_modal()
    if target and target ~= 0 then
        bucket_use_on_target(bucket, target)
    end
end

function object_bucket_0810(eventid, objectref)
    if eventid == 1 then
        close_gumps()
        local container = get_container(objectref)
        if not container then
            -- On the ground: walk over, then event 3 (pick up + use mode).
            local dx = {-1, -1, -1, -1, 1, 1, 1, 0}
            local dy = {-1, 0, -1, 1, -1, 0, 1, 1}
            local ok = utility_position_0808(objectref, dx, dy, -3, 810, objectref, 3)
            if not ok then
                -- Already in range — pick up immediately.
                object_bucket_0810(3, objectref)
            end
        else
            -- Already carried (or in a party container): go straight to use targeting.
            bucket_enter_use_mode(objectref)
        end

    elseif eventid == 3 then
        -- Arrived at ground bucket (or immediate pickup): take into backpack, then use.
        local ok = move_object_to_container(objectref, -356)
        if not ok then
            -- Fallback: try Avatar NPC body if no backpack.
            ok = move_object_to_container(objectref, 0)
        end
        if ok then
            bucket_enter_use_mode(objectref)
        else
            bark(get_npc_name(-356), "@I cannot carry that.@")
        end

    elseif eventid == 2 then
        -- Legacy path: usecode_array re-enters event 2 with click_on_item.
        local fr = get_object_frame(objectref) or 0
        local target = click_on_item()
        if target and target ~= 0 then
            bucket_use_on_target(objectref, target)
        end

    elseif eventid == 9 then
        -- Fill at well: animate well frames if possible, set bucket to water (frame 1).
        local av = get_npc_name(-356)
        local well = find_nearest(av, 740, 10) or find_nearest(av, 470, 10)
        if well then
            local wfr = get_object_frame(well) or 0
            -- Advance a few frames for a simple pump/well animation.
            for i = 0, 3 do
                set_object_frame(well, (wfr + i) % 12)
            end
            set_object_frame(well, wfr) -- restore base if animated strip wraps oddly
            -- Prefer leaving well on a "used" neighboring frame when available.
            if wfr <= 11 then
                set_object_frame(well, math.min(wfr + 1, 11))
            end
        end
        set_object_frame(objectref, 1)
        play_sound_effect(46)
        item_say("@You fill the bucket.@", get_npc_name(-356))

    elseif eventid == 4 or eventid == 10 then
        -- Keep residual usecode-array side paths as no-ops rather than crashing.
        return
    end
end
