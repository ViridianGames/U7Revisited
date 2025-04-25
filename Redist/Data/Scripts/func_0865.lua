-- Function 0865: Random noun pair with plural
function func_0865(eventid, itemref)
    local local0, local1, local2, local3

    local0 = {
        "soup", "*", "eruption", "*", "quagmire", "*", "bureaucracy", "bureaucracies",
        "tractor", "*", "Socialism", "*", "Capitalism", "*", "hammer", "*",
        "sickle", "*", "imperialism", "*", "crankshaft", "*", "carbuerator", "*",
        "Gump", "*", "lenticular cloud", "*", "clock", "*", "sloop", "*",
        "barge", "*"
    }
    local1 = _ArraySize(local0) / 2
    local1 = _Random2(local1, 1)
    local2 = local0[local1 * 2 - 1]
    local3 = local0[local1 * 2]
    if local3 == "*" then
        local3 = local2 .. "s"
    end
    set_return({local3, local2})
end