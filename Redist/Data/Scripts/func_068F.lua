-- Applies a flag-based effect to an item based on flags 814 or 813.
function func_068F(eventid, itemref)
    local local0, local1

    if not get_flag(814) then
        local0 = 15
    elseif not get_flag(813) then
        local0 = 14
    else
        local0 = 13
    end
    local1 = add_item(itemref, {local0, 7750})
    return
end