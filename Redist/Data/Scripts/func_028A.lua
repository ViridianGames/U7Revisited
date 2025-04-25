-- Function 028A: Manages directional display
function func_028A(itemref)
    -- Local variables (5 as per .localc)
    local local0, local1, local2, local3, local4

    if eventid() == 1 then
        local0 = callis_0018(-356)
        local1 = math.floor((local0[1] - 933) / 10)
        local2 = math.floor((local0[2] - 1134) / 10)
        if local1 < 0 then
            local3 = " " .. call_0932H(local1) .. " West"
        else
            local3 = " " .. call_0932H(local1) .. " East"
        end
        if local2 < 0 then
            local4 = " " .. call_0932H(local2) .. " North"
        else
            local4 = " " .. call_0932H(local2) .. " South"
        end
        if not callis_0062() then
            callis_0040(local4 .. local3, itemref)
        elseif call_0937H(-1) then
            callis_0040("@'Twill not function under a roof!@", -1)
        end
    end
end

-- Helper functions
function eventid()
    return 0 -- Placeholder
end