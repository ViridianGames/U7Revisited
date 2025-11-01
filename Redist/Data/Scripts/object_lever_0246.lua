--- Best guess: Manages state-based interactions for an object (e.g., switch or panel), adjusting quality (30 or 31) based on state, likely part of a puzzle or interactive mechanism.
function object_lever_0246(eventid, objectref)
    local var_0000

    if eventid ~= 1 then
        return
    end
    -- call [0000] (081BH, unmapped)
    var_0000 = utility_unknown_0795(objectref)
    if var_0000 == 1 then
        -- call [0001] (081DH, unmapped)
        if not utility_position_0797(5, 3, 0, 0, 250, objectref) then
            -- call [0002] (081EH, unmapped)
            utility_unknown_0798(7, 0, 0, 0, 392, 1, 1, 225, objectref)
            set_object_quality(objectref, 31)
        else
            -- call [0003] (0818H, unmapped)
            utility_unknown_0792()
        end
    elseif var_0000 == 0 then
        -- call [0001] (081DH, unmapped)
        if not utility_position_0797(7, 0, 3, 1, 250, objectref) then
            -- call [0002] (081EH, unmapped)
            utility_unknown_0798(7, 0, 0, 1, 392, 2, 0, 225, objectref)
            set_object_quality(objectref, 30)
        else
            -- call [0003] (0818H, unmapped)
            utility_unknown_0792()
        end
    elseif var_0000 == 2 then
        -- call [0004] (0819H, unmapped)
        utility_unknown_0793(objectref)
    elseif var_0000 == 3 then
        -- call [0005] (081AH, unmapped)
        utility_unknown_0794(objectref)
    end
    return
end