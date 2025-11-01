--- Best guess: Indicates a locked chest, displaying a "Locked" message when interacted with, likely requiring a key or lockpick.
function object_chestlocked_0522(eventid, objectref)
    if eventid == 1 then
        bark(objectref, "Locked")
    end
    return
end