-- Function 0927: Comment on empty drinking vessel
function func_0927(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6

    local1 = _GetItemFrame(get_item_container(itemref))
    if local1 == 0 then
        add_dialogue(itemref, {"I bet that would work much better if thou wouldst put some liquid in it..."})
        add_dialogue_option("Perhaps some BEER for instance.", -4)
        add_dialogue_option("Or maybe some WINE>>>", -3)
    else
        local2 = {"last stuff", "stuff", "stuff", "stuff", "stuff", "stuff", "ale", "beer", "wine", "blood", "water"}
        local3 = math.random(1, 10)
        local4 = local2[local1]
        local5 = "Gee, I bet that " .. local4 .. " was pretty good...."
        if local3 == 1 then
            local6 = "mmmm... I bet that would sure wet a body's whistle."
        end
        if local3 == 2 then
            local7 = show_dialogue_options()
            local5 = "Why dost thou not wait until dinner to drink that " .. local4 .. ", " .. local7 .. "."
        end
        add_dialogue(itemref, local5)
    end
    return
end