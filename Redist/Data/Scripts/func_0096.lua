function func_0096H(eventid, itemref)
    if eventid == 1 then
        if get_object_shape(itemref, 10) == 0 then
            bark(0, "The sails must be furled before the planks are raised.")
            return
        end
        if not U7IsGangplankAccessible(itemref) then
            bark(0, "I think the gangplank is blocked.")
            return
        end
        if U7CheckCondition() then
            U7UseItem()
        end
    end
end