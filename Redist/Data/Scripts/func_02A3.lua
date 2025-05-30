--- Best guess: Manages a parrot NPC’s interaction, displaying various squawks, treasure hints, or party gold info based on its state or player actions.
function func_02A3(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004, var_0005

    if eventid == 1 then
        var_0000 = get_object_frame(objectref)
        if var_0000 == 0 then
            var_0001 = object_select_modal()
            set_object_quality(objectref, 15)
            if unknown_0031H(var_0001) then
                bark(var_0001, "@Hey, that hurt!@")
                return
            end
            if get_object_shape(var_0001) == 675 and get_object_frame(var_0001) == 10 then
                var_0002 = unknown_0001H({0, "@I will tell!@", {17490, 7715}}, var_0001)
                var_0002 = unknown_0002H({16, "@The treasure is at@", {17490, 7715}}, var_0001)
                var_0002 = unknown_0002H({32, "@169 South@", {17490, 7715}}, var_0001)
                var_0002 = unknown_0002H({48, "@28 East@", {17490, 7715}}, var_0001)
            end
        elseif var_0000 == 10 then
            var_0003 = random2(7, 1)
            if var_0003 == 1 then
                var_0002 = unknown_0001H({0, "@Squawk!@", {17490, 7715}}, objectref)
            elseif var_0003 == 2 then
                var_0002 = unknown_0001H({0, "@Polly want a cracker?@", {17490, 7715}}, objectref)
            elseif var_0003 == 3 or var_0003 == 4 then
                var_0002 = unknown_0001H({0, "@I know where@", {17490, 7715}}, objectref)
                var_0002 = unknown_0002H({16, "@the treasure is!@", {17490, 7715}}, objectref)
            elseif var_0003 == 5 then
                var_0002 = unknown_0001H({0, "@Gimmee a cracker!@", {17490, 7715}}, objectref)
            elseif var_0003 == 6 or var_0003 == 7 then
                var_0002 = unknown_0001H({0, "@Pretty bird!@", {17490, 7715}}, objectref)
                if not npc_in_party(2) then
                    var_0002 = unknown_0002H({16, "@Ugly Bird!@", {17490, 7715}}, get_npc_name(2))
                    var_0002 = unknown_0002H({32, "@Ugly Boy!@", {17490, 7715}}, objectref)
                    var_0002 = unknown_0002H({48, "@Hey!!@", {17490, 7715}}, get_npc_name(2))
                end
            end
        elseif var_0000 == 11 then
            var_0004 = check_inventory_space(359, 359, 644, 357)
            var_0005 = "Party gold: " .. var_0004
            bark(objectref, var_0005)
        elseif var_0000 == 17 or var_0000 == 18 or var_0000 == 19 then
            if not unknown_0079H(objectref) then
                var_0002 = unknown_0001H({18, 8006, 12, 7947, 19, 8006, 18, 8024, 17, 8006, 17, 7768}, objectref)
                if not npc_in_party(2) then
                    var_0002 = unknown_0002H({4, "@That is really weird.@", {7762}}, get_npc_name(2))
                end
            end
        elseif var_0000 == 20 then
            var_0002 = unknown_0001H({4, -2, 7947, 23, 7768}, objectref)
        end
    end
    return
end