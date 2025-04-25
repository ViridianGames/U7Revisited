-- Function 0866: Random noun pair with plural
function func_0866(eventid, itemref)
    local local0, local1, local2, local3

    local0 = {
        "batting cage", "*", "flagstaff", "*", "digit", "*", "nail", "*",
        "epaphite", "*", "sycophant", "*", "demagouge", "*", "prophet", "*",
        "profit", "*", "pus", "pus", "mulch", "mulch", "Garden Gnome", "*",
        "personal crisis", "personal crises", "wit", "*", "bathysphere", "*",
        "jello-flavoring", "*", "origami ball", "*", "communion wafer", "*",
        "armageddon", "*", "baloon payment", "*"
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