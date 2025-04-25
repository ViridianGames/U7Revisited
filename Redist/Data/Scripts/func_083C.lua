-- Finds nearby gold items for the triples game.
function func_083C(p0)
    local local1, local2, local3, local4, local5, local6

    local1 = {}
    local2 = external_0035H(0, 10, 644, p0[4]) -- Unmapped intrinsic
    for local3 in ipairs(local2) do
        local4 = local3
        local5 = local4
        local6 = get_item_data(local5)
        if local6[1] <= p0[1] and local6[1] >= p0[1] - 10 and local6[2] <= p0[2] and local6[2] >= p0[2] - 5 then
            local1 = array_append(local1, local5)
        end
    end
    return local1
end