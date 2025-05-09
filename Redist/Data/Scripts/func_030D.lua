--- Best guess: Manages ship gangplank interactions, checking sail state and obstructions, displaying appropriate messages.
function func_030D(eventid, itemref)
    if eventid == 1 then
        if not unknown_0088H(10, itemref) then
            unknown_08FFH("@The sails must be furled before the planks can be lowered.@", itemref)
        elseif not unknown_0829H(itemref) then
            unknown_08FFH("@I think the gangplank is blocked.@", itemref)
        end
    end
    return
end