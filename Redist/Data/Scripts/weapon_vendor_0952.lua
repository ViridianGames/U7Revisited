-- Start weapon_vendor_0952.lua
local strings = {
    [0x0000] = "2-handed axe",
    [0x000D] = "2-handed sword",
    [0x001C] = "sword",
    [0x0022] = "mace",
    [0x0027] = "dagger",
    [0x002E] = "throwing axe",
    [0x003B] = "nothing",
    [0x0043] = "\"What wouldst thou like to buy?\"",
    [0x0064] = "\"Fine.\"",
    [0x006C] = "a ",
    [0x006F] = "",
    [0x0070] = "^",
    [0x0073] = " Wilt thou buy it at that price?\"",
    [0x0095] = "\"Done!\"",
    [0x009D] = "\"Thou cannot possibly carry that much!\"",
    [0x00C5] = "\"Thou dost not have enough gold for that!\"",
    [0x00F0] = "\"Wouldst thou like something else?\""
}
answers = {}
answer = nil
local debug = true
function log(...) if debug then print(...) end end

function weapon_vendor_0952(eventid, objectref)
    log("weapon_vendor_0952 called with objectref:", objectref, "eventid:", eventid)
    local items = {
        strings[0x0000], strings[0x000D], strings[0x001C], strings[0x0022],
        strings[0x0027], strings[0x002E], strings[0x003B]
    }
    local object_ids = {601, 602, 599, 659, 594, 593, 0}
    local prices = {70, 125, 70, 15, 12, 20, 0}
    local prefixes = {
        strings[0x006C], strings[0x006C], strings[0x006C], strings[0x006C],
        strings[0x006C], strings[0x006C], strings[0x006F]
    }
    local continue = true
    save_answers()
    answers = items
    log("Initial answers: ", table.concat(answers, ", "))

    while continue do
        add_dialogue(strings[0x0043])
        local choice = get_answer()
        if choice == 1 then
            add_dialogue(strings[0x0064])
            continue = false
        else
            local price = prices[choice]
            local object_id = object_ids[choice]
            local prefix = prefixes[choice]
            local result = buyobject_(prefix, objectref, 1, price, items[choice])
            add_dialogue(strings[0x0070] .. result .. strings[0x0073])
            local buy_response = get_answer()
            buy_response = buyobject_(prefix, object_id, 1, price, items[choice])
            if buy_response == 1 then
                add_dialogue(strings[0x0095])
            elseif buy_response == 2 then
                add_dialogue(strings[0x009D])
            elseif buy_response == 3 then
                add_dialogue(strings[0x00C5])
            end
        end
        add_dialogue(strings[0x00F0])
        continue = get_answer()
    end
    restore_answers()
    log("weapon_vendor_0952 completed")
end
-- End weapon_vendor_0952.lua