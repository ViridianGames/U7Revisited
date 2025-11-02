-- Start tavern_vendor_0951.lua
local strings = {
    [0x0000] = "ale",
    [0x0004] = "wine",
    [0x0009] = "cake",
    [0x000E] = "Silverleaf",
    [0x0019] = "trout",
    [0x001F] = "mead",
    [0x0024] = "bread",
    [0x002A] = "mutton",
    [0x0031] = "nothing",
    [0x003A] = " for one bottle",
    [0x004A] = " for one bottle",
    [0x005A] = " for one slice",
    [0x0069] = " for one portion",
    [0x007A] = " for one portion",
    [0x008B] = " for one bottle",
    [0x009B] = " for one loaf",
    [0x00A9] = " for one portion",
    [0x00BB] = "\"What wouldst thou like?\"",
    [0x00D5] = "\"Fine.\"",
    [0x00DD] = "\"I regret to tell thee that this fine establishment will no longer be able to provide our fine customers with Silverleaf. The person who provides me with the delicate meal is no longer able to procure it. I am dreadfully sorry, ",
    [0x01C2] = ".\"",
    [0x01C5] = "^",
    [0x01C8] = " That is a fair price, is it not?\"",
    [0x01EB] = "\"How many wouldst thou like?\"",
    [0x0209] = "\"Done!\"",
    [0x0211] = "\"Thou cannot possibly carry that much!\"",
    [0x0239] = "\"Thou dost not have enough gold for that!\"",
    [0x0264] = "\"Wouldst thou like something else?\""
}
answers = {}
answer = nil
local debug = true
function log(...) if debug then print(...) end end

function tavern_vendor_0951(eventid, objectref)
    log("tavern_vendor_0951 called with objectref:", objectref, "eventid:", eventid)
    local items = {
        strings[0x0000], strings[0x0004], strings[0x0009], strings[0x000E],
        strings[0x0019], strings[0x001F], strings[0x0024], strings[0x002A], strings[0x0031]
    }
    local object_ids = {616, 616, 377, 377, 377, 616, 377, 377, 0}
    local prices = {3, 5, 5, 31, 12, 0, 1, 8, -359}
    local suffixes = {
        strings[0x003A], strings[0x004A], strings[0x005A], strings[0x0069],
        strings[0x007A], strings[0x008B], strings[0x009B], strings[0x00A9], ""
    }
    local continue = true
    save_answers()
    answers = items
    log("Initial answers: ", table.concat(answers, ", "))

    while continue do
        add_dialogue( strings[0x00BB])
        local choice = get_answer()
        if choice == 1 then
            add_dialogue(strings[0x00D5])
            continue = false
        elseif choice == 6 and not get_flag(0x012B) then
            add_dialogue(strings[0x00DD] .. (get_player_name() or "Avatar") .. strings[0x01C2])
        else
            local price = prices[choice]
            local object_id = object_ids[choice]
            local suffix = suffixes[choice]
            local result = buy_object(suffix, object_id, 1, price, items[choice])
            add_dialogue(strings[0x01C5] .. result .. strings[0x01C8])
            local buy_response = get_answer()
            if price == 377 then
                add_dialogue(strings[0x01EB])
                buy_response = buy_object(suffix, object_id, math.random(1, 20), price, items[choice])
            else
                buy_response = buy_object(suffix, object_id, 1, price, items[choice])
            end
            if buy_response == 1 then
                add_dialogue(strings[0x0209])
            elseif buy_response == 2 then
                add_dialogue(strings[0x0211])
            elseif buy_response == 3 then
                add_dialogue(strings[0x0239])
            end
        end
        add_dialogue(strings[0x0264])
        continue = get_answer()
    end
    restore_answers()
    log("tavern_vendor_0951 completed")
end
-- End tavern_vendor_0951.lua