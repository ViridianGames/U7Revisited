require "U7LuaFuncs"
-- Casts the "Kal Lor" spell, summoning a bright light effect and adjusting party member properties.
function func_0645(eventid, itemref)
    local local0, local1, local2, local3, local4, local5

    if eventid == 1 then
        if not get_flag(61) then
            item_say("@Kal Lor@", itemref)
            if not external_0906H() then -- Unmapped intrinsic
                set_flag(39, true)
                local0 = add_item(itemref, {1605, 17493, 17519, 17505, 17517, 17516, 17505, 8047, 64, 7768})
                local1 = get_party_members()
                for local2 in ipairs(local1) do
                    local3 = local2
                    local4 = local3
                    set_flag(local4, 8, true)
                    set_flag(local4, 3, true)
                    set_flag(local4, 2, true)
                    set_flag(local4, 7, true)
                end
            else
                local0 = add_item(itemref, {1542, 17493, 17519, 17505, 17517, 17516, 17505, 7791})
            end
        end
    elseif eventid == 2 then
        local5 = {1146, 936}
        external_003EH(-357, local5) -- Unmapped intrinsic
    end
    return
end