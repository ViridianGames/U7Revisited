require "U7LuaFuncs"
-- Function 0928: Comment on drinking vessel with liquid
function func_0928(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10

    local1 = _GetItemFrame(get_item_container(itemref)) % 2
    if local1 == 0 then
        say(itemref, {"I bet that would work much better if thou wouldst put some liquid in it..."})
        add_dialogue_option("Perhaps some BEER for instance.", -4)
        add_dialogue_option("Or maybe some WINE>>>", -3)
    else
        local2 = {"laststuff", "stuff", "stuff", "stuff", "stuff", "stuff", "ale", "beer", "wine", "blood", "water"}
        local3 = 0
        local4 = _GetItemQuality(itemref)
        while local2 do
            local3 = local3 + 1
            if local4 == local3 then
                local8 = "Gee, I bet that " .. local2[local3] .. " was pretty good...."
            end
            local2 = get_next_string() -- sloop
        end
        local9 = math.random(1, 10)
        if local9 == 1 then
            say(itemref, "mmmm... I bet that would sure wet a body's whistle.")
        end
        if local9 == 2 then
            local10 = show_dialogue_options()
            local8 = "Why dost thou not wait until dinner to drink that " .. local2[local1] .. ", " .. local10 .. "."
        end
        if local9 > 2 then
            say(itemref, local8)
        end
    end
    return
end