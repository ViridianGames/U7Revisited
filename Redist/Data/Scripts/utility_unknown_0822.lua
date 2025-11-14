--- Best guess: Updates item types (e.g., 303, 876, 935, 936) based on quality, likely for puzzle or state transitions.
function utility_unknown_0822(eventid, objectref, arg1)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005, var_0006, var_0007

    var_0000 = eventid
    var_0001 = arg1
    var_0002 = get_object_quality(var_0001) --- Guess: Gets item quality
    var_0003 = {}
    if var_0000 == 1 or var_0000 == 359 then
        var_0003 = create_array(303, var_0003) --- Guess: Creates array
        var_0003 = create_array(876, var_0003) --- Guess: Creates array
    elseif var_0000 == 0 or var_0000 == 359 then
        var_0003 = create_array(936, var_0003) --- Guess: Creates array
        var_0003 = create_array(935, var_0003) --- Guess: Creates array
    end
    if var_0003 then
        -- Guess: sloop updates item types
        for i = 1, 5 do
            var_0006 = ({4, 5, 6, 3, 139})[i]
            if get_object_quality(var_0006) == var_0002 then
                var_0007 = get_object_shape(var_0006) --- Guess: Gets item type
                if var_0007 == 303 then
                    utility_event_0818(936, var_0006) --- External call to add items
                elseif var_0007 == 876 then
                    utility_event_0818(935, var_0006) --- External call to add items
                elseif var_0007 == 936 then
                    utility_event_0819(303, var_0006) --- External call to add items
                elseif var_0007 == 935 then
                    utility_event_0819(876, var_0006) --- External call to add items
                end
            end
        end
    end
end