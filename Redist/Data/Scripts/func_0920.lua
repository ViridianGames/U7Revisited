require "U7LuaFuncs"
-- Function 0920: Select party member for training
function func_0920(eventid, itemref)
    local local0

    say(itemref, "\"Which of you wishes to train?\"")
    local0 = call_090DH()
    set_return(local0)
end