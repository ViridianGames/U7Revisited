require "U7LuaFuncs"
-- Function 01A2: Giant bones item creation based on time
function func_01A2(eventid, itemref)
    -- Local variables (5 as per .localc)
    local local0, local1, local2, local3, local4

    -- Check if eventid == 1
    if eventid ~= 1 then
        return
    end

    -- Check if item quality matches current hour
    local0 = _GetItemQuality(itemref)
    if local0 == _GetTimeHour() then
        return
    end

    -- Check item property (581)
    local1 = callis_0035(0, 5, 581, itemref)
    if not local1 then
        return
    end

    -- Create item (581, possibly ammo)
    local2 = callis_0024(581)
    if not local2 then
        return
    end

    -- Set item attributes
    calli_0089(18, local2)
    calli_0089(11, local2)

    -- Randomize value (1 to 100) and apply
    local3 = callis_0017(_Random2(1, 100), local2)

    -- Get bones' position
    local4 = callis_0018(itemref)

    -- Adjust position (x + 1)
    local4[1] = local4[1] + 1

    -- Note: Original has 'db 46' here, possibly a debug artifact, ignored

    -- Update position
    local3 = callis_0026(local4)

    if not local3 then
        -- Update item with current hour
        local3 = callis_0015(_GetTimeHour(), itemref)
    end

    return
end