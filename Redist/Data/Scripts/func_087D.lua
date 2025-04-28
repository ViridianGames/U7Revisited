require "U7LuaFuncs"
-- Adjusts the Avatar's frame based on gender and applies item effects.
function func_087D()
    local local0, local1, local2

    external_0089H(external_001BH(-356), 16) -- Unmapped intrinsic
    local0 = get_item_by_type(854) -- Unmapped intrinsic
    if not is_player_female() then -- Unmapped intrinsic
        if get_item_frame(external_001BH(-356)) < 16 then
            set_item_frame(local0, 18)
        else
            set_item_frame(local0, 19)
        end
    else
        if get_item_frame(external_001BH(-356)) < 16 then
            set_item_frame(local0, 20)
        else
            set_item_frame(local0, 21)
        end
    end
    local1 = get_item_data(external_001BH(-356))
    local2 = set_item_data(local1)
    return
end