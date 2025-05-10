--- Best guess: Manages NPC shape transformations during an earthquake event, cycling through predefined shapes based on random selection.
function func_08DD()
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_0010

    unknown_005CH(objectref)
    var_0000 = unknown_0035H(8, 40, 359, objectref)
    var_0001 = 6
    if not unknown_0088H(10, 356) then
        for _, var_0004 in ipairs(var_0000) do
            var_0005 = 0
            var_0006 = {""}
            if var_0005 < var_0001 then
                var_0007 = unknown_0010H(8, 0)
                if var_0007 == 0 then
                    var_0008 = {17505, 17516, 7789}
                    var_0006 = {var_0008, var_0006}
                elseif var_0007 == 1 then
                    var_0008 = {17505, 17505, 7789}
                    var_0006 = {var_0008, var_0006}
                elseif var_0007 == 2 then
                    var_0008 = {17505, 17518, 7788}
                    var_0006 = {var_0008, var_0006}
                elseif var_0007 == 3 then
                    var_0008 = {17505, 17505, 7777}
                    var_0006 = {var_0008, var_0006}
                elseif var_0007 == 4 then
                    var_0008 = {17505, 17508, 7789}
                    var_0006 = {var_0008, var_0006}
                elseif var_0007 == 5 then
                    var_0008 = {17505, 17517, 7780}
                    var_0006 = {var_0008, var_0006}
                elseif var_0007 == 6 then
                    var_0009 = 7984 + unknown_0010H(3, 0) * 2
                    var_0008 = {17505, 8556, var_0009, 7769}
                    var_0006 = {var_0008, var_0006}
                elseif var_0007 == 7 then
                    var_0009 = 7984 + unknown_0010H(3, 0) * 2
                    var_0008 = {17505, 8557, var_0009, 7769}
                    var_0006 = {var_0008, var_0006}
                elseif var_0007 == 8 then
                    var_0009 = 7984 + unknown_0010H(3, 0) * 2
                    var_0008 = {17505, 8548, var_0009, 7769}
                    var_0006 = {var_0008, var_0006}
                end
                var_0005 = var_0005 + 1
            end
            unknown_005CH(var_0004)
            var_0010 = unknown_0001H(var_0006, var_0004)
        end
    end
    unknown_0059H(var_0001 * 3)
    return
end