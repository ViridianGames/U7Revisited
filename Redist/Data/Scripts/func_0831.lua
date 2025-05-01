-- Function 0831: Ship preparation
function func_0831(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6

    local1 = get_item_position(eventid)
    local1 = table.insert(local1, _GetItemQuality(eventid))
    local1 = table.insert(local1, -359)
    local2 = check_position(0, 12, 150, local1)
    while local3 do
        local5 = local3
        if not call_0829H(local5) then
            add_dialogue(itemref, "@One of the gangplanks seems to be blocked. It must be lowered to sail.@")
            return
        end
        local3 = get_next_item() -- sloop
    end
    local6 = check_position(0, 18, 251, local1)
    call_0830H(1, local6)
    call_008AH(20, -356)
    call_0089H(26, -356)
    call_0058H(10, eventid)
end