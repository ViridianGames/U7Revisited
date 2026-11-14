--- Rudyom's Wand (shape 771). Double-click aims it.
--- Any target thunders. Blackrock (914) is removed. The Black Gate (305)
--- speaks Batlin's line while he is nearby; with the beams of light gone
--- and Batlin absent, it calls the ending.

local BLACKROCK = 914
local BLACK_GATE = 305
local BEAM = 168
local BATLIN = 403

local function nonempty(list)
    return type(list) == "table" and #list > 0
end

-- A wand in a pack sits at the void point. Measure from whoever is holding it.
local function outermost(id)
    local guard = 0
    while id and guard < 8 do
        local parent = get_container(id)
        if not parent or parent == 0 then
            return id
        end
        id = parent
        guard = guard + 1
    end
    return id
end

local function strike()
    play_sound_effect(62)
    lightning()
end

function object_wand_0771(eventid, objectref)
    -- Event 4 is a weapon hit: the caller passes the thing that was struck.
    local target
    if eventid == 4 then
        target = objectref
    else
        target = object_select_modal()
    end
    if not target or target == 0 then
        return
    end

    close_gumps()
    local shape = get_object_shape(target)
    local avatar = get_avatar_ref()

    if shape == BLACKROCK then
        if avatar and avatar > 0 then
            local dir = find_direction(avatar, target) or 0
            -- Face the rock, ready, then stand. The powder-keg swing stays off
            -- this path; the rock is removed on its own after one second.
            execute_usecode_array(avatar, {17505, 17511, 8449, dir, 7769})
        end
        execute_usecode_array(target, {7981, 5, 7719})
    elseif shape == BLACK_GATE then
        local near = (eventid == 4) and target or outermost(objectref)
        local beams = find_nearby(near, BEAM, 12, 0) or {}
        local batlin = find_nearby(-356, BATLIN, 80, 0) or {}
        if nonempty(batlin) then
            start_conversation()
            switch_talk_to(26, 0)
            add_dialogue("The wand glows faintly. Batlin smirks. \"Not yet, Avatar.\"")
            return
        end
        if not nonempty(beams) then
            console_log("Rudyom's Wand: the Black Gate ending starts.")
            run_endgame(true)
        end
    end

    strike()
end
