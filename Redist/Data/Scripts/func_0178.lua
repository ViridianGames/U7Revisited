-- Manages bucket interaction, possibly for filling or emptying.
function func_0178H(eventid, itemref)
    if eventid ~= 1 then
        local state = call_script(0x081B, itemref) -- TODO: Map 081BH (get bucket state?).
        if state == 1 then
            if not call_script(0x081D, itemref, 270, 0, 0, 0, 7) then -- TODO: Map 081DH.
                call_script(0x081E, itemref, 433, 1, 2, 432, 0, 3, 0, 1) -- TODO: Map 081EH.
                set_stat(itemref, 31) -- Sets quality to 31 (filled?).
            else
                call_script(0x0818) -- TODO: Map 0818H (failure action?).
            end
        elseif state == 0 then
            if not call_script(0x081D, itemref, 270, 1, 0, 0, 7) then
                call_script(0x081E, itemref, 433, 0, 1, 432, 1, 0, -3, 7)
                set_stat(itemref, 30) -- Sets quality to 30 (empty?).
            else
                call_script(0x0818)
            end
        elseif state == 2 then
            call_script(0x0819, itemref) -- TODO: Map 0819H (use bucket?).
        elseif state == 3 then
            call_script(0x081A, itemref) -- TODO: Map 081AH (drop bucket?).
        end
    end
end