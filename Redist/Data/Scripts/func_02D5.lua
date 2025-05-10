--- Best guess: Simulates a gambling wheel interaction, prompting bets and cycling states, active outside 3 AM to 3 PM.
function func_02D5(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006

    if eventid == 1 and not unknown_0079H(objectref) then
        var_0000 = random2(16, 1)
        -- calli 005C, 1 (unmapped)
        unknown_005CH(objectref)
        var_0001 = unknown_0001H({1546, 8021, 29, 17496, 8014, 3, 17447, 8014, 3, -14, 7947, 29, 8024, 1, 17447, 8014, 1, 17447, 8014, 1, 17447, 8014, 1, 17447, 8526, var_0000, -5, 7947, 29, 17496, 17486, 17409, 17486, 17409, 17486, 17409, 8014, 29, 7768}, objectref)
        if get_time_hour() >= 15 or get_time_hour() <= 3 then
            if not unknown_0937H(-232) then
                start_conversation()
                add_dialogue("@Round she goes!@")
                add_dialogue("@Place your bets.@")
            end
            -- calli 001D, 2 (unmapped)
            unknown_001DH(9, -232)
            var_0002 = check_flag_location(0, 7, 520, objectref)
            var_0003 = check_flag_location(0, 5, 644, var_0002)
            while true do
                var_0004 = var_0003
                var_0005 = var_0004
                var_0006 = var_0005
                -- calli 008A, 2 (unmapped)
                unknown_008AH(11, var_0006)
                if not var_0006 then
                    break
                end
            end
        end
    end
    return
end