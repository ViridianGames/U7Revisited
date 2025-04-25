-- Checks if all party members are sitting.
function func_080D()
    local local0, local1, local2, local3, local4

    local0 = get_party_members()
    for local1 in ipairs(local0) do
        local2 = local1
        local3 = local2
        local4 = get_item_frame(local3)
        if local4 ~= 10 and local4 ~= 26 then
            return false
        end
    end
    return true
end