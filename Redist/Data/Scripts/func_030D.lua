--- Best guess: Manages ship gangplank interactions, checking sail state and obstructions, displaying appropriate messages.
function func_030D(eventid, objectref)
    if eventid == 1 then
        if not unknown_0088H(10, objectref) then
            unknown_08FFH("@The sails must be furled before the planks can be lowered.@", objectref)
        elseif not unknown_0829H(objectref) then
            unknown_08FFH("@I think the gangplank is blocked.@", objectref)
        end
    end
    return
end