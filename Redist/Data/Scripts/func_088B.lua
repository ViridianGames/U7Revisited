require "U7LuaFuncs"
-- Teleports party members to a specific location and updates flags.
function func_088B()
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9

    local0 = external_0035H(0, 10, 748, -356) -- Unmapped intrinsic
    local1 = 15
    local2 = -3
    local3 = -3
    external_0059H(local1) -- Unmapped intrinsic
    local4 = get_item_data(local0)
    create_object(-1, local4[2] + local3, local4[1] + local2, 0, 0, 0, 1) -- Unmapped intrinsic
    local5 = external_0002H(local0, {7750, 0}, local1) -- Unmapped intrinsic
    external_001FH(-147) -- Unmapped intrinsic
    external_001DH(-147, 15) -- Unmapped intrinsic
    local6 = {-145, -146, -140, -144, -142, -143, -147}
    for local7, local8 in ipairs(local6) do
        local9 = local8
        external_003FH(local9) -- Unmapped intrinsic
    end
    set_flag(419, true)
    abort()
    return
end