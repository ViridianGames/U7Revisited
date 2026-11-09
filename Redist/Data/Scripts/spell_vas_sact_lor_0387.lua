--- Invisibility All (Vas Sanct Lor). Eighth Circle.
--- Sets item flag 0 on every party member. Do not destroy the caster.
--- Filename keeps the decompile typo ("sact") so spell lookup still finds _0387.

local function invis_party()
    local party = get_party_list2() or {}
    for _, npc_id in ipairs(party) do
        local obj_id = get_npc_object_id(npc_id)
        if obj_id and obj_id ~= -1 then
            set_item_flag(obj_id, 0)
            obj_sprite_effect(obj_id, 13)
        end
    end
end

function spell_vas_sact_lor_0387(eventid, objectref)
    if eventid == 2 then
        play_sound_effect(109)
        invis_party()
        return
    end

    if eventid ~= 1 then
        return
    end

    halt_scheduled(objectref)
    bark(objectref, "@Vas Sanct Lor@")
    if not check_spell_requirements(objectref) then
        execute_usecode_array(objectref, {17514, 17519, 17520, 7781})
        return
    end

    begin_casting_mode(objectref, 859)
    execute_usecode_array(objectref, {17514, 17519, 17520, 7791})
    play_sound_effect(109)
    obj_sprite_effect(objectref, 7)
    invis_party()
end
