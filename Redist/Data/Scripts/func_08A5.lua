-- Function 08A5: Displays random poetic messages for a torch
function func_08A5()
    -- Local variables (4 as per .localc)
    local local0, local1, local2, local3

    local0 = callis_001B(-252)
    local1 = callis_001C(local0)
    local2 = ""
    local3 = callis_0010(4, 1)

    if local1 == 11 then
        if local3 == 1 then
            local2 = "To wonder about love."
        elseif local3 == 2 then
            local2 = "To have found it yet?"
        elseif local3 == 3 then
            local2 = "To have no torch."
        elseif local3 == 4 then
            local2 = "To be glad to help."
        end
        callis_0040(local2, local0)
    end

    return
end