--- Best guess: Manages the "Sanct Lor" spell, granting invisibility (ID 1645) to a selected target, with a fallback effect if the spell fails.
function func_066D(eventid, itemref)
    local var_0000, var_0001, var_0002

    if eventid == 1 then
        var_0000 = _ItemSelectModal()
        unknown_005CH(itemref)
        var_0001 = unknown_092DH(var_0000)
        bark(itemref, "@Sanct Lor@")
        if not unknown_0906H() then
            var_0002 = unknown_0001H(itemref, {17514, 17520, 8047, 67, 8536, var_0001, 7769})
            var_0002 = unknown_0002H(4, {1645, 17493, 7715}, var_0000)
        else
            var_0002 = unknown_0001H(itemref, {1542, 17493, 17514, 17520, 8559, var_0001, 7769})
        end
    elseif eventid == 2 then
        unknown_0089H(0, itemref)
    end
end