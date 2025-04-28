require "U7LuaFuncs"
-- Handles paintbrush usage, applying paint with random dialogue outcomes.
function func_0337H(eventid, itemref)
    if eventid == 1 then
        local frame = get_item_frame(itemref)
        if frame < 2 then
            say(0, "Finger-painting again?")
            return
        end
        local target = item_select_modal() -- TODO: Implement LuaItemSelectModal for callis 0033.
        local item_type = get_item_type(target)
        if item_type == 823 and get_item_frame(target) < 2 then -- 0337H: Paintbrush.
            local target_frame = get_item_frame(target)
            local frame_mod = target_frame % 8
            local outcome = random(1, 10)
            local message
            if outcome == 1 then
                message = "Looks great!"
            elseif outcome == 2 then
                message = "Do not quit your day job."
            elseif outcome == 3 then
                message = {"I can barely", "see the numbers."}
            elseif outcome == 4 then
                message = "Stay within the lines."
            elseif outcome == 5 then
                message = "What is it?"
            end
            say(0, message)
            if frame_mod < 7 then
                set_item_frame(target, target_frame + 1)
            end
        elseif get_wearer(target) then
            say(0, "Tattooing?")
        else
            say(0, {"The stain will", "never come out."})
        end
    else
        say(0, "Use pigments!")
    end
end