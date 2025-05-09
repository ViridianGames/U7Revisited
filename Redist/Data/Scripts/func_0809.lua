--- Best guess: Manages cart interaction, checking ownership and triggering movement or dialogue.
function func_0809(eventid, itemref)
    local var_0000, var_0001, var_0002, var_0003, var_0004

    var_0000 = itemref
    var_0001 = get_item_owner(var_0000) --- Guess: Gets item owner
    if not var_0001 then
        if not _CheckNPCStatus(10, var_0000) then
            _SetQuestFlag(10, var_0000) --- Guess: Sets quest flag
            _SetQuestFlag(26, var_0000) --- Guess: Sets quest flag
            cast_multiple_spells({"@Whoa!@"}, 356) --- Guess: Casts multiple spells
        else
            var_0002 = unknown_0035H(0, 16, 796, var_0000) --- Guess: Sets NPC location
            if not var_0002 then
                var_0003 = check_item_ownership(359, 797, 796, 10) --- Guess: Checks item ownership
                if not var_0003 then
                    if calle_080DH() then --- External call to check sitting
                        set_item_flag(var_0000, 10) --- Guess: Sets item flag
                        set_item_flag(var_0001, 26) --- Guess: Sets item flag
                        cast_multiple_spells({"@Giddy-up!@"}, 356) --- Guess: Casts multiple spells
                    else
                        var_0004 = calle_08B3H(var_0000) --- External call to sit down
                    end
                else
                    if array_size(get_party_members()) == 1 then
                        bark(itemref, "@The title for this cart must first be purchased.@")
                    else
                        bark(itemref, "@We must first purchase the title for this cart.@")
                    end
                end
            end
        end
    end
end