--- Best guess: Triggers a creature’s pain sound (“Arghh”) when interacted with, likely for a hostile or injured NPC or monster.
function func_01BF(eventid, objectref)
    if eventid == 1 then
        bark(objectref, "Arghh")
    end
    return
end