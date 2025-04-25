-- Manages the Orb of the Moons, creating moongates for teleportation or displaying error messages.
function func_0311H(eventid, itemref)
    if eventid == 1 then
        if get_flag(0x0004) then
            say(0, {"It work before.", "How odd!"})
            return
        end
        if get_flag(0x0057) or not call_script(0x093E) then -- TODO: Map 093EH (possibly check condition).
            local target = item_select_modal() -- TODO: Implement LuaItemSelectModal for callis 0033.
            local pos = call_script(0x0822, target) -- TODO: Map 0822H (possibly get position).
            local dir = find_direction(-356, pos) -- TODO: Implement LuaFindDirection for callis 001A.
            local x, gate_type
            if dir == 0 or dir == 4 then
                x = 1
                gate_type = 779 -- 030BH
            else
                x = 2
                gate_type = 157 -- 009DH
            end
            pos[x] = pos[x] + 2
            if not check_horizontal_space(pos, gate_type, 0) then -- TODO: Implement LuaCheckHorizontalSpace for callis 0085.
                for i = 1, 3 do
                    pos[x] = pos[x] + 1
                    if check_horizontal_space(pos, gate_type, 0) then
                        break
                    end
                end
                set_environment(0) -- TODO: Implement LuaSetEnvironment for calli 006A.
                return
            end
            use_item()
            local moongate = find_object_by_type(gate_type) -- TODO: Implement LuaFindObjectByType for callis 0024.
            if moongate then
                use_item()
                update_container(pos)
                pos[x] = pos[x] - 2
                play_music(51, 0) -- TODO: Implement LuaPlayMusic for calli 002E.
                set_item_quality(moongate, 18)
                set_item_quality(moongate, dir)
                local arr = {-1, 7750, 0, 8014, 17419, -1, 5, 7947, -7, 5, 8006, 4, 8014, 17420, -1, 10, 8006, 4, 8016, 17419, 4, 7981, 3}
                execute_action(moongate, arr)
                local distance = 5 - get_distance(-356, moongate) -- TODO: Implement LuaGetDistance for callis 0019.
                local arr2 = {7769, 8496 + dir}
                if distance > 0 then
                    arr2 = {7769, dir, distance}
                end
                execute_action(-356, arr2)
                local avatar_pos = get_item_info(-356)
                local idx = x == 1 and 2 or 1
                if pos[x] < avatar_pos[x] then
                    x = idx
                else
                    x = idx
                    idx = x == 1 and 2 or 1
                end
                pos[x] = pos[x] + (pos[x] < avatar_pos[x] and 1 or -1)
                local result = move_to_position(785, moongate, 7, pos) -- TODO: Implement LuaMoveToPosition for callis 007D.
                if result then
                    set_item_state(moongate, 785, 8) -- TODO: Implement LuaSetItemState for calli 008B.
                    local owner = get_wearer(itemref) -- TODO: Implement LuaGetWearer for callis 006E.
                    local party = get_party_members() -- In U7LuaFuncs.cpp
                    for i = 1, #party do
                        if not owner or (owner == party[i] and is_party_member(owner)) then
                            break
                        end
                        owner = get_wearer(owner)
                    end
                    if not owner then
                        remove_item(itemref)
                        create_item(785, 1, 0, 0, false) -- TODO: Implement LuaCreateItem for callis 002C.
                    end
                else
                    call_script(0x0821, moongate) -- TODO: Map 0821H (possibly remove moongate).
                end
            end
        end
    elseif eventid == 8 then
        if not call_script(0x0826, itemref) then -- TODO: Map 0826H (possibly check state).
            call_script(0x0821, itemref)
            say(0, {"Let thyself enter.", "No, Avatar."})
        end
    elseif eventid == 7 then
        if not call_script(0x0826, itemref) then
            call_script(0x0821, itemref)
            call_script(0x0824, itemref) -- TODO: Map 0824H (possibly cleanup).
        end
    end
end