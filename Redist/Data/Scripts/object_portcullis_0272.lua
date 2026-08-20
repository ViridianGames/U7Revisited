--- Portcullis (shapes 271/272). Raised by password/guard scripts (utility_unknown_0820);
--- double-click alone should not open the gate.
function object_portcullis_0272(eventid, objectref)
    if eventid == 1 then
        bark(objectref, "@The portcullis is down.@")
    end
end

object_portcullis_0271 = object_portcullis_0272
