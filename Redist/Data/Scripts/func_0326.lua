-- Manages Trinsic guard’s dialogue, checking for the correct password to allow passage.
function func_0326H(eventid, itemref)
    if eventid == 0 then
        return
    end
    local state = check_item_state(itemref) -- TODO: Implement LuaCheckItemState for callis 001B.
    local state2 = check_item_state2(itemref) -- TODO: Implement LuaCheckItemState2 for callis 001C.
    switch_talk_to(259, 0)
    add_answer({"bye", "job", "name"})
    if not get_flag(0x003D) then
        add_answer("password")
    end
    add_dialogue(0, "You see a tough-looking guard who takes his job -very- seriously.")
    local answer = get_answer()
    while answer do
        if answer == "name" then
            add_dialogue(0, '"My name is not important."')
            remove_answer("name")
        elseif answer == "job" then
            add_dialogue(0, '"I keep villains and knaves out of Trinsic and keep a record of all who leave. Thou must have a password to leave."')
            add_answer("password")
        elseif answer == "password" then
            add_dialogue(0, '"What is the password?"')
            local options = {"Please", "Long live the king", "Uhh, I don't know"}
            if not get_flag(0x003D) then
                table.insert(options, "Blackbird")
            end
            local choice = call_script(0x090B, options) -- TODO: Map 090BH (possibly get_answer with options).
            if choice == "Blackbird" then
                local result = call_script(0x0834) -- TODO: Map 0834H (possibly check condition).
                if result then
                    add_dialogue(0, '"Very well, thou mayest pass."')
                    return
                end
            else
                add_dialogue(0, '"Thou dost not know the password. Sorry. The Mayor can give thee the proper password."')
                set_flag(0x0042, true)
            end
        elseif answer == "bye" then
            add_dialogue(0, '"Goodbye."')
            return
        end
        answer = get_answer()
    end
end