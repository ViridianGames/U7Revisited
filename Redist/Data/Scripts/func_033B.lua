require "U7LuaFuncs"
-- Function 033B: Manages bandage healing
function func_033B(itemref)
    -- Local variables (4 as per .localc)
    local local0, local1, local2, local3

    if eventid() == 1 then
        local0 = callis_0033()
        if callis_0031(local0) then
            local1 = callis_0020(0, local0)
            local2 = callis_0020(3, local0)
            if local2 == local1 then
                call_08FFH("@It does not appear as though a bandage is needed.@")
            elseif callis_003A(local0) == -356 then
                call_08FEH("@Much better.@")
            elseif call_0937H(local0) then
                local3 = callis_0010(3, 1)
                if local3 == 1 then
                    callis_0040("@Ah, much better!@", local0)
                elseif local3 == 2 then
                    callis_0040("@Thank thee!@", local0)
                elseif local3 == 3 then
                    callis_0040("@That looks better.@", local0)
                end
                local3 = callis_0010(4, 1)
                if local2 + local3 > local1 then
                    local3 = local1 - local2
                end
                callis_0021(3, local3, local0)
            end
            call_0925H(itemref)
        else
            call_08FEH("@Do not soil the bandages.@")
        end
    end
end

-- Helper functions
function eventid()
    return 0 -- Placeholder
end