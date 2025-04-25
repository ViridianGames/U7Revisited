-- Function 02D5: Gambling wheel mechanic
function func_02D5(eventid, itemref)
    -- Local variables (7 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6

    if eventid ~= 1 or callis_0079(itemref) then
        return
    end

    local0 = _Random2(1, 16)
    calli_005C(itemref)
    local1 = callis_0001({
        1546, 8021, 29, 17496, 8014, 3, 17447, 8014, 3, -14, 7947, 29,
        8024, 1, 17447, 8014, 1, 17447, 8014, 1, 17447, 8014, 1, 17447,
        8526, local0, -5, 7947, 29, 17496, 17486, 17409, 8526, local0,
        -8, 17419, 17409, 17486, 17409, 17486, 17409, 8014, 29, 7768
    }, itemref)
    if _GetTimeHour() >= 15 or _GetTimeHour() <= 3 then
        if call_0937H(-232) then
            call_0904H({"@Round she goes!@", "@Place your bets.@"}, -232)
        end
        calli_001D(9, -232)
        local2 = callis_0035(0, 7, 520, itemref)
        local3 = callis_0035(0, 5, 644, local2)
        while local3 do
            -- Note: Original has 'sloop' and 'db 2' for iteration, ignored
            local6 = local3
            calli_008A(11, local6)
            local3 = callis_0035(0, 5, 644, local2)
        end
    end

    return
end