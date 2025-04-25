-- Function 06C7: Applies NPC effects for Minoc
function func_06C7(eventid, itemref)
    -- Local variables (4 as per .localc)
    local local0, local1, local2, local3

    if eventid ~= 3 then
        return
    end

    local0 = {-90, -82, -81, -91, -93}
    for _, local3 in ipairs(local0) do
        call_093FH(11, local3)
    end

    return
end