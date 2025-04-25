-- Function 02F8: Gem interaction with mirror-breaking
function func_02F8(eventid, itemref)
    -- Local variables (9 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8

    local0 = _GetItemFrame(itemref)
    if eventid == 1 then
        if local0 <= 11 then
            local1 = "@Those are beautiful. I am sure that they would fetch a high price at the jewelers in Britain.@"
            call_08FFH(local1)
        elseif local0 == 14 then
            if not call_08E7H() then
                local2 = {6, 1552, 2191}
                calli_004F(local2)
            else
                calli_006F(itemref)
                calli_000F(37)
            end
        elseif get_flag(0x032F) or not get_flag(0x0330) then
            calle_06F6H(itemref)
        elseif local0 == 13 then
            calle_06F6H(itemref)
        elseif local0 == 12 then
            if not callis_0072(12, 760, 1, -356) then
                call_08FFH("@I believe the gem must be held in the weapon hand to break the mirror.@")
            end
            calli_007E()
            local3 = callis_0001({760, 8021, 2, 7719}, itemref)
        end
    elseif eventid == 2 then
        local4 = _ItemSelectModal()
        local5 = _GetItemType(local4)
        local6 = _GetItemFrame(local4)
        if local5 == 848 and local6 == 3 then
            call_0828H(7, local4, 760, -2, {2, 0}, local4)
        end
    elseif eventid == 7 then
        local7 = call_092DH(itemref)
        local3 = callis_0001({37, 17496, 8039, 2, 17447, 8038, 2, 17447, 8037, 2, 8487, local7, 7769}, -356)
        local3 = callis_0001({9, 8006, 10, 7719}, itemref)
        local8 = _GetContainerItems(12, -359, 760, -356)
        local3 = callis_0001({848, 8021, 2, 7975, 13, 8006, 10, 7719}, local8)
        set_flag(0x0313, false)
        set_flag(0x0333, false)
    end

    return
end

-- Helper functions
function say(message)
    print(message)
end

function get_flag(flag)
    return false -- Placeholder
end

function set_flag(flag, value)
    -- Placeholder
end