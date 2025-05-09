--- Best guess: Manages a game state check for an event (likely a race or competition), setting flags 31 and 32 based on conditions and calling an external function if both are set.
function func_060B(eventid, itemref)
    if eventid ~= 2 then
        return
    end

    if get_flag(31) and get_flag(32) then
        unknown_083DH()
    end

    if not get_flag(31) then
        set_flag(31, true)
    end

    if not get_flag(32) then
        set_flag(32, true)
    end
end