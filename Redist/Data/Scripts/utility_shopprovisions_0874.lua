--- Dell's provisions shop (Trinsic). Restored from func_0874 after rename loss.
--- Same purchase pattern as utility_shopweapons_0882.
function utility_shopprovisions_0874()
    local shopping = true
    local options = {
        "\"What wouldst thou like to buy?\"",
        "bedroll - 15 gold",
        "swamp boots - 40 gold",
        "bucket - 2 gold",
        "lockpicks - 8 gold",
        "backpack - 12 gold",
        "torch - 4 gold",
        "nothing"
    }
    local shapes = {583, 588, 810, 627, 801, 595, 0}
    local prices = {15, 40, 2, 8, 12, 4, 0}

    while shopping do
        local choice = get_purchase_option(options)
        if choice == 0 then
            add_dialogue("\"Fine.\"")
            shopping = false
        else
            -- UI inserts answers in reverse; map back to 1-based shape index (6 items).
            choice = 7 - choice
            if choice < 1 or choice > 6 or shapes[choice] == 0 then
                add_dialogue("\"Fine.\"")
                shopping = false
            else
                local amount = 1
                local doPurchase = true
                -- Lockpicks and torches: ask how many (up to 5), matching original usecode.
                if shapes[choice] == 627 or shapes[choice] == 595 then
                    amount = ask_number("\"How many wouldst thou like?\"", 0, 5, 1)
                    if amount == nil or amount < 1 then
                        add_dialogue("\"Fine.\"")
                        doPurchase = false
                    end
                end
                if doPurchase then
                    local result = purchase_object(shapes[choice], 0, prices[choice], amount)
                    if result == 0 then
                        add_dialogue("\"Fine.\"")
                    elseif result == 1 then
                        add_dialogue("\"Very good. At last we are getting somewhere!\"")
                    elseif result == 2 then
                        add_dialogue("\"Thou hast thine hands full, idiot!\"")
                    elseif result == 3 then
                        add_dialogue("\"Thou hast a lot of gall attempting to buy something from my shop without enough gold in thy possession!\"")
                    end
                end
                shopping = ask_yes_no("\"Anything else for thee today?\"")
            end
        end
    end
end

func_0874 = utility_shopprovisions_0874
