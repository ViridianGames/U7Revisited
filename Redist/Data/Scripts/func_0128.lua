function func_0128H(eventid, itemref)
    if eventid == 5 or eventid == 6 then
        local wearer = U7GetWearer(itemref)
        while wearer ~= nil and wearer ~= 0 and not U7IsWearerValid(wearer) do
            wearer = U7GetWearer(wearer)
        end
        if wearer == 0 then
            U7ApplyInvisibility(0)
        end
        if eventid == 5 then
            U7SetItemQuality(wearer, 0)
        elseif eventid == 6 then
            U7RemoveItemQuality(wearer, 0)
        end
    end
end