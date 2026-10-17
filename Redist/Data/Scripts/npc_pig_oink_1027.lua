--- fn_0903: a party member opens the dialogue portrait, says the supplied text,
--- and closes only that portrait. Flag 25 replaces the text with "Oink".
--- The original gate is NPCInParty (intrinsic 0x2F), not a distance check.
function npc_pig_oink_1027(npc_id, message)
    -- Party ids are 0 for the Avatar and 1, 2, ... for companions.
    -- Usecode also passes 356/-356 for the Avatar and negative companion ids.
    local party_id = npc_id
    if party_id == 356 or party_id == -356 then
        party_id = 0
    end
    if not npc_id_in_party(party_id) then
        return
    end

    local function show_line(text)
        if type(text) ~= "string" or text == "" then
            return
        end
        if text:sub(1, 1) == "@" then
            text = text:sub(2)
        end
        if text:sub(-1) == "@" then
            text = text:sub(1, -2)
        end
        if text ~= "" then
            add_dialogue(text)
        end
    end

    local is_avatar = npc_id == 356 or npc_id == -356 or npc_id == 0
    -- Portraits are U7FACES + npc id + frame. The Avatar is npc 0
    -- (U7FACES00 male, U7FACES01 female). 356 is only the usecode ref.
    -- fn_0902 returns negative companion ids (-2 is Spark); the face is the positive id.
    local portrait_id = npc_id
    if is_avatar then
        portrait_id = 0
    elseif type(npc_id) == "number" and npc_id < 0 and npc_id > -256 then
        portrait_id = -npc_id
    end
    local frame = (is_avatar and is_player_female()) and 1 or 0
    start_conversation()
    switch_talk_to(portrait_id, frame)

    -- get_item_flag returns 0 or 1. In Lua, 0 is true, so compare to 1.
    -- Flag 25 is the pig polymorph. A clear flag must still say the real line.
    local speaker = get_npc_name(is_avatar and 356 or npc_id)
    if speaker and get_item_flag(speaker, 25) == 1 then
        add_dialogue("Oink")
    elseif type(message) == "table" then
        for _, line in ipairs(message) do
            show_line(line)
        end
    else
        show_line(message)
    end
    end_conversation()
end
