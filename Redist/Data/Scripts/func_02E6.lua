-- Function 02E6: NPC dialogue trigger
function func_02E6(eventid, itemref)
    if eventid ~= 1 then
        return
    end

    if _NPCInParty(-2) and call_0937H(-2) then
        bark(2, "@Gee, is that neat.@")
    end

    return
end