--- Best guess: Handles a resurrection mechanic, restoring party members or NPCs, playing music, and managing item states (e.g., containers, frames) with complex array-based animations and NPC property updates.
function utility_music_0270(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007, var_0008, var_0009, var_000A, var_000B, var_000C, var_000D, var_000E, var_000F, var_0010, var_0011, var_0012, var_0013, var_0014, var_0015, var_0016, var_0017, var_0018, var_0019, var_001A, var_001B, var_001C, var_001D, var_001E

    if eventid == 4 then
        fade_palette(0, 1, 12)
        play_music(0, 255)
        play_music(0, 17)
        -- TODO UNKNOWN()
        var_0000 = get_dead_party(objectref)
        for var_0003 in ipairs(var_0000) do
            var_0004 = resurrect(var_0003)
        end
        var_0004 = delayed_execute_usecode_array(5, {1550, 17493, 7715}, objectref)
    end

    if eventid ~= 2 then
        restart_game()
        return
    end

    var_0005 = get_object_shape(objectref)
    var_0006 = get_object_position(objectref)
    set_flag(57, false)
    if get_flag(87) then
        set_flag(58, utility_unknown_1017(get_object_position(-356), {[0]=1791, [1595]=899, [753]=-356}))
        if not get_flag(58) then
            var_0007 = find_nearby(4, 90, 359, -356)
            var_0007 = utility_unknown_1084(get_npc_name(-356), var_0007)
            for var_000A in ipairs(var_0007) do
                if get_schedule_type(var_000A) == 0 then
                    var_000B = get_alignment(var_000A)
                    if var_000B == 0 or var_000B == 1 then
                        set_schedule_type(12, var_000A)
                    elseif var_000B == 3 or var_000B == 2 then
                        var_000C = get_container_objects(359, 359, 359, var_000A)
                        for var_000F in ipairs(var_000C) do
                            remove_item(var_000F)
                        end
                        remove_npc(var_000A)
                    end
                end
            end
        else
            var_0010 = {1733, 836}
            get_object_frame(-356, 13)
            set_item_flag(-356, 1)
            var_0011 = {[2]=-1, [2]=1, [-1]=4, [-1]=-4, [1]=4, [1]=-4, [4]=0, [4]=0, [4]=0, [4]=-4}
            var_0012 = 0
            var_0013 = {[8496]=var_0012, [8496]=var_0012, [8502]=var_0012, [8498]=var_0012, [8502]=var_0012, [8498]=var_0012, [8496]=var_0012, [8502]=var_0012, [7730]=var_0012}
            var_0014 = {[8]=-17, [0]=-17, [8]=8, [8]=8, [8]=-7, [8]=0, [0]=8, [0]=-7}
            var_0015 = {[13]=var_0012, [13]=var_0012, [29]=var_0012, [29]=var_0012, [29]=var_0012, [13]=var_0012, [13]=var_0012}
            var_0016 = 1
            var_0017 = get_party_list2()
            for var_0018 in ipairs(var_0017) do
                clear_item_flag(var_0018, 8)
                clear_item_flag(var_0018, 7)
                clear_item_flag(var_0018, 3)
                clear_item_flag(var_0018, 2)
                clear_item_flag(var_0018, 0)
                clear_item_flag(var_0018, 9)
                var_0004 = set_npc_quality(var_0018, 0, get_npc_quality(var_0018, 3) - get_npc_quality(var_0018, 3))
                var_0004 = set_npc_quality(var_0018, 5, get_npc_quality(var_0018, 6) - get_npc_quality(var_0018, 5))
                set_schedule_type(var_0018, 31)
            end
            var_001A = var_0017
            if get_schedule_type(-167) == 0 or get_schedule_type(-168) == 0 then
                if not utility_unknown_1080(-167) then
                    var_001A = table.insert(var_001A, get_npc_name(-167))
                    set_schedule_type(-167, 11)
                end
                if not utility_unknown_1080(-168) then
                    var_001A = table.insert(var_001A, get_npc_name(-168))
                    set_schedule_type(-168, 11)
                end
            end
            move_object(var_0010, -357)
            for var_001B in ipairs(var_001A) do
                if var_001B == get_npc_name(-356) then
                    halt_scheduled(var_001B)
                    if not get_item_flag(var_001B, 1) then
                        var_0004 = execute_usecode_array(var_001B, {var_0013[var_0016], 17497, 7777})
                        var_001D = {var_0010[3] - 1, var_0010[2], var_0010[1] + var_0011[var_0016 + 1]}
                    else
                        var_001D = {var_0010[3], var_0010[2], var_0010[1] + var_0014[var_0016 + 1]}
                        get_object_frame(var_001B, var_0015[var_0016])
                        var_001E = random2(20, 14)
                        var_0004 = execute_usecode_array(var_001B, {1561, 8533, var_001E, 7719})
                    end
                    move_object(var_001D, var_001B)
                    var_0016 = var_0016 + 2
                end
            end
            clear_item_flag(-356, 4)
            var_0004 = execute_usecode_array(-356, {1552, 8021, 2, 7719})
        end
    end
end