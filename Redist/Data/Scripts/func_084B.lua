-- Prompts for a gold amount and adds it to the inventory.
function func_084B(p0)
    local local1, local2

    local1 = ask_number(p0 / 2, 1, p0, 0) -- Unmapped intrinsic
    if local1 >= 50 and local1 >= p0 / 2 then
        local2 = add_item_to_container(-359, -359, -359, 644, local1) -- Unmapped intrinsic
        return true
    end
    return false
end