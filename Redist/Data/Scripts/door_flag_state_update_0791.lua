--- Func0817 / 0x817: set door-bank flags and pulse matching winch/gear pieces.
--- var0000 is a 1-based flag triple written to flags 740/741/742.

function utility_unknown_0791(flag_triple)
    if type(flag_triple) ~= "table" then
        return
    end

    set_flag(740, flag_triple[1] and flag_triple[1] ~= 0)
    set_flag(741, flag_triple[2] and flag_triple[2] ~= 0)
    set_flag(742, flag_triple[3] and flag_triple[3] ~= 0)

    local selected = 0
    if get_flag(740) then selected = 230 end
    if get_flag(741) then selected = 220 end
    if get_flag(742) then selected = 210 end

    -- Shape 949 (0x3B5) gear/winch pieces near Avatar
    local gears = find_nearby_avatar(949) or {}
    for _, gear in ipairs(gears) do
        if get_object_quality(gear) == selected then
            -- Original runs a short usecode-array anim; approximate with a frame nudge
            local fr = get_object_frame(gear) or 0
            set_object_frame(gear, (fr + 1) % 8)
        end
    end
end
