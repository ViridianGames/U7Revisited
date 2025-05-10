--- Best guess: Triggers an external function (ID 1782) or updates an object (shape 990) with a state change, possibly for a puzzle or mechanism.
function func_02C3(eventid, objectref)
    local var_0000

    if eventid == 1 then
        -- calle 06F6H, 1782 (unmapped)
        unknown_06F6H(objectref)
    elseif eventid == 2 then
        if get_object_shape(objectref) == 990 then
            -- calli 008C, 3 (unmapped)
            unknown_008CH(0, 1, 12)
            var_0000 = unknown_0001H({990, 8021, 3, 7719}, objectref)
        end
    end
    return
end