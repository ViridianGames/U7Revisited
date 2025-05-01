-- Function 03B0: Spitting action with dialogue
function func_03B0(eventid, itemref)
    -- Local variable (1 as per .localc)
    local local0

    if eventid ~= 1 then
        return
    end

    if _GetItemFrame(itemref) == 0 and call_0937H(-356) and not callis_0081() then
        bark(356, "@ptui!@")
        local0 = callis_0002({3, 24, 7768}, itemref)
    end

    return
end