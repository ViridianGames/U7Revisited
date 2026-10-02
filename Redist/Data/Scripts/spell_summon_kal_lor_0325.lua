--- Help (Kal Lor). Oracle: usecode.dc Func0645 object#(0x645).
--- Linear spell: teleport party to Lord British's castle (usecode tile 936,1146).

local HELP_X = 936
local HELP_Z = 1146

function spell_summon_kal_lor_0325(eventid, objectref)
    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@Kal Lor@")
    if not check_spell_requirements() then
        execute_usecode_array(objectref, {17511, 7781})
        return
    end

    execute_usecode_array(objectref, {17511, 8037, 64, 7768})

    local party = get_party_list2() or {}
    for _, npc_id in ipairs(party) do
        -- Clear common status flags (asleep, poisoned, etc.) then warp.
        local obj_id = get_npc_object_id(npc_id)
        if obj_id and obj_id ~= -1 then
            clear_item_flag(obj_id, 1)
            clear_item_flag(obj_id, 2)
            clear_item_flag(obj_id, 3)
            clear_item_flag(obj_id, 7)
            clear_item_flag(obj_id, 8)
        end
        -- Engine pos: x, height y, map z. Usecode [936, 1146, 0] → (936, 0, 1146).
        set_npc_pos(npc_id, HELP_X, 0, HELP_Z)
    end
end
