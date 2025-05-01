-- Applies healing to an NPC and deducts gold.
function func_091D(p0, p1)
    local local2, local3, local4, local5, local6

    local2 = external_0910H(0, p1) -- Unmapped intrinsic
    local3 = external_0910H(3, p1) -- Unmapped intrinsic
    local4 = get_player_name(p1) -- Unmapped intrinsic
    if local2 > local3 then
        local5 = local2 - local3
        external_0912H(3, p1, local5) -- Unmapped intrinsic
        local6 = add_item_to_container(-359, -359, -359, 644, p0) -- Unmapped intrinsic
        add_dialogue("\"The wounds have been healed.\"")
    elseif p1 == -356 then
        add_dialogue("\"Thou seemest quite healthy!\"")
    else
        add_dialogue("\"" .. local4 .. " is already healthy!\"")
    end
    return
end