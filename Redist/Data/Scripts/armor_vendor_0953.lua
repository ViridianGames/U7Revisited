-- Start armor_vendor_0953.lua
local strings = {
    [0x0000] = "crested helm",
    [0x000D] = "plate leggings",
    [0x001C] = "plate armour",
    [0x0029] = "great helm",
    [0x0034] = "gauntlets",
    [0x003E] = "chain leggings",
    [0x004D] = "chain armour",
    [0x005A] = "chain coif",
    [0x0065] = "nothing",
    [0x006D] = "a ",
    [0x0070] = "",
    [0x0071] = "",
    [0x0072] = "a ",
    [0x0075] = "",
    [0x0076] = "",
    [0x0077] = "",
    [0x0078] = "a ",
    [0x007B] = "",
    [0x007C] = "",
    [0x007D] = " for a pair",
    [0x0089] = "",
    [0x008A] = "",
    [0x008B] = " for a pair",
    [0x0097] = " for a pair",
    [0x00A3] = "",
    [0x00A4] = "",
    [0x00A5] = "",
    [0x00A6] = "\"What wouldst thou like to buy?\"",
    [0x00C7] = "\"Fine.\"",
    [0x00CF] = "^",
    [0x00D2] = " Is that acceptable?\"",
    [0x00E8] = "\"Done!\"",
    [0x00F0] = "\"Thou cannot possibly carry that much!\"",
    [0x0118] = "\"Thou dost not have enough gold for that!\"",
    [0x0143] = "\"Wouldst thou like something else?\""
}
answers = {}
answer = nil
local debug = true
function log(...) if debug then print(...) end end

function armor_vendor_0953(object_id, event)
    log("armor_vendor_0953 called with object_id:", object_id, "event:", event)
    local items = {
        strings[0x0000], strings[0x000D], strings[0x001C], strings[0x0029],
        strings[0x0034], strings[0x003E], strings[0x004D], strings[0x005A], strings[0x0065]
    }
    local object_ids = {542, 576, 573, 541, 580, 575, 571, 539, 0}
    local prices = {60, 120, 300, 150, 20, 50, 100, 80, 0}
    local prefixes = {
        strings[0x006D], strings[0x0070], strings[0x0071], strings[0x0072],
        strings[0x0075], strings[0x0076], strings[0x0077], strings[0x0078], strings[0x007B]
    }
    local suffixes = {
        strings[0x007C], strings[0x007D], strings[0x0089], strings[0x008A],
        strings[0x008B], strings[0x0097], strings[0x00A3], strings[0x00A4], strings[0x00A5]
    }
    local continue = true
    save_answers()
    answers = items
    log("Initial answers: ", table.concat(answers, ", "))

    while continue do
        add_dialogue(object_id, strings[0x00A6])
        local choice = get_answer()
        if choice == 1 then
            add_dialogue(object_id, strings[0x00C7])
            continue = false
        else
            local price = prices[choice]
            local object_id = object_ids[choice]
            local prefix = prefixes[choice]
            local suffix = suffixes[choice]
            local result = buyobject_(prefix, object_id, 1, price, items[choice])
            add_dialogue(object_id, strings[0x00CF] .. result .. strings[0x00D2])
            local buy_response = get_answer()
            buy_response = buyobject_(prefix, object_id, 1, price, items[choice])
            if buy_response == 1 then
                add_dialogue(object_id, strings[0x00E8])
            elseif buy_response == 2 then
                add_dialogue(object_id, strings[0x00F0])
            elseif buy_response == 3 then
                add_dialogue(object_id, strings[0x0118])
            end
        end
        add_dialogue(object_id, strings[0x0143])
        continue = get_answer()
    end
    restore_answers()
    log("armor_vendor_0953 completed")
end
-- End armor_vendor_0953.lua