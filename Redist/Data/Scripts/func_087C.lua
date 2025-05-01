-- Handles an Emp's request for honey, with dialogue and flag updates.
function func_087C()
    local local0, local1

    switch_talk_to(283, 0)
    if not get_flag(340) then
        add_dialogue("The ape-like creature slowly and cautiously walks up to you. He, or she, sniffs for a moment, and then points to the honey you are carrying.")
    end
    add_answer({"Go away!", "Want honey?"}) -- Unmapped intrinsic
    if compare_answer("Want honey?") then
        add_dialogue("\"Honey will be given by you to me?\"")
        local0 = external_090AH() -- Unmapped intrinsic
        if not local0 then
            local1 = add_item_to_container(-359, -359, -359, 772, 1) -- Unmapped intrinsic
            add_dialogue("\"You are thanked.\"")
            if not get_flag(340) then
                external_0911H(10) -- Unmapped intrinsic
                set_flag(340, true)
            end
        else
            if not get_flag(340) then
                add_dialogue("The Emp appears very disappointed.\"")
            else
                add_dialogue("\"`Goodbye' is said to you.\"*")
                abort()
            end
        end
    elseif compare_answer("Go away!") then
        add_dialogue("It does.*")
        abort()
    end
    remove_answer({"Go away!", "Want honey?"}) -- Unmapped intrinsic
    return
end