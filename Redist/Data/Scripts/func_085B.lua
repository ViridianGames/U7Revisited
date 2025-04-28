require "U7LuaFuncs"
-- Displays random NPC dialogue for NPC -244.
function func_085B()
    local local0, local1, local2, local3

    local0 = external_001BH(-244) -- Unmapped intrinsic
    local1 = external_001CH(local0) -- Unmapped intrinsic
    local2 = ""
    local3 = get_random(1, 4)
    if local1 == 11 then
        if local3 == 1 then
            local2 = "@We'll never find it!@"
        elseif local3 == 2 then
            local2 = "@Love. Hah!@"
        elseif local3 == 3 then
            local2 = "@I thought thou had it!@"
        elseif local3 == 4 then
            local2 = "@Why me?@"
        end
    end
    item_say(local2, local0)
    return
end