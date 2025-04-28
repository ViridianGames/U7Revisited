require "U7LuaFuncs"
-- Simulates fishing with a pole, with random outcomes for catching fish or losing bait.
function func_0296H(eventid, itemref)
    if eventid == 1 or eventid == 4 then
        use_item() -- TODO: Implement LuaUseItem for calli 007E.
        local target = item_select_modal() -- TODO: Implement LuaItemSelectModal for callis 0033.
        local arr = {7783, 17505}
        execute_action(-356, arr) -- TODO: Implement LuaExecuteAction for callis 0001.
        if not check_environment(target, {2, 3, 4}) then -- TODO: Implement LuaCheckEnvironment for callis 0090.
            set_environment(0) -- TODO: Implement LuaSetEnvironment for calli 006A.
            return
        end
        local pos = get_item_info(-356) -- TODO: Implement LuaGetItemInfo for callis 0018.
        pos[1] = pos[1] + 1
        local fish = find_items(-356, 509, 15, 0) -- TODO: Implement LuaFindItems for callis 0035.
        local attempts = 0
        while fish do
            attempts = attempts + 1
            fish = next(fish) -- Simulate sloop iteration.
        end
        local caught = attempts > 0 and random(1, 10) <= attempts
        if caught then
            local food = find_object_by_type(377) -- 0179H: Fish.
            if food then
                set_item_frame(food, 12)
                set_item_quality(food, 11)
                update_container(pos) -- TODO: Implement LuaUpdateContainer for callis 0026.
                local outcome = random(1, 3)
                if outcome == 1 then
                    say(0, "Indded, a whopper!")
                    if is_party_member(-2) then -- Shamino.
                        call_script(0x0933, -2, "I have seen bigger.", 16) -- TODO: Map 0933H (delayed say).
                    end
                elseif outcome == 2 then
                    say(0, "What a meal!")
                elseif outcome == 3 then
                    say(0, {"That fish does not", "look right."})
                end
            end
        else
            local outcome = random(1, 4)
            if outcome == 1 then
                call_script(0x0933, -356, "Not even a bite!", 0)
            elseif outcome == 2 then
                call_script(0x0933, -356, "It got away!", 0)
                if is_party_member(-1) then -- Generic NPC.
                    call_script(0x0933, -1, "It was the Big One!", 16)
                end
            elseif outcome == 3 then
                call_script(0x0933, -356, "I've lost my bait.", 0)
            elseif outcome == 4 then
                call_script(0x0933, -356, "I felt a nibble.", 0)
            end
        end
    end
end