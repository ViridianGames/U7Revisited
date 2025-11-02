-- Start ship_gangplank_0096.lua
local strings = {
    [0x0000] = "@The sails must be furled before the planks are raised.@",
    [0x0039] = "@I think the gangplank is blocked.@"
}
answers = {}
answer = nil
local debug = true
function log(...) if debug then print(...) end end

function ship_gangplank_0096(eventid, objectref)
    log("ship_gangplank_0096 called with objectref:", objectref, "eventid:", eventid)
    if eventid == 1 then
        if get_flag(0x010) and not get_flag(0x088) then -- Placeholder: sail state
            add_dialogue(strings[0x0000])
        elseif not get_flag(0x829) then -- Placeholder: block check
            add_dialogue(strings[0x0039])
        elseif not get_flag(0x081) then
            -- TODO: Raise gangplank (calli 007E)
        end
    end
    log("ship_gangplank_0096 completed")
end
-- End ship_gangplank_0096.lua