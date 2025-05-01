-- Function 00FC: Display time on item (e.g., clock)
function func_00FC(eventid, itemref)
    -- Local variables (3 as per .localc)
    local local0, local1, local2

    -- Check if eventid == 1
    if eventid ~= 1 then
        return
    end

    -- Get hour and adjust for 12-hour format
    local0 = _GetTimeHour()
    if local0 > 12 then
        local0 = local0 - 12
    end
    if local0 == 0 then
        local0 = 12
    end

    -- Get minute and pad with leading zero if < 10
    local1 = _GetTimeMinute()
    if local1 < 10 then
        local1 = "0" .. local1
    end

    -- Format time string (e.g., "12:05")
    local2 = tostring(local0) .. ":" .. tostring(local1)

    -- Display time on item
    bark(itemref, local2)

    return
end