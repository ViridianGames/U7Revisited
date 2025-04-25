-- Function 02EB: Soul cage for liche capture/release
function func_02EB(eventid, itemref)
    -- Local variables (4 as per .localc)
    local local0, local1, local2, local3

    if eventid ~= 1 then
        return
    end

    local0 = _GetItemFrame(itemref)
    local1 = _ItemSelectModal()
    if local0 == 0 then
        if _GetItemType(local1) == 519 then
            local2 = callis_000E(1, 1011, -141)
            if _GetItemFrame(local2) == 1 and callis_001C(-141) == 14 and _GetItemFrame(-141) == 13 then
                calli_005C(-141)
                local3 = callis_0025(itemref)
                if local3 then
                    local3 = callis_0026(callis_0018(-141))
                    calli_001D(15, -141)
                    set_flag(0x01AF, true)
                end
            end
        end
    elseif local0 == 1 then
        if _GetItemType(local1) == 748 then
            _SetItemFrame(0, itemref)
        end
    end

    return
end

-- Helper function
function set_flag(flag, value)
    -- Placeholder
end