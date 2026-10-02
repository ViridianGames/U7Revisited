--- Party greeting for Tseramed: forgive past deception if needed, then offer help.
---@param party_size integer The number of party members
---@param player_name string The player's name or title
function npc_shamino_forgiveness_1012(party_size, player_name)
    local whom = "thee"
    if party_size > 2 then
        whom = "the party"
    end
    -- Flag 349: Tseramed was angered by a false Fellowship identity claim.
    if get_flag(349) then
        add_dialogue("^" .. player_name .. ", I have weighed thine actions against thy former conduct. Now that I am travelling with " .. whom .. "...")
        add_dialogue("I forgive thy misrepresentation at our first meeting.")
        set_flag(349, false)
    end
    if math.random(1, 3) == 1 then
        add_dialogue("\"I enjoy travelling with " .. whom .. ".\"")
    end
    if get_item_flag(0, 356) then
        add_dialogue("\"Avatar! 'Tis strange to converse yet not see the speaker. Invisibility is queer magic.\"")
    end
    add_dialogue("\"How may I assist " .. whom .. ", " .. player_name .. "?\"")
    add_answer({"leave", "bees"})
end
