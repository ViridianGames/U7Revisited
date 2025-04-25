-- Manages lit light source (e.g., candle), switching to unlit or updating state.
function func_0152H(eventid, itemref)
    if eventid == 1 or eventid == 2 then
        set_item_type(itemref, 336) -- 0150H: Unlit candle.
        set_item_state(itemref) -- TODO: Implement LuaSetItemState for calli 005C.
    elseif eventid == 7 then
        set_item_type(itemref, 336) -- 0150H: Unlit candle.
        local obj = call_script(0x0827, -356, itemref) -- TODO: Map 0827H.
        local arr = {7769, obj, 8449, 17514, 17505} -- Array from arrc 0005H.
        execute_action(-356, arr) -- TODO: Implement LuaExecuteAction for callis 0001.
    elseif eventid == 5 then
        call_script(0x0905, itemref) -- TODO: Map 0905H.
    end
end