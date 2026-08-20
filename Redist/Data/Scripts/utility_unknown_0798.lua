--- Paired door / multi-piece door helper (usecode Func081E / 0x81E).
---
--- After the clicked door piece is updated by utility_position_0797 (Func081D),
--- this finds a nearby sibling piece of shape P7 whose frame%4 matches P6 and
--- that shares a coordinate axis with the clicked piece, then runs 0797 on it.
---
--- Lua arg order is reversed from the original usecode call (decompiler convention):
---   utility_unknown_0798(p8, y_off, x_off, frame_adj, other_shape, pos_idx, frame_need, shape_find, item)
--- Original: Func081E(item, shape_find, frame_need, pos_idx, other_shape, frame_adj, x_off, y_off, p8)

function utility_unknown_0798(P0, P1, P2, P3, P4, P5, P6, P7, P8)
    local y_off = P1 or 0
    local x_off = P2 or 0
    local frame_adj = P3 or 0
    local other_shape = P4
    local pos_idx = P5 or 1
    local frame_need = P6 or 0
    local shape_find = P7
    local item = P8

    if not item or not shape_find or not other_shape then
        return
    end

    local item_pos = get_object_position(item)
    if not item_pos then
        return
    end

    -- pos_idx is 1-based: 1=x, 2=y(lift), 3=z
    local align = item_pos[pos_idx]
    if align == nil then
        if pos_idx == 1 then align = item_pos.x
        elseif pos_idx == 2 then align = item_pos.y
        else align = item_pos.z
        end
    end

    -- Engine find_nearby(objectref, shape, distance, mask)
    local nearby = find_nearby(item, shape_find, 7, 0)
    if type(nearby) ~= "table" then
        return
    end

    local match = nil
    for _, obj in ipairs(nearby) do
        if obj and obj ~= item then
            local fr = utility_unknown_0795(obj)
            if fr == frame_need then
                local p = get_object_position(obj)
                if p then
                    local other_align = p[pos_idx]
                    if other_align == nil then
                        if pos_idx == 1 then other_align = p.x
                        elseif pos_idx == 2 then other_align = p.y
                        else other_align = p.z
                        end
                    end
                    -- Same axis alignment (double-door leaves share an edge)
                    if other_align ~= nil and math.abs(other_align - align) < 0.6 then
                        match = obj
                        break
                    end
                end
            end
        end
    end

    if match then
        -- Apply same open/close transform as 0797: (p5, y_off, x_off, frame_adj, shape, obj)
        -- P0 from the original call is typically 5 or 7; pass through as first arg.
        utility_position_0797(P0 or 7, y_off, x_off, frame_adj, other_shape, match)
    end
end
