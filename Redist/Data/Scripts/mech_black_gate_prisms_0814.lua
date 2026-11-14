--- Prism placement at the Black Gate.
--- A pedestal (shape 577) counts when it shares the prism's frame and stands
--- on the prism's tile or any of the eight tiles around it. The original
--- pedestals are a tile off the spot the prism lands. Height may be the
--- pedestal's own height or up to two levels above it.

local function tile_delta(a, b)
    local dx = math.abs(math.floor(a[1]) - math.floor(b[1]))
    local dz = math.abs(math.floor(a[3]) - math.floor(b[3]))
    if dx > dz then
        return dx
    end
    return dz
end

function mech_black_gate_prisms_0814(eventid, objectref)
    close_gumps()

    -- Called as mech_black_gate_prisms_0814(prism), so the prism is eventid.
    local anchor = objectref or eventid
    local anchor_pos = anchor and get_object_position(anchor) or nil
    if not anchor_pos then
        console_log("Prism check: no prism to measure from.")
        return
    end

    local beams = find_nearby(anchor, 168, 20, 0) or {}
    local pedestals = find_nearby(anchor, 577, 20, 0) or {}
    local prisms = find_nearby(anchor, 981, 20, 0) or {}
    if get_object_shape(anchor) == 981 then
        local listed = false
        for i = 1, #prisms do
            if prisms[i] == anchor then
                listed = true
            end
        end
        if not listed then
            prisms[#prisms + 1] = anchor
        end
    end

    local used = {}
    local seated = 0
    for i = 1, #prisms do
        local prism = prisms[i]
        local ppos = get_object_position(prism)
        local pframe = get_object_frame(prism)
        local best, best_pos, best_frame, best_d
        if ppos then
            for j = 1, #pedestals do
                local ped = pedestals[j]
                if not used[ped] then
                    local bpos = get_object_position(ped)
                    local bframe = get_object_frame(ped)
                    if bpos and bframe == pframe then
                        local d = tile_delta(ppos, bpos)
                        local dh = math.abs(ppos[2] - bpos[2])
                        if d <= 1 and dh <= 2 and (not best or d < best_d) then
                            best = ped
                            best_pos = bpos
                            best_frame = bframe
                            best_d = d
                        end
                    end
                end
            end
        end
        if best then
            used[best] = prism
            seated = seated + 1
            console_log(string.format(
                "Prism placed correctly: prism %s frame %s on tile %d,%d, pedestal %s frame %s on tile %d,%d (%d tile away).",
                tostring(prism), tostring(pframe),
                math.floor(ppos[1]), math.floor(ppos[3]),
                tostring(best), tostring(best_frame),
                math.floor(best_pos[1]), math.floor(best_pos[3]),
                best_d))
            if prism == anchor then
                sprite_effect(-1, 2, -1, -1, ppos[2], ppos[1], 7)
            end
        elseif ppos then
            console_log(string.format(
                "Prism %s frame %s on tile %d,%d: no matching pedestal on that tile or the eight around it.",
                tostring(prism), tostring(pframe),
                math.floor(ppos[1]), math.floor(ppos[3])))
        end
    end

    console_log("Prism check: " .. seated .. " of 3.")

    if seated == 3 then
        for i = 1, #beams do
            remove_item(beams[i])
        end
        console_log("All three prisms are placed. Removed " .. #beams .. " beam(s) of light.")
        -- Speech 14 is U7SPEECH member 14, file ordinal 10.
        play_sound_effect("Audio/Voice/U7BG_voice_010.wav")
        console_log("Playing Audio/Voice/U7BG_voice_010.wav (speech 14).")
    else
        for i = 1, #beams do
            local frame = get_object_frame(beams[i]) or 0
            set_object_frame(beams[i], (frame % 8) + seated * 8)
        end
    end
end
