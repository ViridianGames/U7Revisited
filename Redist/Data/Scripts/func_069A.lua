require "U7LuaFuncs"
-- Triggers a sequence of effects, creating objects and applying combat-related mechanics.
function func_069A(eventid, itemref)
    local local0, local1, local2, local3, local4

    external_087DH(itemref, 15) -- Unmapped intrinsic
    local0 = get_item_data(itemref)
    create_object(-1, 0, 0, 0, local0[2] - 2, local0[1] - 2, 13) -- Unmapped intrinsic
    local1 = get_item_data(external_001BH(-356)) -- Unmapped intrinsic
    create_object(-1, 0, 0, 0, local1[2] - 2, local1[1] - 2, 7) -- Unmapped intrinsic
    apply_effect(68) -- Unmapped intrinsic
    local2 = external_092DH(itemref) -- Unmapped intrinsic
    local3 = (local2 + 4) % 8
    local4 = add_item(itemref, {1691, 8021, 4, 17447, 8047, 1, 17447, 8048, 1, 17447, 8033, 1, 17447, 8044, 3, 17447, 8045, 1, 17447, 8044, 1, 8487, local3, 7769})
    return
end