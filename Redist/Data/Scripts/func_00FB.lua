--- Best guess: Manages ship sailing interaction, checking for a deed (scroll, ID 797) and displaying dialogue if missing, or handling sailing logic if conditions are met.
function func_00FB(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    if eventid ~= 1 then
        return
    end
    -- callis 0081, 0 (unmapped)
    if unknown_0081H() then
        -- calli 007E, 0 (unmapped)
        unknown_007EH()
    end
    -- callis 0058, 1 (unmapped)
    if unknown_0058H(objectref) then
        var_0000 = check_flag_location(0, 199, 5, objectref)
        var_0001 = check_flag_location(0, 251, 5, objectref)
        if not is_in_int_array(objectref, var_0001) then
            var_0001 = var_0001 .. {objectref}
        end
        -- callis 0088, 2 (unmapped)
        if not unknown_0088H(10, 356) then
            var_0002 = get_object_quality(objectref)
            var_0003 = check_inventory_space(359, var_0002, 797, 357)
            if not var_0003 then
                start_conversation()
                if array_size(get_party_members()) == 1 then
                    add_dialogue("@The deed for this vessel must first be purchased.@")
                else
                    add_dialogue("@We must purchase the deed for this vessel before we sail her.@")
                end
                return
            end
        end
        -- call [0001] (080DH, unmapped)
        if not unknown_080DH() then
            -- call [0002] (0831H, unmapped)
            unknown_0831H(objectref)
        else
            -- call [0003] (08B3H, unmapped)
            var_0004 = unknown_08B3H(aidx(var_0000, 1))
            -- calli 0089, 2 (unmapped)
            unknown_0089H(20, objectref)
        end
    else
        -- calli 008A, 2 (unmapped)
        unknown_008AH(20, objectref)
        -- call [0004] (0830H, unmapped)
        unknown_0830H(0, var_0001)
        unknown_008AH(10, objectref)
        unknown_008AH(26, objectref)
        play_music(0, 255)
    end
    return
end