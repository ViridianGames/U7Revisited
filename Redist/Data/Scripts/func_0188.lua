require "U7LuaFuncs"
-- Manages well interaction, possibly for drawing water.
function func_0188H(eventid, itemref)
    if eventid ~= 1 then
        local state = call_script(0x081B, itemref) -- TODO: Map 081BH (get well state?).
        if state == 1 then
            if not call_script(0x081D, itemref, 225, 0, 0, 0, 7) then
                call_script(0x081E, itemref, 250, 1, 2, 246, 0, 3, 0, 1)
                set_stat(itemref, 31) -- Sets quality to 31 (filled?).
            else
                call_script(0x0818) -- TODO: Map 0818H (failure action?).
            end
        elseif state == 0 then
            if not call_script(0x081D, itemref, 225, 1, 0, 0, 7) then
                call_script(0x081E, itemref, 250, 0, 1, 246, 1, 0, -3, 7)
                set_stat(itemref, 30) -- Sets quality to 30 (empty?).
            else
                call_script(0x0818)
            end
        elseif state == 2 then
            call_script(0x0819, itemref) -- TODO: Map 0819H (use well?).
        elseif state == 3 then
            call_script(0x081A, itemref) -- TODO: Map 081AH (interact with well?).
        end
    end
end