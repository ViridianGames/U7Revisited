-- Function 0868: Random verb forms
function func_0868(eventid, itemref)
    local local0, local1, local2, local3, local4

    local0 = {
        "lactate", "lactated", "lactating",
        "grovel", "grovelled", "grovelling",
        "brew", "*", "*",
        "digest", "*", "*",
        "complain", "*", "*",
        "gump", "*", "*",
        "guffaw", "*", "*",
        "loiter", "*", "*",
        "solicit", "*", "*",
        "represent", "*", "*",
        "conjugate", "*", "*",
        "sink", "sank", "*",
        "harvest", "*", "*",
        "gossip", "*", "*",
        "falsify", "falsified", "*",
        "sue", "sued", "suing",
        "gyrate", "gyrated", "gyrating",
        "outstrech", "*", "*",
        "deflower", "*", "*"
    }
    local1 = _ArraySize(local0) / 3
    local1 = _Random2(local1, 1)
    local2 = local0[local1 * 3 - 2]
    local3 = local0[local1 * 3 - 1]
    local4 = local0[local1 * 3]
    if local3 == "*" then
        local3 = local2 .. "ed"
    end
    if local4 == "*" then
        local4 = local2 .. "ing"
    end
    set_return({local4, local3, local2})
end