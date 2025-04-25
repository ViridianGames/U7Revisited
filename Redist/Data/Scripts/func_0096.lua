function func_0096H(eventid, itemref)
    if eventid == 1 then
        if U7GetItemShape(itemref, 10) == 0 then
            U7Say("The sails must be furled before the planks are raised.", 0)
            return
        end
        if not U7IsGangplankAccessible(itemref) then
            U7Say("I think the gangplank is blocked.", 0)
            return
        end
        if U7CheckCondition() then
            U7UseItem()
        end
    end
end