require "U7LuaFuncs"
-- Cures poison from an NPC and deducts gold.
function func_091E(p0, p1)
    local local2, local3

    local2 = external_001BH(p1) -- Unmapped intrinsic
    if external_0088H(8, local2) then -- Unmapped intrinsic
        external_008AH(8, local2) -- Unmapped intrinsic
        local3 = add_item_to_container(-359, -359, -359, 644, p0) -- Unmapped intrinsic
        say("\"The wounds have been healed.\"")
    else
        say("\"That individual does not need curing!\"")
    end
    return
end