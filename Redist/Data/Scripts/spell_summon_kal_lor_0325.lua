--- Help (Kal Lor). Oracle: usecode.dc Func0645 object#(0x645).
--- Linear spell: after the Trinsic password is known (flag 61 / gflags[0x3D]),
--- clear party poison/curse/charm/paralyze, set flag 39 (gflags[0x27]), and
--- warp the party to Lord British's castle (usecode [936, 1146, 0]).

local HELP_X = 936
local HELP_Z = 1146
-- Exult gflags[0x003D] = Trinsic Blackbird password (Finnigan sets flag 61).
local FLAG_TRINSIC_PASSWORD = 61
-- Exult gflags[0x0027] set on successful Help cast.
local FLAG_HELP_USED = 39

local function clear_party_status_flags()
    local party = get_party_list2() or {}
    for _, npc_id in ipairs(party) do
        local obj_id = get_npc_object_id(npc_id)
        if obj_id and obj_id ~= -1 then
            -- Oracle clears only 8,3,2,7 (poisoned, cursed, charmed, paralyzed).
            clear_item_flag(obj_id, 8)
            clear_item_flag(obj_id, 3)
            clear_item_flag(obj_id, 2)
            clear_item_flag(obj_id, 7)
        end
    end
end

local function teleport_party_to_castle()
    local party = get_party_list2() or {}
    for _, npc_id in ipairs(party) do
        -- Engine pos: x, height y, map z. Usecode [936, 1146, 0] → (936, 0, 1146).
        set_npc_pos(npc_id, HELP_X, 0, HELP_Z)
    end
end

function spell_summon_kal_lor_0325(eventid, objectref)
    if eventid == 2 then
        teleport_party_to_castle()
        return
    end

    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)

    -- Without the Trinsic password, Exult fizzles with no bark.
    if not get_flag(FLAG_TRINSIC_PASSWORD) then
        execute_usecode_array(objectref, {17511, 7781})
        return
    end

    bark(objectref, "@Kal Lor@")
    if not check_spell_requirements() then
        execute_usecode_array(objectref, {17511, 7781})
        return
    end

    set_flag(FLAG_HELP_USED, true)
    clear_party_status_flags()

    begin_casting_mode(objectref, 859)
    -- Oracle success: sfx(64), up, standing, 0x6C, kneel, standing, up, usecode(0x645).
    -- Lua list is reverse execution order; 17493 = UC_USECODE, event 2 warps after poses.
    execute_usecode_array(objectref, {0x645, 17493, 8047, 8033, 8557, 8044, 8033, 8047, 64, 7768})
end
