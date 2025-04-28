require "U7LuaFuncs"
-- Function 0817: Update door flags and items
function func_0817(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6

    set_flag(740, local0[1])
    set_flag(741, local0[2])
    set_flag(742, local0[3])
    local1 = check_position(0, 15, 949, -356)
    if not get_flag(740) then
        local2 = 230
    elseif not get_flag(741) then
        local2 = 220
    elseif not get_flag(742) then
        local2 = 210
    end
    while local3 do
        local5 = local3
        if _GetItemQuality(local5) == local2 then
            local6 = call_0001H({0, 17478, 7969, 16, 17496, 17443, 7937, 1, 7750}, local5)
        end
        local3 = get_next_item() -- sloop
    end
end