-- Manages coin flipping game with dialogue for heads or tails.
function func_0284H(eventid, itemref)
    if eventid ~= 1 then
        return
    end
    use_item() -- TODO: Implement LuaUseItem for calli 007E.
    set_stat(itemref, 23) -- Sets quality to 23.
    local result = call_script(0x0937, -356) -- TODO: Map 0937H (possibly check state).
    local result2 = call_script(0x0937, -1)
    if not (result or not result2) then
        return
    end
    if call_script(0x08F7, -1) then -- TODO: Map 08F7H (possibly coin flip condition).
        return
    end
    call_script(0x0933, -356, "Call it.", 0) -- TODO: Map 0933H (possibly say with delay).
    local flip = random(1, 2)
    if flip == 1 then
        call_script(0x0933, -1, "Tails.", 16)
        call_script(0x0933, -356, "It is heads.", 32)
    else
        call_script(0x0933, -1, "Heads.", 16)
        call_script(0x0933, -356, "It is tails.", 32)
    end
    if random(1, 3) == 1 then
        call_script(0x0933, -1, "Again!", 48)
    end
end