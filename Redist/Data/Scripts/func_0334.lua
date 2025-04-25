-- Displays text on a plaque based on its quality, used for various signs and inscriptions.
function func_0334H(eventid, itemref)
    local target = itemref
    local quality = get_item_quality(target)
    local text = {}
    if eventid == 3 then
        if get_item_type(target) ~= 820 then -- 0334H: Plaque.
            local items = find_items(target, 820, 5, 176) -- TODO: Implement LuaFindItems for callis 0035.
            target = call_script(0x093D, items) -- TODO: Map 093DH (possibly select item).
            if not target then
                return
            end
        end
        quality = get_item_quality(target)
        text = {}
        if quality == 7 then
            text = {557, 623, 600} -- Specific quest items.
        elseif quality == 8 then
            text = {627}
        elseif quality == 9 then
            text = {640}
        elseif quality == 10 then
            text = {654}
        elseif quality == 11 then
            text = {644, 645, 646}
        end
        local found = false
        for _, item in ipairs(text) do
            if find_items(target, item, 5, 176) then
                if quality == 11 then
                    quality = quality + 1
                    set_item_quality(target, quality)
                    use_item()
                    found = true
                    break
                end
                local pos = get_item_info(target)
                create_effect(7, pos[1], pos[2], 0, 0, -1, 0) -- TODO: Implement LuaCreateEffect for callis 0053.
                apply_effect(68) -- TODO: Implement LuaApplyEffect for calli 000F.
                remove_item(target)
                use_item()
                return
            end
        end
        if not found then
            return
        end
    end
    local choice = call_script(0x0908) -- TODO: Map 0908H (possibly get choice).
    if quality > 65 then
        text = {"This is not a valid plaque"}
    elseif quality == 0 then
        text = {"here", "recorded", "to|be", "event", "important"}
    elseif quality == 1 then
        text = {"forgiven", "but|not", "forgotten", "kronos", "tomb|of"}
    elseif quality == 2 then
        text = {"(+tre", "royal"}
    elseif quality == 3 then
        text = {"HALL", "FELLOWSHIP"}
    elseif quality == 4 then
        text = {"STRENGTH", "OF", "TEST"}
    elseif quality == 5 then
        text = {"RETREAT", "MEDITATION"}
    elseif quality == 6 then
        text = {"THE CODEX", "SHRINE OF"}
    elseif quality == 7 then
        text = {"enter", "to", "here", "hammer"}
    elseif quality == 8 then
        text = {"goi*", "to|k)p", "carefully", "pick|item"}
        say(0, {"Look at it now!", "The sign appears to have changed!", "By Jove, I think thou art on the right track!"})
    elseif quality == 9 then
        text = {"faces|()", "tru(", "ring|of", "a|golden"}
    elseif quality == 10 then
        text = {"(r+ds", "at", "not", "grasp"}
    elseif quality == 11 then
        text = {"back", "hold|()", "shall|not", "royal|mint", "(e"}
    elseif quality == 12 then
        text = {"GO THIS WAY"}
    elseif quality == 13 then
        text = {"THIS WAY", "GO", "DO NOT"}
    elseif quality == 14 then
        text = {"WOODEN DOOR", "THE", "IN", "DO NOT GO"}
    elseif quality == 15 then
        text = {"DOOR", "WINDOWED", "THE", "GO IN", "DO NOT"}
    elseif quality == 16 then
        text = {"DOOR", "STEEL", "THE", "IN", "GO"}
    elseif quality == 17 then
        text = {"GREEN DOOR", "IN THE", "GO", "DO NOT"}
    elseif quality == 18 then
        text = {"IS TRUE", "SIGNS", "OF THESE", "ONE", "ONLY"}
    elseif quality == 19 then
        text = {"FALSE", "ARE", "TWO SIGNS", "AT LEAST"}
    elseif quality == 20 then
        text = {"BRANCH", "NATIONAL"}
    elseif quality == 21 then
        text = {"AVATAR?", "AN", "ART THOU"}
    elseif quality == 22 then
        text = {"NOW!", "SEATS", "THY", "RESERVE"}
    elseif quality == 23 then
        text = {"FOSSIL", "BRITANNIAN", "EARLIEST", "ZOG:", "THE BONES OF"}
    elseif quality == 24 then
        text = {"AVATAR", "BY THE", "ONCE WORN", "SWAMP BOOTS"}
    elseif quality == 25 then
        text = {"COMPOSING", "USED WHILE", "HARPSICORD", "MANITTZI'S"}
    elseif quality == 26 then
        text = {"SPRING|", "OF", "|ANIA"}
    elseif quality == 27 then
        text = {"flower", "fine,", "skara|braes", "|marney|"}
    elseif quality == 28 then
        text = {"inn", "wayfarers", "(e"}
    elseif quality == 29 then
        text = {"boar", "blue", "(e"}
    elseif quality == 30 then
        text = {"museum", "royal"}
    elseif quality == 31 then
        text = {"hall", "music", "(e"}
    elseif quality == 32 then
        text = {"hall", "town"}
    elseif quality == 33 then
        text = {"mint", "royal"}
    elseif quality == 34 then
        text = {"CHANGES", "MANY", "OF", "THRONE", "THE"}
    elseif quality == 35 then
        text = {"VIRTUE", "OF", "THRONE", "THE"}
    elseif quality == 36 then
        text = {"MUSKET", "BRITISH'S", "LORD"}
    elseif quality == 37 then
        text = {"VIRTUE", "OF", "STONES", "THE"}
    elseif quality == 38 then
        text = {"GARGOYLES", "BY THE", "ONCE USED", "HORN", "SILVER"}
    elseif quality == 39 then
        text = {"SNAKES", "SILVER", "THE", "TO SUMMON"}
    elseif quality == 40 then
        text = {"VIRTUES", "THE", "SYMBOL OF", "", "THE ANKH"}
    elseif quality == 41 then
        text = {"BRITISH", "LORD"}
    elseif quality == 42 then
        text = {"AVATAR", "THE"}
    elseif quality == 43 then
        text = {"CUBE", "VORTEX", "THE"}
    elseif quality == 44 then
        text = {"VIRTUES", "THE", "OF", "RUNES", "THE"}
    elseif quality == 45 then
        text = {"bridge", "knights", "of", "game", "(e"}
    elseif quality == 46 then
        text = {"ENTER", "DO NOT"}
    elseif quality == 47 then
        text = {"ferry", "summon", "to", "horn", "blow"}
    elseif quality == 48 then
        local plaque_pos = get_item_info(target)
        local avatar_pos = get_item_info(-23)
        if math.abs(plaque_pos[1] - avatar_pos[1]) <= 2 and math.abs(plaque_pos[2] - avatar_pos[2]) <= 2 then
            local arr = {7765, 8021, 1545, 8021, 1545, 7981}
            execute_action(target, arr)
            local arr2 = {7719, 8024, 17496, 19, 8033, 17517, 17496, 29, 7937, 17518, 17493}
            execute_action(-23, arr2)
            say(0, {"Yancey-Hausman will pay!", "He's dead, Avatar!", ""})
            local arr3 = {7715, 17494, 26}
            execute_action(-356, arr3)
            return
        end
        text = {"BRITISH", "LORD", "OF", "ROOM", "THRONE", "THE"}
    elseif quality == 49 then
        text = {"BRITANNIA", "LORD OF", "THE NEXT", "THOU ART", "SEE IF"}
    elseif quality == 50 then
        text = {"mama", "of", "memory", "lovi*", "in"}
    elseif quality == 51 then
        text = {"DRAGON", "THE", "BEWARE"}
    elseif quality == 52 then
        text = {"marney", "of", "love", "(e", "for"}
    elseif quality == 53 then
        text = {"writer", "a|gr+t", "man", "a|gr+t", "|j|r|r|t|"}
    elseif quality == 54 then
        text = {"LENS", "BRITANNIAN", "THE"}
    elseif quality == 55 then
        text = {"LENS", "GARGOYLE", "THE"}
    elseif quality == 56 then
        text = {"POR", "EX"}
    elseif quality == 57 then
        text = {"love", "of", "te,", "(e"}
    elseif quality == 58 then
        text = {"courage", "of", "te,", "(e"}
    elseif quality == 59 then
        text = {"way", "(e", "is", "nor("}
    elseif quality == 60 then
        text = {"tru(", "is", "tru("}
    elseif quality == 61 then
        text = {"deceptive", "are", "app+rances", "only"}
    elseif quality == 62 then
        text = {"done", "well"}
    elseif quality == 63 then
        text = {"tru(", "of", "keys", "(e"}
    elseif quality == 64 then
        text = {"path", "obvious", "always|(e", "tru,|not"}
    elseif quality == 65 then
        text = {"see|(is", "wish|to", "do,|not", "(ou"}
    end
    display_sign(text, 51) -- TODO: Implement LuaDisplaySign for calli 0032.
end