--- Best guess: Triggers an action for an item when event ID 1 is received, likely for a generic interactable object.
function func_031C(eventid, objectref)
    if eventid == 1 then
        unknown_0809H(objectref)
    end
    return
end