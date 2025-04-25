-- Function 02DA: Child rescue and item transformation
function func_02DA(eventid, itemref)
    -- Local variables (3 as per .localc)
    local local0, local1, local2

    if eventid ~= 1 then
        return
    end

    if _GetItemFrame(itemref) == 2 then
        local0 = "@Praise All! The child is still alive. He must be returned to Lady Tory immediately!@"
        call_08FFH(local0)
    else
        local1 = _ItemSelectModal()
        local2 = _GetItemType(local1[1])
        if local2 == 987 then
            call_08FFH("@Pardon me my friend, dost thou not think that would be a little crowded?@")
        elseif local2 == 992 then
            _SetItemType(987, local1)
            call_0925H(itemref)
        else
            call_08FDH(60)
        end
    end

    return
end