-- Start zella_0920.lua
local strings = {
    [0x0062] = "It appears that thou dost not have enough gold to train.",
    [0x0110] = "You gather your gold and find thou hast only ",
    [0x014A] = " gold altogether.",
    [0x015C] = "It appears that thou dost not have enough gold to train.",
    [0x01E1] = "It appears that thou hast not the capacity to learn more at this time.",
    [0x024E] = "You pay ",
    [0x0257] = " gold.",
    [0x025E] = "Zella begins the lesson. She shows ",
    [0x0283] = " the proper stance for combat, instructs ",
    [0x0325] = " some steps, sparring with ",
    [0x034A] = " ",
    [0x034C] = " him and slowly ",
    [0x035D] = " a feel for the technique. They take turns trying to ",
    [0x03AC] = " take jabs at each other. Zella then ",
    [0x03CB] = " ",
    [0x03CD] = " proper defensive techniques. ",
    [0x0405] = " ",
    [0x0407] = " ",
    [0x0409] = " ",
    [0x040B] = " a better grip on combat."
}
answers = {}
answer = nil
local debug = true
function log(...) if debug then print(...) end end

function zella_0920(object_id, event)
    log("zella_0920 called with object_id:", object_id, "event:", event)
    local player_id = object_id -- TODO: Map to player ID
    local player_name = get_player_name() or "Avatar"
    local is_female = is_player_female() -- Requires implementation
    local pronoun = is_female and "She" or "He"
    local pronoun_lower = is_female and "she" or "he"
    local mimic = is_female and "mimics" or "mimic"
    local develops = is_female and "develops" or "develop"
    local them = is_female and "them" or "you"
    local feels = is_female and "feels" or "feel"
    local has = is_female and "has" or "have"
    local learns = is_female and "learns" or "learn"

    if player_id == -356 then
        player_name = is_female and "You" or "you"
        mimic = "mimic"
        develops = "develop"
        them = "you"
        feels = "feel"
        has = "have"
        learns = "learn"
    end

    if event == 2 then
        local gold_amount = get_gold() -- Placeholder: callis 0028
        if gold_amount == 0 then
            add_dialogue(object_id, strings[0x0062])
        elseif gold_amount == 1 then
            add_dialogue(object_id, strings[0x0110] .. gold_amount .. strings[0x014A])
            if gold_amount < 644 then
                add_dialogue(object_id, strings[0x015C])
            end
        elseif gold_amount == 2 then
            add_dialogue(object_id, strings[0x01E1])
        else
            add_dialogue(object_id, strings[0x024E] .. gold_amount .. strings[0x0257])
            spend_gold(gold_amount) -- Placeholder: callis 002B
            add_dialogue(object_id, strings[0x025E] .. player_name .. strings[0x0283] .. player_name .. strings[0x0325] .. pronoun_lower .. strings[0x034A] .. mimic .. strings[0x034C] .. develops .. strings[0x035D] .. them .. strings[0x03AC] .. player_name .. strings[0x03CB] .. learns .. strings[0x03CD] .. pronoun .. strings[0x0405] .. feels .. strings[0x0407] .. pronoun_lower .. strings[0x0409] .. has .. strings[0x040B])
            local strength = get_stat(player_id, 1) -- Requires implementation
            local dexterity = get_stat(player_id, 4)
            if strength < 30 then
                set_stat(player_id, 1, strength + 1)
            end
            if dexterity < 30 then
                set_stat(player_id, 4, dexterity + 1)
            end
        end
    end
    log("zella_0920 completed")
end
-- End zella_0920.lua