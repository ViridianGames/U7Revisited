--- Best guess: Manages a paintbrush, allowing painting on specific items (e.g., canvas, ID 837) with pigments, with random feedback messages.
function object_unknown_0823(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid == 1 then
        var_0000 = get_object_frame(objectref)
        if var_0000 < 2 then
            utility_unknown_1022("@Finger-painting again?@")
        else
            var_0001 = object_select_modal()
            var_0002 = get_object_shape(var_0001)
            if var_0002 == 823 then
                if get_object_frame(var_0001) < 2 then
                    var_0001 = object_select_modal()
                    if get_object_shape(var_0001) == 837 then
                        var_0003 = get_object_frame(var_0001) % 8
                        var_0004 = random2(10, 1)
                        if var_0004 == 1 then
                            var_0005 = "@Looks great!@"
                        elseif var_0004 == 2 then
                            var_0005 = "@Do not quit your day job.@"
                        elseif var_0004 == 3 then
                            var_0005 = {"@I can barely", "see the numbers.@"}
                        elseif var_0004 == 4 then
                            var_0005 = "@Stay within the lines.@"
                        elseif var_0004 == 5 then
                            var_0005 = "@What is it?@"
                        end
                        utility_unknown_1022(var_0005)
                        if var_0003 < 7 then
                            get_object_frame(get_object_frame(var_0001) + 1, var_0001)
                        end
                    elseif is_npc(var_0001) then
                        utility_unknown_1022("@Tattooing?@")
                    else
                        utility_unknown_1022({"@The stain will", "never come out.@"})
                    end
                end
            else
                utility_unknown_1022("@Use pigments!@")
            end
        end
    end
end