-- Adjusts gangplank position based on type.
function func_082D(p0, p1, p2)
    if p0 == 781 then
        p1 = external_082BH(3, p1) -- Unmapped intrinsic
        p2 = external_082AH(3, p1, p2) -- Unmapped intrinsic
    elseif p0 == 150 then
        p2 = external_082AH(3, p1, p2) -- Unmapped intrinsic
    end
    return p2
end