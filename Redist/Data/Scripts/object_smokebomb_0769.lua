--- Best guess: Manages a smokebomb, creating a smoke effect at the player's location and affecting nearby NPCs.
function object_smokebomb_0769(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    if eventid == 1 or eventid == 4 then
        close_gumps()
        var_0000 = find_nearby(0, 300, 494, objectref)
        for var_0001 in ipairs(var_0000) do
            set_schedule_type(0, var_0003)
            set_attack_mode(7, var_0003)
            set_oppressor(-356, var_0003)
        end
        var_0004 = get_object_position(objectref)
        halt_scheduled(objectref)
        sprite_effect(25, 0, 0, 0, var_0004[2], var_0004[1], 3)
        sprite_effect(25, 1, 0, 2, var_0004[2], var_0004[1], 3)
        sprite_effect(25, 2, 0, -2, var_0004[2], var_0004[1], 3)
        sprite_effect(25, 3, 2, 0, var_0004[2], var_0004[1], 3)
        sprite_effect(25, 4, -2, 0, var_0004[2], var_0004[1], 3)
        sprite_effect(25, 1, 2, 2, var_0004[2], var_0004[1], 3)
        sprite_effect(25, 2, -2, 2, var_0004[2], var_0004[1], 3)
        sprite_effect(25, 3, 2, -2, var_0004[2], var_0004[1], 3)
        sprite_effect(25, 4, -2, -2, var_0004[2], var_0004[1], 3)
        remove_item(objectref)
    end
end