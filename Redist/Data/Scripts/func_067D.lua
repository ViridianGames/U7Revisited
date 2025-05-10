--- Best guess: Manages the "Vas An Xen Ex" spell, freeing a creature or entity (ID 1661) within a radius, with random placement and a fallback effect if the spell fails.
function func_067D(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008

    if eventid ~= 1 then
        if eventid == 2 then
            var_0007 = unknown_003AH(objectref)
            if table.contains({-356, -218, -217}, var_0007) then
                var_0008 = unknown_003CH(-356)
                if var_0008 then
                    unknown_0089H(2, objectref)
                else
                    unknown_008AH(2, objectref)
                end
            end
        end
        return
    end

    unknown_005CH(objectref)
    bark(objectref, "@Vas An Xen Ex@")
    if not unknown_0906H() then
        var_0000 = unknown_0001H(objectref, {1661, 17493, 17514, 17519, 17520, 8047, 65, 7768})
        var_0001 = unknown_0018H(objectref)
        unknown_0053H(-1, 0, 0, 0, var_0001[2] - 2, var_0001[1] - 2, 7)
        var_0002 = 25
        var_0003 = unknown_0934H(var_0002)
        for var_0004 in ipairs(var_0003) do
            var_0006 = unknown_0019H(var_0006, objectref)
            var_0002 = var_0006 // 4 + 4
            if random2(3, 1) ~= 1 then
                var_0000 = unknown_0002H(var_0002, 1661, {17493, 7715}, var_0006)
            end
        end
    else
        var_0000 = unknown_0001H(objectref, {1542, 17493, 17514, 17519, 17520, 7791})
    end
end