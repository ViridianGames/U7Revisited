--- Best guess: Manages the "Sanct Lor" spell, granting invisibility (ID 1645) to a selected target, with a fallback effect if the spell fails.
function func_066D(eventid, objectref)
    local var_0000, var_0001, var_0002

    if eventid == 1 then
        var_0000 = object_select_modal()
        unknown_005CH(objectref)
        var_0001 = unknown_092DH(var_0000)
        bark(objectref, "@Sanct Lor@")
        if not unknown_0906H() then
            var_0002 = unknown_0001H(objectref, {17514, 17520, 8047, 67, 8536, var_0001, 7769})
            var_0002 = unknown_0002H(4, {1645, 17493, 7715}, var_0000)
        else
            var_0002 = unknown_0001H(objectref, {1542, 17493, 17514, 17520, 8559, var_0001, 7769})
        end
    elseif eventid == 2 then
        unknown_0089H(0, objectref)
    end
end