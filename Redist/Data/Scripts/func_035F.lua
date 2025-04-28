require "U7LuaFuncs"
-- Function 035F: Manages flour usage
function func_035F(itemref)
    -- Local variables (9 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8

    if eventid() == 1 then
        local0 = callis_0012(itemref)
        if local0 == 0 then
            local1 = callis_0033()
            local2 = callis_0018(local1)
            local3 = callis_0011(local1)
            local4 = -1
            if local3 == 1018 then
                local4 = local2[1] - callis_0010(3, 0)
                local5 = local2[2]
                local6 = local2[3] + 2
            elseif local3 == 1003 then
                local4 = local2[1]
                local5 = local2[2] - callis_0010(2, 0)
                local6 = local2[3] + 2
            end
            if local4 == -1 then
                call_08FFH("@Why not put the flour on the table first?@")
            else
                local7 = callis_0024(658)
                if not local7 then
                    callis_0089(18, local7)
                    callis_0013(local7, 0)
                    local8 = callis_0026({local4, local5, local6})
                end
            end
        elseif local0 == 8 or local0 == 9 then
            local1 = callis_0033()
            if callis_0011(local1) == 658 and callis_0012(local1) == 2 then
                callis_0013(local1, 1)
            end
            call_0933H(0, "@Hey! That really hurt!@", local1)
        elseif local0 == 13 or local0 == 14 then
            callis_0013(itemref, 0)
        end
    end
end

-- Helper functions
function eventid()
    return 0 -- Placeholder
end