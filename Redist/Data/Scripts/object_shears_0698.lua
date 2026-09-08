--- Shears / scissors (shape 698).
--- Double-click, then click cloth (851) to cut it into bandages (827).

local CLOTH = 851
local BANDAGE = 827

function object_shears_0698(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    close_gumps()
    local target = click_on_item()
    if not target or target == 0 then
        return
    end

    if get_object_shape(target) ~= CLOTH then
        if utility_unknown_1023 then
            utility_unknown_1023(
                "@Might not those come in handy for cutting cloth into bandages?@")
        else
            item_say(
                "@Might not those come in handy for cutting cloth into bandages?@",
                objectref)
        end
        return
    end

    -- Morph cloth → bandages in place (original usecode set_shape).
    set_object_shape(target, BANDAGE)
    set_object_frame(target, math.random(0, 1))
end
