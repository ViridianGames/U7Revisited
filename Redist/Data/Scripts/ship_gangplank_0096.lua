require "U7LuaFuncs"
-- Start ship_gangplank_0096.lua
local strings = {
    [0x0000] = "@The sails must be furled before the planks are raised.@",
    [0x0039] = "@I think the gangplank is blocked.@"
}
answers = {}
answer = nil
local debug = true
function log(...) if debug then print(...) end end

function ship_gangplank_0096(object_id, event)
    log("ship_gangplank_0096 called with object_id:", object_id, "event:", event)
    if event == 1 then
        if get_flag(0x010) and not get_flag(0x088) then -- Placeholder: sail state
            say(object_id, strings[0x0000])
        elseif not get_flag(0x829) then -- Placeholder: block check
            say(object_id, strings[0x0039])
        elseif not get_flag(0x081) then
            -- TODO: Raise gangplank (calli 007E)
        end
    end
    log("ship_gangplank_0096 completed")
end
-- End ship_gangplank_0096.lua