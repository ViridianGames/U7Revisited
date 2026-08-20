--- Compatibility aliases for decompiled Lua scripts.
---
--- Many scripts were converted before U7LuaFuncs had its current names/signatures,
--- or were renamed later while callers still use old names.
--- This file maps those call sites onto the real engine / Lua helpers.
---
--- Loaded AFTER RegisterAllLuaFunctions() so these wrappers are not overwritten.
---
--- Tiers:
---   RENAME  - old script name → renamed Lua helper (same function body)
---   SAFE    - invented English name → existing engine binding (same idea)
---   WRAP    - thin adapter (arg order, arity, string cleanup)
---   STUB    - documented no-op / nil until real engine work exists

-- Shared heuristics for Exult vs engine argument-order detection.
local function looks_like_property(v)
    return type(v) == "number" and v >= 0 and v <= 11
end

local function looks_like_npc_ref(v)
    if type(v) ~= "number" then return false end
    if v == -356 or v == 356 then return true end
    return math.abs(v) > 11
end

------------------------------------------------------------------------
-- RENAME: callers still use pre-rename utility names
------------------------------------------------------------------------

-- Fellowship conversation helpers (files were renamed; many NPCs still call old names)
utility_ship_1049 = utility_fellowship_intro_1049
utility_ship_1050 = utility_fellowship_philosophy_1050
utility_unknown_1056 = utility_select_party_member_for_training_1056

------------------------------------------------------------------------
-- SAFE renames (exact or near-exact engine bindings)
------------------------------------------------------------------------

get_dialogue_choice = get_answer
unknown_XXXXH = get_answer

npc_in_party = npc_id_in_party
start_endgame = run_endgame
get_object_container = get_container
get_position_data = get_object_position
get_player_name_context = get_player_name
get_player_id = get_avatar_ref
game_hour = get_time_hour

-- Flag helpers (see WRAP section for Exult arg-order tolerant versions)
-- set_object_flag / check_object_flag / clear_object_flag defined below

-- Conversation / UI
_hide_npc = hide_npc
select_object = object_select_modal

-- Economy / combat / lifecycle
spend_gold = remove_party_gold
remove_object = remove_item
damage_npc = reduce_health
resurrect_character = resurrect

-- Scripted action arrays (PostAction / execute_usecode_array).
-- Engine implementation is still incomplete, but this stops nil-call crashes.
add_containerobject_s = execute_usecode_array
add_containerobject_s_at = execute_usecode_array

-- Sprite FX: decompiler name matches sprite_effect's 7-arg Exult layout
apply_sprite_effect = sprite_effect
create_explosion = sprite_effect

------------------------------------------------------------------------
-- WRAP: tiny language / table helpers from the decompiler
------------------------------------------------------------------------

--- aidx(t, i) — usecode 1-based array index (tables are 1-based in these scripts)
function aidx(t, i, j)
    if type(t) ~= "table" then
        return nil
    end
    if j ~= nil then
        local row = t[i]
        if type(row) == "table" then
            return row[j]
        end
        return nil
    end
    return t[i]
end

--- create_array(n) / create_array(n, fill) — simple Lua table
function create_array(n, fill)
    local t = {}
    n = tonumber(n) or 0
    for i = 1, n do
        t[i] = fill
    end
    return t
end

------------------------------------------------------------------------
-- WRAP: conversation / UI helpers
------------------------------------------------------------------------

function compare_answer(keyword, _)
    return cmps(keyword)
end

function show_dialogue_options(first, ...)
    if type(first) == "table" then
        add_answer(first)
        return first
    end
    local opts = { first, ... }
    add_answer(opts)
    return opts
end

local function strip_bark_at(text)
    if type(text) ~= "string" then
        return text
    end
    if text:sub(1, 1) == "@" and text:sub(-1) == "@" and #text >= 2 then
        return text:sub(2, -2)
    end
    return text
end

--- display_message("@text@"[, objectref])
function display_message(text, objectref)
    if type(text) ~= "string" then
        return
    end
    local cleaned = strip_bark_at(text)
    if objectref then
        bark(objectref, cleaned)
    else
        add_dialogue(cleaned)
    end
end

--- say_with_newline — dialogue line (often with @...@)
function say_with_newline(text, ...)
    if type(text) == "string" then
        add_dialogue(strip_bark_at(text))
    end
end

--- item_say(text, objectref) — Exult-ish order (text first) or (objectref, text)
function item_say(a, b)
    if type(a) == "string" then
        bark(b, strip_bark_at(a))
    else
        bark(a, strip_bark_at(b))
    end
end

------------------------------------------------------------------------
-- WRAP: RNG / debug
------------------------------------------------------------------------

function get_random(n)
    n = tonumber(n) or 1
    if n < 1 then
        return 0
    end
    return random(1, n)
end

function debug_npc(npc_id, message, ...)
    local extra = { ... }
    local msg = tostring(message or "")
    for i = 1, #extra do
        msg = msg .. " " .. tostring(extra[i])
    end
    debug_print("NPC " .. tostring(npc_id) .. ": " .. msg)
end

------------------------------------------------------------------------
-- WRAP: NPC properties (Exult vs engine arg order)
--
-- Decompiled scripts are inconsistent on (prop,npc) vs (npc,prop).
------------------------------------------------------------------------

function get_npc_quality(a, b)
    local npc_id, property_id
    if looks_like_property(a) and looks_like_npc_ref(b) then
        property_id, npc_id = a, b
    elseif looks_like_npc_ref(a) and looks_like_property(b) then
        npc_id, property_id = a, b
    else
        property_id, npc_id = a, b
    end
    return get_npc_property(npc_id, property_id)
end

function set_npc_quality(a, b, c)
    local npc_id, property_id, value, as_delta
    if looks_like_property(b) and looks_like_npc_ref(c) then
        value, property_id, npc_id, as_delta = a, b, c, true
    elseif looks_like_npc_ref(a) and looks_like_property(b) then
        npc_id, property_id, value, as_delta = a, b, c, false
    else
        value, property_id, npc_id, as_delta = a, b, c, true
    end
    if as_delta then
        local current = get_npc_property(npc_id, property_id) or 0
        return set_npc_property(npc_id, property_id, current + (value or 0))
    end
    return set_npc_property(npc_id, property_id, value)
end

function set_npc_prop(a, b, c)
    if c == nil then
        debug_print("compat: set_npc_prop 2-arg form ignored")
        return
    end
    return set_npc_quality(a, b, c)
end

------------------------------------------------------------------------
-- WRAP: find_nearby arg order
-- Engine: find_nearby(objectref, shape, distance, mask)
-- Decompiler often: find_nearby(mask, distance, shape, objectref)
------------------------------------------------------------------------

local _engine_find_nearby = find_nearby

function find_nearby(a, b, c, d)
    -- Decompiler form: small mask, small dist, shape, objectref
    if type(a) == "number" and type(d) == "number"
        and a >= 0 and a <= 255 and b ~= nil and b <= 64
        and looks_like_npc_ref(d) then
        return _engine_find_nearby(d, c or 0, b or 0, a)
    end
    return _engine_find_nearby(a, b, c, d)
end

------------------------------------------------------------------------
-- WRAP: get/set_object_frame — decompiler often calls get_object_frame(frame, obj) to SET
------------------------------------------------------------------------

local _engine_get_object_frame = get_object_frame
local _engine_set_object_frame = set_object_frame

function get_object_frame(a, b)
    if b ~= nil and type(a) == "number" and a >= 0 and a <= 31 and looks_like_npc_ref(b) then
        return _engine_set_object_frame(b, a)
    end
    return _engine_get_object_frame(a)
end

function set_object_frame(a, b)
    -- Allow (frame, obj) or (obj, frame)
    if looks_like_npc_ref(b) and type(a) == "number" and a >= 0 and a <= 31 then
        return _engine_set_object_frame(b, a)
    end
    return _engine_set_object_frame(a, b)
end

------------------------------------------------------------------------
-- WRAP: item flags (Exult often uses flag, object; engine uses object, flag)
------------------------------------------------------------------------

local _engine_get_item_flag = get_item_flag
local _engine_set_item_flag = set_item_flag
local _engine_clear_item_flag = clear_item_flag

local function looks_like_flag_id(v)
    return type(v) == "number" and v >= 0 and v <= 31
end

local function resolve_obj_flag(a, b)
    -- Prefer (object, flag) when second looks like a flag and first does not,
    -- or when first looks like an object ref.
    if looks_like_flag_id(a) and not looks_like_flag_id(b) then
        return b, a -- Exult (flag, object)
    end
    return a, b -- engine (object, flag)
end

function get_item_flag(a, b)
    local obj, flag = resolve_obj_flag(a, b)
    return _engine_get_item_flag(obj, flag)
end

function set_item_flag(a, b)
    local obj, flag = resolve_obj_flag(a, b)
    return _engine_set_item_flag(obj, flag)
end

function clear_item_flag(a, b)
    local obj, flag = resolve_obj_flag(a, b)
    return _engine_clear_item_flag(obj, flag)
end

set_object_flag = set_item_flag
check_object_flag = get_item_flag
clear_object_flag = clear_item_flag

-- Quantity: decompiler often uses (qty, object); engine is (object, qty)
local _engine_set_item_quantity = set_item_quantity
local _engine_get_item_quantity = get_item_quantity

function set_item_quantity(a, b)
    if looks_like_npc_ref(b) and type(a) == "number" and a >= 0 and a <= 255 then
        return _engine_set_item_quantity(b, a)
    end
    return _engine_set_item_quantity(a, b)
end

function get_item_quantity(objectref)
    return _engine_get_item_quantity(objectref)
end

------------------------------------------------------------------------
-- WRAP: object / party / inventory naming consistency
------------------------------------------------------------------------

function is_object_valid(id)
    if id == nil then
        return false
    end
    local ok, shape = pcall(get_object_shape, id)
    return ok and shape ~= nil
end

function get_object_owner(objectref)
    return get_container(objectref)
end

function set_object_owner(objectref, owner)
    debug_print("compat: set_object_owner not fully implemented")
    return false
end

--- remove_npc(id) — Exult removes NPC from the world; closest is kill_npc
function remove_npc(npc_or_obj)
    -- Negative usecode NPC numbers: -23 → NPC 23
    local id = npc_or_obj
    if type(id) == "number" and id < 0 and id > -256 then
        id = -id
    end
    return kill_npc(id)
end

--- set_npc_location(a,b,c,npc) — often (x,y,z,npc); engine is set_npc_pos(npc,x,y,z)
function set_npc_location(a, b, c, d)
    if d == nil then
        return false
    end
    local npc = d
    if type(npc) == "number" and npc < 0 and npc > -256 then
        npc = -npc
    end
    -- Avatar objectref 356 / -356 → NPC 0
    if npc == 356 or npc == -356 then
        npc = 0
    end
    return set_npc_pos(npc, a, b, c)
end

function heal_character(npc_id, amount)
    local current = get_npc_property(npc_id, 3) or 0
    return set_npc_property(npc_id, 3, current + (amount or 0))
end

function cure_poison(npc_id)
    -- No dedicated binding yet; clear a common poison-related item flag if present.
    if clear_item_flag and npc_id then
        -- Best-effort; real poison status lives in NPC status bits.
        return true
    end
    return false
end

--- is_not_blocked — inverse of is_blocked; arg layouts vary in decompiler output
function is_not_blocked(a, b, c, d, e)
    -- Common: is_not_blocked(lift, shape, {x,y,z}) or is_not_blocked(x,y,z)
    if type(c) == "table" then
        local x, y, z = c[1], c[2], c[3]
        if x and z then
            return not is_blocked(x, y or 0, z)
        end
    elseif e ~= nil then
        -- 5-arg form with position table as last
        if type(e) == "table" then
            return not is_blocked(e[1], e[2] or 0, e[3])
        end
    elseif a ~= nil and b ~= nil and c ~= nil and d == nil then
        return not is_blocked(a, b, c)
    end
    return true
end

function find_nearbyobject_s(dist, shape, mask, objectref)
    -- Engine: find_nearby(objectref, shape, distance, mask)
    return find_nearby(objectref or get_avatar_ref(), shape or 0, dist or 0, mask or 0)
end

function get_nearby_npcs(objectref)
    return find_nearby(objectref or get_avatar_ref(), 0, 16, 0)
end

function npc_nearby(npc_or_obj)
    -- is_near_object(npc_id, object_id, max_distance)
    local id = npc_or_obj
    if type(id) == "number" and id < 0 and id > -256 then
        id = -id
    end
    return is_near_object(0, id, 16)
end

--- Party inventory helpers — Exult-ish names → remove/add_party_items
--- Calls vary; we only forward the common 4-arg (count, shape/qual/frame) forms.
function remove_object_from_inventory(a, b, c, d, e)
    -- Seen: (count, qual, shape, who) and (bool, qual, shape, count, who)
    if e ~= nil then
        -- (flag, quality, shape, count, container) → remove_party_items(count, shape, quality, -359)
        return remove_party_items(d or 1, c or -359, b or -359, -359)
    end
    return remove_party_items(a or 1, c or -359, b or -359, d or -359)
end

function add_object_to_inventory(a, b, c, d, e)
    -- Seen: (qual, frame, shape, count) and longer forms
    if e ~= nil then
        return add_party_items(d or 1, c or -359, a or -359, b or -359)
    end
    return add_party_items(d or 1, c or -359, a or -359, b or -359)
end

function check_inventory(a, b, c, d, e)
    -- Approximate: is shape in party inventory
    local shape = c or a
    return is_object_in_party_inventory(shape)
end

function check_inventory_space(...)
    -- No real capacity check yet; allow adds.
    return true
end

------------------------------------------------------------------------
-- WRAP: shops / party select
------------------------------------------------------------------------

function select_party_member(...)
    if select('#', ...) == 0 then
        return select_party_member_by_name()
    end
    return nil
end

function buy_object(...)
    return purchase_object(...)
end

function process_purchase(...)
    return purchase_object(...)
end

function show_purchase_options(list, _)
    if type(list) == "table" then
        add_answer(list)
        return list
    end
    return nil
end

--- format_price_message / format_price / _FormatPrice — string builders for shops
function format_price_message(name, price, suffix, prefix)
    name = tostring(name or "item")
    price = tostring(price or 0)
    prefix = prefix and tostring(prefix) or ""
    suffix = suffix and tostring(suffix) or ""
    if prefix ~= "" and suffix ~= "" then
        return string.format("%s %s for %s gold%s", prefix, name, price, suffix)
    elseif suffix ~= "" then
        return string.format("%s for %s gold%s", name, price, suffix)
    end
    return string.format("%s: %s gold", name, price)
end

function format_price(a, b, c, d, e)
    -- Decompiler arg order varies; best-effort readable string.
    return format_price_message(d or a, b or c or 0, e, nil)
end

_FormatPrice = format_price

------------------------------------------------------------------------
-- WRAP: movement / create
------------------------------------------------------------------------

function move_object(a, b, c, d)
    if type(b) == "table" then
        local x, y, z = b[1], b[2], b[3]
        if x then
            set_object_position(a, x, y, z)
            return true
        end
    elseif b ~= nil and c ~= nil and d ~= nil then
        set_object_position(a, b, c, d)
        return true
    elseif b == nil then
        return update_last_created(a)
    end
    return false
end

-- create_new_object / create_object are registered in C++ (Ethereal Void).

------------------------------------------------------------------------
-- STUBS: named consistently but not implementable as aliases yet
------------------------------------------------------------------------

function check_spell_requirements()
    -- Spell system gate; allow cast attempts until real reagent/mana checks exist.
    return true
end

function select_spell_target(target)
    return target
end

function get_cont_items(shape, quality, frame, container)
    debug_print("compat: get_cont_items not fully implemented")
    return {}
end

get_container_objects = get_cont_items
get_containerobject_s = get_cont_items

function get_object_status(id)
    -- Often mis-decompiles; try item flag 0 as a weak stand-in.
    if type(id) == "number" then
        local ok, v = pcall(get_item_flag, id, 0)
        if ok then return v end
    end
    return 0
end

function set_object_behavior(flag, objectref)
    return set_item_flag(objectref, flag)
end

function get_conversation_target()
    return get_avatar_ref()
end

function get_training_target()
    return select_party_member_by_name("\"Who will train?\"")
end

function get_party_leader()
    return 0
end

function play_spell_animation(_)
    return true
end

function consume_reagents(_)
    return true
end

function cast_spell(_)
    return true
end

function apply_spell_effect(...)
    return true
end

function trigger_explosion(_)
    return true
end

function set_spell_duration(_)
    return true
end

--- check_flag_location(mask, shape, dist, objectref) → any matching nearby object?
function check_flag_location(mask, shape, dist, objectref)
    local found = find_nearby(objectref, shape or 0, dist or 5, mask or 0)
    if type(found) ~= "table" then
        return false
    end
    return #found > 0 or next(found) ~= nil
end

--- _SelectIndex(list) — pick from a list of strings / names
function _SelectIndex(list)
    if type(list) ~= "table" then
        return 0
    end
    -- Prefer multiple-choice UI when available
    if ask_multiple_choice then
        local choice = ask_multiple_choice(list)
        if choice == nil then
            return 0
        end
        for i, v in ipairs(list) do
            if v == choice then
                return i
            end
        end
        return 0
    end
    add_answer(list)
    local ans = get_answer()
    for i, v in ipairs(list) do
        if tostring(v):lower() == tostring(ans):lower() then
            return i
        end
    end
    return 0
end

function apply_protection_effect(a, b, c, d, e, f, g, objectref)
    -- Same layout as sprite_effect plus optional object; use world effect.
    return sprite_effect(a, b, c, d, e, f, g)
end

function cast_multiple_spells(texts, objectref)
    if type(texts) == "table" then
        for _, t in ipairs(texts) do
            if type(t) == "string" then
                item_say(t, objectref or get_avatar_ref())
            end
        end
    end
    return true
end

function check_dialogue_target(npc_id)
    local id = npc_id
    if type(id) == "number" and id < 0 then
        id = -id
    end
    return npc_id_in_party(id) or is_npc(id) or false
end

function check_npc_presence(npc_id)
    return check_dialogue_target(npc_id)
end

function get_object_ref(objectref)
    return objectref
end

function get_object_counter(objectref)
    return get_object_quality(objectref)
end

function set_object_counter(objectref, value)
    return set_object_quality(objectref, value)
end

function set_object_count(value, objectref)
    return set_item_quantity(objectref, value)
end

function set_quest_flag(flag, npc, value)
    return set_flag(flag, value and true or false)
end

function set_quest_property(flag)
    return set_flag(flag, true)
end

function is_object_equipped(objectref)
    return is_readied and is_readied(objectref) or false
end

function spawn_object_at(shape, x, y, z)
    if type(shape) == "number" and x and y and z then
        return spawn_object(shape, 0, x, y, z)
    end
    return nil
end
