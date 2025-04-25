-- Prompts for an NPC or "Nobody" and returns the selected NPC ID.
function func_090E()
    local local0, local1, local2, local3, local4

    local0 = get_player_name(external_008DH()) -- Unmapped intrinsic
    local1 = external_008DH() -- Unmapped intrinsic
    local2 = {local1, 0}
    local3 = external_090CH({local0, "Nobody"}) -- Unmapped intrinsic
    local4 = local3 == 2 and 0 or local2[local3]
    return external_003AH(local4) -- Unmapped intrinsic
end