--- Best guess: Manages cart interaction, checking ownership and triggering movement or dialogue.
function utility_ship_0777(eventid, objectref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    var_0000 = objectref
    var_0001 = get_object_owner(var_0000) --- Guess: Gets item owner
    if not var_0001 then
        if not _CheckNPCStatus(10, var_0000) then
            _SetQuestFlag(10, var_0000) --- Guess: Sets quest flag
            _SetQuestFlag(26, var_0000) --- Guess: Sets quest flag
            cast_multiple_spells({"@Whoa!@"}, 356) --- Guess: Casts multiple spells
        else
            var_0002 = find_nearby(0, 16, 796, var_0000) --- Guess: Sets NPC location
            if not var_0002 then
                var_0003 = check_object_ownership(359, 797, 796, 10) --- Guess: Checks item ownership
                if not var_0003 then
                    if utility_unknown_0781() then --- External call to check sitting
                        set_object_flag(var_0000, 10) --- Guess: Sets item flag
                        set_object_flag(var_0001, 26) --- Guess: Sets item flag
                        cast_multiple_spells({"@Giddy-up!@"}, 356) --- Guess: Casts multiple spells
                    else
                        var_0004 = utility_unknown_0947(var_0000) --- External call to sit down
                    end
                else
                    if #get_party_members() == 1 then
                        bark(objectref, "@The title for this cart must first be purchased.@")
                    else
                        bark(objectref, "@We must first purchase the title for this cart.@")
                    end
                end
            end
        end
    end
end