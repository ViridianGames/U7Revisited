--- Dell's armor shop (Trinsic). Restored from func_0873 after rename loss.
--- Same purchase pattern as utility_shopweapons_0882.
function utility_shoparmor_0873()
    local shopping = true
    local options = {
        "\"What wouldst thou like to buy?\"",
        "leather armour - 40 gold",
        "chain leggings - 70 gold",
        "leather leggings - 25 gold",
        "wooden shield - 15 gold",
        "leather helm - 25 gold",
        "nothing"
    }
    -- Shapes: leather armour, chain legs, leather legs, wooden shield, leather helm
    local shapes = {569, 575, 574, 572, 1004, 0}
    local prices = {40, 70, 25, 15, 25, 0}

    while shopping do
        local choice = get_purchase_option(options)
        if choice == 0 then
            add_dialogue("\"Fine.\"")
            shopping = false
        else
            -- UI inserts answers in reverse; map back to 1-based shape index (5 items).
            choice = 6 - choice
            if choice < 1 or choice > 5 or shapes[choice] == 0 then
                add_dialogue("\"Fine.\"")
                shopping = false
            else
                local result = purchase_object(shapes[choice], 0, prices[choice], 1)
                if result == 0 then
                    add_dialogue("\"Fine.\"")
                elseif result == 1 then
                    add_dialogue("\"Very good. At last we are getting somewhere!\"")
                elseif result == 2 then
                    add_dialogue("\"Thou hast thine hands full, idiot!\"")
                elseif result == 3 then
                    add_dialogue("\"Thou hast a lot of gall attempting to buy something from my shop without enough gold in thy possession!\"")
                end
                shopping = ask_yes_no("\"Anything else for thee today?\"")
            end
        end
    end
end

func_0873 = utility_shoparmor_0873
