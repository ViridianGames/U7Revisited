--- Create Food (In Mani Ylem). Oracle: usecode.dc Func0648 / object#0x648.
--- Spawns shape 377 with random frame 1..30 at each party member's feet.

local function spawn_create_food_meals()
    local party = get_party_list2()
    if type(party) ~= "table" then
        return
    end

    for _, npc_id in ipairs(party) do
        local obj_id = get_npc_object_id(npc_id)
        if obj_id and obj_id ~= -1 then
            local pos = get_object_position(obj_id)
            if pos then
                local food = create_new_object(377)
                if food then
                    -- usecode: UI_die_roll(1, 0x1E) → frames 1..30
                    set_object_frame(food, die_roll(1, 30))
                    set_item_flag(food, 18) -- FLAG_OK_TO_TAKE
                    update_last_created(pos)
                end
            end
        end
    end
end

function spell_create_food_in_mani_ylem_0328(eventid, objectref)
    if eventid == 1 then
        -- Spellbook passes the mage as objectref; do not destroy them.
        bark(objectref, "@In Mani Ylem@")
        if check_spell_requirements() then
            -- Cast FX only (SFX + delays). Stripped UC_USECODE+0x648: the engine's
            -- UC_USECODE path calls Interact(2) on the caster, not this spell.
            execute_usecode_array(objectref, {17511, 17509, 8038, 68, 7768})
            spawn_create_food_meals()
        else
            execute_usecode_array(objectref, {1542, 17493, 17511, 17509, 7782})
        end
    elseif eventid == 2 then
        spawn_create_food_meals()
    end
end
