-- Resurrects an NPC and deducts gold.
function func_091F(p0, p1)
    local local2, local3

    local2 = external_0051H(p1) -- Unmapped intrinsic
    if local2 ~= 0 then
        add_dialogue("\"Breath doth return to the body. Thy comrade is alive!\"")
        local3 = add_item_to_container(-359, -359, -359, 644, p0) -- Unmapped intrinsic
    else
        add_dialogue("\"Alas, I cannot save thy friend. I will provide a proper burial. Thou must go on and continue with thine own life.\"")
    end
    return
end