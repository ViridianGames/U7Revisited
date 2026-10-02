--- Inventory presence helper used by converted NPC scripts.
---
--- Prefer is_object_in_party_inventory() for new code. This wrapper remains so
--- older call sites (utility_unknown_1073 / check_object_ownership) keep working.
---
--- For silver serpent venom (shape 649), scripts historically called:
---   utility_unknown_1073(1, 357, 649, 359, 1)
---   utility_unknown_1073(1, 359, 649, 1, 357)

SHAPE_SILVER_SERPENT_VENOM = 649

--- Legacy name used by many converted scripts. Now backed by the engine.
function check_object_ownership(arg1, arg2, arg3, arg4)
    -- Best-effort: if arg2 looks like a shape, treat as party shape check.
    local shape = nil
    if type(arg2) == "number" and arg2 > 1 and arg2 < 2000 then
        shape = arg2
    elseif type(arg3) == "number" and arg3 > 1 and arg3 < 2000 then
        shape = arg3
    elseif type(arg1) == "number" and arg1 > 1 and arg1 < 2000 then
        shape = arg1
    end
    if not shape or type(is_object_in_party_inventory) ~= "function" then
        return 0
    end
    local ok, has = pcall(is_object_in_party_inventory, shape)
    if ok and has then
        return 1
    end
    return 0
end

--- Returns true if the party has at least the requested quantity of an item.
--- Accepts the 4- and 5-arg Exult-style forms from converted scripts.
function utility_unknown_1073(arg1, arg2, arg3, arg4, arg5)
    local shape = nil
    local quantity = 1

    if arg5 ~= nil then
        -- 5-arg forms used for venom checks:
        --   (1, 357, 649, 359, 1)  or  (1, 359, 649, 1, 357)
        if type(arg3) == "number" and arg3 > 1 then
            shape = arg3
        elseif type(arg2) == "number" and arg2 > 1 then
            shape = arg2
        end
        if type(arg1) == "number" and arg1 > 0 and arg1 < 100 then
            quantity = arg1
        end
        if arg5 == 357 and type(arg4) == "number" and arg4 > 0 and arg4 < 100 then
            quantity = arg4
        end
    else
        -- 4-arg: often (quality, shape, frame, container)
        shape = arg2
        quantity = 1
    end

    if type(shape) ~= "number" then
        return false
    end
    if type(quantity) ~= "number" or quantity < 1 then
        quantity = 1
    end

    if type(is_object_in_party_inventory) ~= "function" then
        return false
    end

    local ok, has = pcall(is_object_in_party_inventory, shape, -1, -1, quantity)
    if not ok then
        return false
    end
    return has and true or false
end
