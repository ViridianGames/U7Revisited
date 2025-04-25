-- Evaluates triples game results, counting frames and checking for winning conditions.
function func_083B()
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11

    local0 = 0
    local1 = 0
    local2 = 0
    local3 = 1
    local4 = external_0030H(809) -- Unmapped intrinsic
    local3 = {}
    for local5 in ipairs(local4) do
        local6 = local5
        local7 = local6
        local8 = get_item_frame(local7)
        local9 = math.floor(local8 / 8) + 1
        local3 = array_append(local3, local9)
        if local9 == 1 then
            local0 = local0 + 1
        elseif local9 == 2 then
            local1 = local1 + 1
        elseif local9 == 3 then
            local2 = local2 + 1
        end
    end
    local10 = local3[1] + local3[2] + local3[3]
    if local0 == 3 or local1 == 3 or local2 == 3 then
        local11 = true
    else
        local11 = false
    end
    return {local11, local10}
end