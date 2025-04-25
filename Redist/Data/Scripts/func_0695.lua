-- Function 0695: Create and position items
function func_0695(eventid, itemref)
    local local0, local1, local2, local3, local4, local5

    local0 = check_condition(10, 740, call_001BH(-356))
    if local0 then
        local1 = _GetItemFrame(local0)
        local1 = local1 - 6
        local2 = call_0001H({8006, 2, 17447, 8014, 1, 17447, 8014, 1, 17447, 8014, 1, 17447, 8014, 1, 17447, 7758}, local0)
        local3 = call_0001H({8033, 2, 17447, 8039, 1, 7975, 2, 17497, 8036, 1, 17447, 8039, 1, 17447, 8037, 1, 17447, 8038, 1, 17447, 7780}, call_001BH(-356))
        local4 = call_0001H(1, {7750}, itemref)
        call_000FH(40)
    end
end