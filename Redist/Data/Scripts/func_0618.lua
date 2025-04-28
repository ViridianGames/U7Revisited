require "U7LuaFuncs"
-- Initializes the Avatar's appearance via a moongate, setting flags and creating items to set up the game's starting scene.
function func_0618(eventid, itemref)
    local local0

    if get_flag(-356, 16) then
        set_flag(-356, 16, false)
        local0 = add_item(-356, {
            1562, 8021, 1025, 8021, 10, 7975, 0, 17462, 8019,
            0, 17462, 8019, 0, 17462, 7763
        })
    end
    return
end